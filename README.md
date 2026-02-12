# trEYEcopa
Experiment and analysis code for a forthcoming manuscript by Hackney & Grossman at the University of California, Irvine.
This is an eye tracking experiment where participants view and interpret Heider-Simmel-style videos.

## Dependencies
We make use of [PsychToolbox](http://psychtoolbox.org/download.html) to handle I/O, 
which further requires [GStreamer](https://gstreamer.freedesktop.org/download/) to support video playback.
Please make sure both of those are installed and configured before running this experiment.


**As of 10/25/2023, Psychtoolbox does NOT work on Apple Silicon - you will need to run this experiment on an Intel-based computer.**

The experiment is intended to be run with an [SR Research Eyelink II eye tracker](https://www.sr-research.com/eyelink-ii/), which outputs data in .EDF format. (Though theoretically, any SR Research eye tracker would work).
We use [Alexander Pastukhov's edfImport](https://github.com/alexander-pastukhov/edfImport) to pull this data into MATLAB for analysis.
edfImport further requires you to install [SR Research's EDF API](https://www.sr-research.com/support/thread-13.html),
which is free but requires registration on their forum.

Some analyses make use of functions from Matlab's `Image Processing Toolbox`.
We also use [this False-Discovery Rate function](https://www.mathworks.com/matlabcentral/fileexchange/27418-fdr_bh) from the Matlab File Exchange.

## Setup
### Stimuli
This experiment uses a modified version of the [TriangleCOPA](https://github.com/asgordon/TriangleCOPA) stimulus set from Maslan, Roemmele, and Gordon (2015).
We also employed stimuli from Martin & Weisberg (2003) "Neural foundations for understanding social and mechanical concepts".

Stimuli as we used them are available on [OSF](https://osf.io/z6ysr/).
There should be two folders, `TriCOPA` and `MartinWeisberg`. Place both in `trEYEcopa/stims`. If properly set up:

`/stims/MartinWeisberg/` should have 16 videos.

`/stims/TriCOPA/` should have subfolders `flipped` and `normal`, each with 100 videos.
Flipped videos have the prefix `f_`, while normal does not. e.g. `flipped/f_Q13_6642_ignore.mov`

### Data
If you wish to analyze our data, the files are available on OSF [here](https://osf.io/ym7uq).
There should be two folders: `beh` and `data`.
Download and place them in the root trEYEcopa folder, i.e. at the same level as `specifyPaths.m`.
If properly set up, you should be able to find the following files at these locations:

`/beh/TC_01_task-TriCOPA_date-xxx.txt`

`/data/derivatives/TC/TC_01.mat`

`/data/source/TC/TC_01.edf`

## Use
### Experiment
To run the experiment, open MATLAB and call `Main_EyeLink()`.
A box will pop up asking for

1. a two-digit subject number (e.g. 01), and
1. an indicator 1 or 2 of which video set to use: 1 for TriCOPA or 2 for Martin & Weisberg (aka "the vignettes").

Output will be automatically sorted into `beh` and `data`.

### Analysis
To analyze the data:

- cd into `/Analysis/`
- run `addpath('..');` so that Matlab can access the `specifyPaths` function in root, then
- run `analysis('metricName');`

A list of available metric names is present in the header of `/Analysis/selectMetric`.
Our primary metrics were:

- `sfix` for "scaled fixation" i.e. the proportion of time fixated,
- `tot` for "time on target" i.e. proportion of time tracking characters, and
- `deviance` or proportion of time gaze deviated from visual motion.


By default, `analysis()` will invoke either `getTCData()` or `getMWData()`
to extract data from the EDF files in `/data/source/`.
If you have that data already loaded into memory (i.e. as a table),
then you can feed it into `analysis()` as a second argument.
For example, if you have already run
`totDF = getTCData('tot');` to get the Time on Target data, then you could run
`analysis('tot', totDF);` instead of waiting for `analysis()` to run `getTCData()` again.