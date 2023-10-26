# trEYEcopa
Code for eyetracking the TriCOPA videos

# Dependencies
This experiment uses the [TriangleCOPA](https://github.com/asgordon/TriangleCOPA) stimulus set, which is included in this repo.

We make use of [PsychToolbox](http://psychtoolbox.org/download.html) to handle I/O, 
which further requires [GStreamer](https://gstreamer.freedesktop.org/download/) to support video playback.
Please make sure both of those are installed and configured before running this experiment.


**As of 10/25/2023, Psychtoolbox does NOT work on Apple Silicon - you will need to run this experiment on an Intel-based computer.**

The experiment is intended to be run with an [SR Research Eyelink II eye tracker](https://www.sr-research.com/eyelink-ii/), which outputs data in .EDF format. (Though theoretically, any SR Research eye tracker would work).
We use [Alexander Pastukhov's edfImport](https://github.com/alexander-pastukhov/edfImport) to pull this data into MATLAB for analysis.
