Nuclear_shape
FIJI and Matlab pipeline for analysis of the nuclear orientation based on curvature analysis.


LICENCE:
%%  *****************************************************************
%  Copyright 2022 by Paolo Pierobon (CNRS, Institut Curie, PSL Research
%  University, INSERM U932, 26 rue d'Ulm, 75248 Paris, Cedex 05, France.)
%  Email: <pppierobon@gmail.com>
%  
%  Licensed under GNU General Public License 3.0 or later. 
%  Some rights reserved. See COPYING, AUTHORS.
%  @license GPL-3.0+ <http://spdx.org/licenses/GPL-3.0+>
%
%%  *****************************************************************




System requirements:
Matlab 2016b or older
Image Processing Toolbox
Statistics and Machine Learning Toolbox
The necessary functions of the matGeom and matImage are included in the folder (under appropriate license).

Install and configure:
Unzip the dowloaded directory and add all subdirectories to the path either manually or by going to the Nuclear_Shape folder and typing:
addpath(genpath('.'))

These functions works only on .tif multi-dimensional files with 2 channels (the nucleus in channel 1 and the droplet in channel 2). The final structure "data" contains the information for the plots used in the paper (each index of the structure represent a cell). The relevant outputs for the paper are saved (as time series) in the following fields:
distNucDrop: distance between the center of the nucleus and the droplet surface
distIndDrop: distance between the indentation and the droplet surface
distNucInd: distance between the indentation and the center of the nucleus
angleIndCom: angle between the vector nucleus-droplet and the vector nucleus-indentation (i.e. orientation of the nucleus w.r.t. the nucleus-droplet axis).

We are working on a more user friendly and data independent version (as well as a more complete description of the output).

Usage:
    1. Prepare files for Matlab analysis in FIJI:
prepare_nucleus_for_matlab_Batch
(check number of channels and resolution)
    2. Run core analysis of nucleus in Matlab: 
nuclear_shape_drop_movie (folder_containing_file)
    3. Generate the structure containing all data about the different movies and the data of the droplets in Matlab:
data=getMLABDataNuc(list); %for list use dir(“*.mat”))
    4. Compute corrected distances between nucleus and droplets in Matlab: data=correction_nucleus(data)
    5. To generate a movie use the following functions: 
patch_indent_movie

