function EEG = sl_epoching_with_drift_correction_pulses(EEG, NumSyllablesPerEpoch, drift_ms)
%
%   EEG = sl_epoching_with_drift_correction_pulses(EEG, NumSyllablesPerEpoch, drift_ms)
%
%   Create triggers, correct for drift, and epoch SL files for files that contain the 
%   timing test pulses at the beginning and end of the stimulus (2 pulses at the 
%   beginning, 2 pulses at the end, 300 ms each).
%   
%   Stimtracker is turned off for V08 visits, and EPrime cannot send TCP/IP triggers
%   with reliable timing, so there are no individual triggers corresponding to each 
%   SL syllable stimulus. Instead, we have to add triggers into the EEG file afterwards
%   based on what we know about the timing of each syllable (supposed to be 300 ms each).
%
%   However, due to clock desync between the EPrime and Netstation computers, the timing 
%   of the stimulus playback desynchronizes from the timing of the EEG recording. After
%   timing testing across many sites, this amount of desync/drift appears to be consistent
%   within any given setup (same amplifier, same EPrime computer). Thus, we can correct
%   for this drift by performing timing tests to measure the drift value, and using that 
%   drift value to shift the trigger timings. 
% 
%   During the timing test, these pulses are used to calculated the timing drift due
%   to clock desync between the EPrime and Netstation computers. This drift value is saved
%   in a csv and used to correct the timings of the "fake" triggers that we insert into 
%   the EEG file for epoching. 

%   Every NumSyllablesPerEpoch syllables, an 'NE' (new epoch) event is created. 'NE' events
%   are used to create epochs that are NumSyllablesPerEpoch * 0.300 sec long
%   The data are epoched on 'NE' events and baseline-corrected using the full epoch window
%   (all following Batterink et al. 2017 procedure).
%
%   As of 9/3/26, recordings shorter than the full 6 minute song are supported. The syllable
%   timeline `latencies` is first built for the full reported 6 minute song. The length of 
%   the EEG file is used to determine how many syllables were actually played, so that we 
%   can select how many epochs to actually create. A file longer than the song
%   (trailing pulses, recording tail) is capped at the song itself, so
%   full-length recordings behave exactly as they did before.
%
%   Inputs:
%     EEG                  - EEGLAB EEG structure
%     NumSyllablesPerEpoch - Number of syllables per epoch
%     drift_ms             - Total timing drift (ms) accumulated over the
%                            full recording (positive = stimuli arrived late)
%
%   Output:
%     EEG - Epoched and baseline-corrected EEG structure

    % length of syllable is always 300 ms, EpochLength depends on syllable duration
    interval_sec = 0.300;
    EpochLength  = NumSyllablesPerEpoch * interval_sec;

    % Pulse structure baked into the stimulus audio (no DIN triggers present
    % to mark it). Matches the span assumed by sl_compute_drift_from_timing_test_with_pulses:
    % Pulse 1 (300ms) + Pulse 2 (300ms) + SL song (6 min) + Pulse 3 (300ms)
    num_leading_pulses = 2;
    pulse_duration_sec = 0.300;
    song_duration_sec  = 6 * 60;

    % Trim data to the first syllable, i.e. the 'stms' event plus the 2 leading pulses
    evt_types = {EEG.event.type};
    stms_idx  = find(strcmp(evt_types, 'stms'), 1, 'first');
    if isempty(stms_idx)
        error('sl_epoching_with_drift_correction_pulses: no ''stms'' event found.');
    end
    srate       = EEG.srate;
    start_point = EEG.event(stms_idx).latency + (num_leading_pulses * pulse_duration_sec * srate);
    if round(start_point) > EEG.pnts
        error('sl_epoching_with_drift_correction_pulses: computed start point falls after the end of the recording -- check for a truncated file.');
    end
    EEG = pop_select(EEG, 'point', [round(start_point) EEG.pnts]);
    EEG = eeg_checkset(EEG);

    % Build ideal 300 ms latency array across the fixed 6-minute song.
    % This array describes the stimulus so it always covers the full 6 minutes 
    % regardless of the length of the actual EEG file. 
    % The trailing pulses are always excluded since they fall after the last syllable.
    n_latencies_full_song = song_duration_sec / interval_sec;
    times_sec             = (0:n_latencies_full_song-1) * interval_sec;
    latencies             = round((times_sec * srate) + 1);

    % Apply linear drift correction to latency array.
    drift_samples = (drift_ms / 1000) * srate;
    corrections   = round(drift_samples * (0:n_latencies_full_song-1) / (n_latencies_full_song-1));
    latencies     = latencies + corrections;

    % Calculate how much of the full 6 minute timeline the recording actually covers.
    % Short file (less than 6 min) --> only the syllables that fit in the recording are counted
    % Long file (more than 6 min) --> capped at 1200 syllables (full song)
    n_latencies_in_file = sum(latencies <= EEG.pnts);

    % Check that recording is long enough for at least one full epoch 
    if EEG.pnts < round(EpochLength * srate)
        error(['sl_epoching_with_drift_correction_pulses: recording is too short to fill one full epoch. ' ...
               'Recording has %d samples, but one epoch needs %d samples.'], ...
              EEG.pnts, round(EpochLength * srate));
    end

    % Place syll, word, and NE markers events
    % word replaces syll at every 3rd position
    % Always place NE events every NumSyllablesPerEpoch events (overlaps with word events)
    evt_idx = length(EEG.event);
    for i = 1:n_latencies_in_file
        lat = latencies(i);

        if mod(i-1, 3) == 0
            evt_idx = evt_idx + 1;
            EEG.event(evt_idx).latency = lat;
            EEG.event(evt_idx).type    = 'word';
            EEG.event(evt_idx).code    = 'word';
        else
            evt_idx = evt_idx + 1;
            EEG.event(evt_idx).latency = lat;
            EEG.event(evt_idx).type    = 'syll';
            EEG.event(evt_idx).code    = 'syll';
        end

        if mod(i-1, NumSyllablesPerEpoch) == 0
            evt_idx = evt_idx + 1;
            EEG.event(evt_idx).latency = lat;
            EEG.event(evt_idx).type    = 'NE';
            EEG.event(evt_idx).code    = 'NE';
        end
    end
    EEG = eeg_checkset(EEG, 'eventconsistency');

    % Keep only word, syll, and NE events
    keepEvents = arrayfun(@(e) any(strcmp(e.code, {'syll','word','NE'})), EEG.event);
    EEG.event = EEG.event(keepEvents);
    EEG = eeg_checkset(EEG, 'makeur');

    % Epoch on 'NE' markers
    EEG = pop_epoch(EEG, {'NE'}, [0 EpochLength], ...
        'newname', EEG.setname, 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG);

    % Baseline correction
    EEG = pop_rmbase(EEG, [EEG.times(1) EEG.times(end)]);
    EEG = eeg_checkset(EEG);

    % One epoch may overlap with the next epoch's first syllable if drift is 
    % negative, resulting in one epoch including the NE and word event from the 
    % next epoch's first event. 
    % Fix this by identifying any NE events that aren't the time locking event
    % (latency is not exactly EEG.pnts*(epoch-1)+1) and dropping that events
    % and any events with the same latency. This should remove any NE and word 
    % events at the end of each epoch that should belong to the next epoch. 
    event_offset_in_epoch = [EEG.event.latency] - (([EEG.event.epoch]-1)*EEG.pnts + 1);
    stray_event_mask      = strcmp({EEG.event.code}, 'NE') & event_offset_in_epoch ~= 0;
    EEG.event = EEG.event(~ismember([EEG.event.latency], [EEG.event(stray_event_mask).latency]));
    EEG = eeg_checkset(EEG, 'eventconsistency');

    % Sanity check for number of events per epoch
    for x = 1:numel(EEG.epoch)
        codes        = EEG.epoch(x).eventcode;
        NumSyllables = sum(strcmp(codes, 'syll')) + sum(strcmp(codes, 'word'));
        if NumSyllables ~= NumSyllablesPerEpoch
            error('sl_epoching_with_drift_correction_pulses: epoch %d has %d syll/word events (expected %d).', ...
                  x, NumSyllables, NumSyllablesPerEpoch);
        end
        n_ne = sum(strcmp(codes, 'NE'));
        if n_ne ~= 1
            error('sl_epoching_with_drift_correction_pulses: epoch %d has %d NE events (expected 1).', x, n_ne);
        end
    end

    fprintf('sl_epoching_with_drift_correction_pulses: %d epochs created.\n', numel(EEG.epoch));
end
