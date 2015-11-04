In order to generate the Figure at the following location:

<iframe src="http://wl.figshare.com/articles/1590989/embed?show_title=1" width="568" height="502" frameborder="0"></iframe>

(which shows FracKin analysis of data collected in Old Woman Wash, near the San Rafael monocline in central Utah) files stored in this repository must be used according the protocol below.  The numerical input file serves to validate correct operation of FracKin.m, a Matlab implementation of a new kinematic algorithm, via numerical output file and the Figure.

Four resources are required:
1) Matlab; 
2) algorithm library published by Allmendinger et al. (2012), link provided with Figure; 
3) two matlab.m files stored in this repository; 
4) a valid input file, such as the one in this repository for validation.

Collect all files for 2), 3), and 4) into a single local directory. 
Launch Matlab and direct it to the local directory containing collected files. 
Click in the Command Window, type "FracKin" (case sensitive), and enter/return. 
A new dialog box will appear, asking for an input file. 
  Navigate to "Old Woman Wash input.txt" and select. 
  Figure should be reproduced in a new "FracKin" window. 
"Old Woman Wash numerical output.txt" should be reproduced by clicking the "Save Numerical Results" button in the "FracKin" window.
  OR
Figure can be saved by choosing "Save" in the "File" menu of the "FracKin" window (.eps is most flexible output option). 
  OR
"Quit" button in the "FracKin" window. 
Dismiss the "FracKin" window.

Provided that both output files are replicated, third-party input files may be substituted for the example provided in this repository.  In that case, the "FracKin" window provides numerical and graphical (pub quality) analyses of third-party input.  If third-party results are interesting, then publish them!  I request only that third-party cite this DOI:

