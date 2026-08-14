# Processing Settings and Configuration 

Selections of HBCD-MADE processing parameters are made in JSON keys rather than in the MATLAB preprocessing scripts. An example .json that has been used for processing data can be found [here](https://github.com/DCAN-Labs/HBCD-MADE/blob/main/proc_settings_HBCD.json). 

The settings specified in the JSON fall under two general categories:

**Global parameters** : These settings fall under the JSON key global_parameters and serve as the default settings across tasks.

**Unique task settings** : Task-specific parameters are specified below global_parameters. It is important that the name of your files follows BIDS formatting for the pipeline to correctly identify the task name for a given EEG file. For example, if you have a file named sub-{X}_ses-{X}_task-MMN_run-1_acq-eeg_eeg.set, you should have a field in your JSON file named MMN to denote the processing settings used for this task.

Parameters can be set in both global and task-specific keys. When there are conflicting settings, HBCD-MADE will continue processing with the task-specific settings. Because some processing (i.e., ICA) will occur on a merged version of all tasks, some settings should be the same across all tasks (e.g., high and low-pass filter cutoffs).

For a list of processing specifications for HBCD EEG data, see HBCD Processing Settings

## Global Parameters

These supported global settings are specified in the proc_settings_HBCD_container.json:

<table>
    <tr>
        <th>Parameter</th>
        <th>Parameter Data Type</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>boundary_marker</td>
        <td>String</td>
        <td>If this marker is present in the EEG file, data from <br> before this marker will be removed prior to analysis.</td>
    </tr>
    <tr>
        <td>ekg_channels</td>
        <td>String</td>
        <td>Non-cortical electrode measuring the electrocardiogram.</td>
    </tr>
    <tr>
        <td>channel_locations</td>
        <td>String</td>
        <td>The path to the .sfp file with electrode channel locations. <br> The sample_locs folder from EEGLAB is placed under <br> /sample_locs in the container, so these files can be directly <br> referenced from within the container (i.e., /sample_locs/GSN129.sfp). <br> Alternatively, an external path can be provided to a custom file, <br> but the path to this folder will then need to be bound to Singularity.</td>
    </tr>
    <tr>
        <td>down_sample</td>
        <td>Binary (1 or 0)</td>
        <td>Whether or not to downsample the data.</td>
    </tr>
    <tr>
        <td>sampling_rate</td>
        <td>Float</td>
        <td>The new sampling rate you want following downsampling. <br> This is only used if down_sample = 1.</td>
    </tr>
    <tr>
        <td>delete_outerlayer</td>
        <td>Binary (1 or 0)</td>
        <td>Whether the outer layer of channels should be deleted.</td>
    </tr>
    <tr>
        <td>outerlayer_channel</td>
        <td>List of strings</td>
        <td>Outer layer of channels to be deleted if delete_outerlayer = 1.</td>
    </tr>
    <tr>
        <td>highpass</td>
        <td>Float</td>
        <td>The high-pass filter cutoff frequency.</td>
    </tr>
    <tr>
        <td>lowpass</td>
        <td>Float</td>
        <td>The low-pass filter cutoff frequency.</td>
    </tr>
    <tr>
        <td>remove_baseline</td>
        <td>Binary (1 or 0) </td>
        <td>Whether to remove the baseline.</td>
    </tr>
    <tr>
        <td>baseline_window</td>
        <td>List</td>
        <td>Baseline time window.</td>
    </tr>
    <tr>
        <td>voltthresh_rejection</td>
        <td>Binary (1 or 0) </td>
        <td>Whether to remove epochs based on voltage rejection.</td>
    </tr>
    <tr>
        <td>volt_threshold</td>
        <td>List of two floats</td>
        <td>The negative and positive values in uV to use for <br> epoch thresholding.</td>
    </tr>
    <tr>
        <td>interp_epoch</td>
        <td>Binary (1 or 0) </td>
        <td>Whether to interpolate over removed epochs.</td>
    </tr>
    <tr>
        <td>frontal_channels</td>
        <td>List of strings</td>
        <td>Frontal channels.</td>
    </tr>
    <tr>
        <td>interp_channels</td>
        <td>Binary (1 or 0) </td>
        <td>Whether to interpolate channels.
    </tr>
    <tr>
        <td>rerefer_data</td>
        <td>Binary (1 or 0) </td>
        <td>Whether to re-reference the data.</td>
    </tr>
    <tr>
        <td>reref</td>
        <td>List of strings</td>
        <td>Either [ ] for the default re-referencing (average re-referencing) <br> or provide the electrodes to use as reference.</td>
    </tr>
    <tr>
        <td>output_format</td>
        <td>Binary (1 or 2) </td>
        <td>1 = .set; 2 = .mat</td>
    </tr>
</table>


## EEG Acquisition Flag Descriptions

### V03, V04, and V06


#### Resting State (RS)

<table>
    <tr>
        <th>Flag</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>Bgn+</td>
        <td>Start of task</td>
    </tr>
    <tr>
        <td>bas+</td>
        <td>Start of RS video</td>
    </tr>
    <tr>
        <td>DIN3</td>
        <td>StimTracker flag for visual stimuli</td>
    </tr>
    </tr>
        <td>TRSP</td>
        <td>End of stimulus presentation, contains additional stimulus information</td>
    </tr>
</table>



#### Visual Evoked Potential (VEP)

<table>
    <tr>
        <th>Flag</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>Bgn+</td>
        <td>Start of task</td>
    </tr>
    <tr>
        <td>Ch1+</td>
        <td>Checkerboard 1 presentation</td>
    </tr>
    <tr>
        <td>Ch2+</td>
        <td>Checkerboard 2 presentation</td>
    </tr>
    <tr>
        <td>DIN3</td>
        <td>StimTracker flag for visual stimuli</td>
    </tr>
    <tr>
        <td>TRSP</td>
        <td>End of stimulus presentation, contains additional stimulus information</td>
    </tr>
</table>



#### Mismatch Negativity (MMN)

<table>
    <tr>
        <th>Flag</th>
        <th>Description</th>
    </tr>
    </tr>
        <td>Bgn+</td>
        <td>Start of task</td>
    </tr>
    </tr>
        <td>Stms</td>
        <td>MMN stimuli presentation</td>
    </tr>
    </tr>
        <td>DIN2</td>
        <td>StimTracker flag for auditory stimuli</td>
    </tr>
    <tr>
        <td>TRSP</td>
        <td>End of stimulus presentation, contains additional stimulus information <br> (what sound was played)</td>
    </tr>
</table>



#### Face Processing (FACE)

<table>
    <tr>
        <th>Flag</th>
        <th>Description</th>
    </tr>
    </tr>
        <td>Bgn</td>
        <td>Start of task</td>
    </tr>
    </tr>
        <td>Stm+</td>
        <td>FACE stimuli presentation</td>
    </tr>
    </tr>
        <td>ITI+</td>
        <td>Inter-trial time</td>
    </tr>
    <tr>
        <td>fix+</td>
        <td>Fixation cross presentation (between faces)</td>
    </tr>
    <tr>
        <td>dist</td>
        <td>Distractor/attention grabber</td>
    </tr>
    <tr>
        <td>DIN3</td>
        <td>StimTracker flag for visual stimuli</td>
    </tr>
    <tr>
        <td>TRSP</td>
        <td>End of stimulus presentation, contains additional stimulus information <br> (what face was shown)</td>
    </tr>
</table>

### V08



#### Resting State (RS)

<table>
    <tr>
        <th>Flag</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>Bgin</td>
        <td>Start of task</td>
    </tr>
    <tr>
        <td>bas+</td>
        <td>Start of RS video</td>
    </tr>
    </tr>
        <td>TRSP</td>
        <td>End of stimulus presentation, contains additional stimulus information</td>
    </tr>
</table>



#### Movie Clips (MC)

<table>
    <tr>
        <th>Flag</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>Bgin</td>
        <td>Start of task</td>
    </tr>
    <tr>
        <td>soc+</td>
        <td>Start of MC video</td>
    </tr>
    </tr>
        <td>TRSP</td>
        <td>End of stimulus presentation, contains additional stimulus information</td>
    </tr>
</table>



#### Statistical Learning (SL)

<table>
    <tr>
        <th>Flag</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>Bgin</td>
        <td>Start of task</td>
    </tr>
    <tr>
        <td>Stms</td>
        <td>SL stimuli presentation</td>
    </tr>
    </tr>
        <td>TRSP</td>
        <td>End of stimulus presentation, contains additional stimulus information</td>
    </tr>
</table>



#### Emotional Faces (EMO)

<table>
    <tr>
        <th>Flag</th>
        <th>Description</th>
    </tr>
    </tr>
        <td>Bgn</td>
        <td>Start of task</td>
    </tr>
    </tr>
        <td>Stm+</td>
        <td>EMO stimuli presentation</td>
    </tr>
    </tr>
        <td>ITI+</td>
        <td>Inter-trial time</td>
    </tr>
    <tr>
        <td>fix+</td>
        <td>Fixation cross presentation (between faces)</td>
    </tr>
    <tr>
        <td>dist</td>
        <td>Distractor/attention grabber</td>
    </tr>
    <tr>
        <td>star</td>
        <td>Star trial presentation</td>
    </tr>
    <tr>
        <td>TRSP</td>
        <td>End of stimulus presentation, contains additional stimulus information <br> (what face was shown)</td>
    </tr>
</table>


## Unique Task Settings

<table>
    <tr>
        <th>Task Setting</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>ROI_of_interest</td>
        <td>Selects the regions of interest for scoring of ERPs.</td>
    </tr>
    <tr>
        <td>make_dummy_events</td>
        <td>(true or false) Whether to insert dummy events into your scan. <br> This option is used to create new events in the case of resting-state <br> acquisitions where there are no triggers to denote epochs.</td>
    </tr>
    <tr>
        <td>num_dummy_events</td>
        <td>(int) The number of dummy events to make if make_dummy_events = true.</td>
    </tr>
    </tr>
        <td>dummy_event_spacing</td>
        <td>(float) The amount of time (in seconds) to have between dummy events. <br> Note that epochs are constructed around events, so this isn’t the same <br> as spacing between epochs.</td>
    </tr>
    <tr>
        <td>pre_latency</td>
        <td>(float) The amount of time (in seconds) to include in an epoch prior to <br> the event specified by the entries in marker_names.
        </td>
    </tr>
    </tr>
        <td>post_latency</td>
        <td>(float) The amount of time (in seconds) to include in an epoch following the <br> event specified by the entries in marker_names.</td>
    </tr>
    </tr>
        <td>ERP_window_start</td>
        <td>Time window of interest in the topographic plots and the averages for <br> the .mat files.</td>
    </tr>
    <tr>
        <td>ERP_window_end</td>
        <td>Time window of interest in the topographic plots and the averages for <br> the .mat files.</td>
    </tr>
    </tr>
        <td>erp_filter</td>
        <td>Boolean variable indicating whether to apply a second low-pass filter before <br> creating ERPs.</td>
    </tr>
    </tr>
        <td>erp_lowpass</td>
        <td>Hz at which to apply the second low-pass filter.</td>
    </tr>
    </tr>
        <td>marker_names</td>
        <td>(list of strings) Name of event code markers you want to construct epochs <br> around (e.g., DIN3). If make_dummy_events = true, then this should instead <br> represent the first marker in your EEG file. Dummy events will then be placed <br> after the first instance of this marker.</td>
    </tr>
    </tr>
        <td>ERP_dirs</td>
        <td>Direction of ERP components listed in "ERP_names". [-1] indicates a <br> negaive-going component, and [1] indicates positive. These values are used <br> to specify whether MADE should search for a positive or negative peak when <br> computing peak latency and adaptive-mean amplitude for a given ERP.</td>
    </tr>
    </tr>
        <td>score_ages</td>
        <td>List of age bins used to compute ERPS with age-dependent time windows.</td>
    </tr>
    </tr>
        <td>score_times{X}</td>
        <td>Time ranges (in seconds) to use for plotting and scoring SME, ERP, <br> and peak measures.</td>
    </tr>
    </tr>
        <td>score_ROIs</td>
        <td>Regions of interest to use for plotting and scoring SME, ERP, <br> and peak measures.</td>
    </tr>
    </tr>
        <td>ERP_names</td>
        <td>Names of the scored ERP components</td>
    </tr>
</table>

!!! note
    DIN markers are inserted by a StimTracker and denote specific types of stimuli. DIN2 markers represent auditory stimuli from computer speakers, and DIN3 markers represent visual stimuli captured by a photocell on the participant monitor. DIN2 flags will always be present in MMN, and will appear in the FACE and VEP task only in cases when the researcher prompted “attention getter” stimuli which involve an auditory signal to bring the participant’s attention back to the computer screen. See [HBCD EEG Task Information](https://docs.hbcdstudy.org/latest/instruments/eeg/tasks/#hbcd-eeg-tasks) for more information.


### Age-Dependent ERP Time Windows
Some ERP components are scored with age-dependent time windows, which are defined in the [processing settings .json file](https://github.com/DCAN-Labs/HBCD-MADE/blob/main/proc_settings_HBCD.json). 

Here's an example of how to interpret the .json specifying the age-dependent ERP time windows:

 The code below states that for the VEP task in ses-V03, ERPs are scored as follows for participants who were 3-6 months old at EEG acquisition: 

- The N1 component is scored at the Oz cluster between 40 ms - 79 ms

- The P1 component is scored at the Oz cluster between 80 ms - 140 ms

- The N2 component is scored at the Oz cluster between 141 ms - 300 ms. 

`score_times2` defines the time windows for participants who were 6-9 months old at EEG acquisition. 

Unlike the ERP time windows, the ROI clusters used to score any given ERP are stable across age groups.  

```
"VEP": {
    "ses-V03": { 
        "ERP_dirs": [-1, 1, -1], #Direction of the N1, P1, and N2 components
        "score_ages": [[3,6],[6,9]], #age bins are 3-6 months and 6-9 months
        "score_times1":[[40, 79], [80,140], [141, 300]], # ERP time windows for 3-6 month olds for the N1, P1, and N2 components
        "score_times2":[[40, 79], [80,120], [121, 170]], # ERP time windows for 6-9 month olds for the N1, P1, and N2 components
        "score_ROIs": ["oz", "oz", "oz"], # Electrode cluser at ERP regions of interest for the N1 P1, and N2 components
        "ERP_names": ["N1", "P1", "N2"] # list of ERP components scored
    }
}
```

## Additional Functionality

The following functionality was added in MADE v.1.7.0 and will be reflected in the HBCD DR3.0. 

### StimTracker Artifact Detection and Correction
`stimtracker_artifact_interpolation.m` averages all epochs per task and flags voltage fluctuations >1 µV in two time windows: –10 to 10 ms and 250 to 270 ms. Voltage fluctuations during those time windows have been identified as an artifact originating from the StimTracker device. See the [Central HBCD docs](https://docs.hbcdstudy.org/latest/instruments/eeg/qc/#eeg-quality-control-procedures) for additional details about MADE's StimTracker artifact detection and correction algorithm. 

### Signal Uniformity Checks
`run_MADE.m` checks for signal uniformity, which may indicate technical issues during administration. 
