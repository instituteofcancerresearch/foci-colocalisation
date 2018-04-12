# foci-colocalisation
 Adam Tyson | 15/12/2017 | adam.tyson@icr.ac.uk

To segment nuclei and two channels of foci. Foci are measured and various foci parameters, including colocalisation are returned. Requires MATLAB licence (any recent version should work, but was written with MATLAB 2017b). The Image Processing toolbox is also needed.




 Instructions:
 
 1- Export images as OME-TIFF (this is the default in slidebook, keep all options as default). There should be a C0, C1 and C2 image for each position.
 
 2- Unzip foci-colocalisation-master and place in the MATLAB path (e.g. C:\Users\User\Documents\MATLAB). 
 
 3- Open foci-colocalisation-master\fociMarkSeg.m and run (F5 or the green "Run" arrow under the "EDITOR" tab).
 
 4- Choose the directory containing all images.
 
 5- Adjust thresholds if necessary:
 
        Nuclear Threshold (a.u.) - increase to make segmentation more stringent, and vice versa.
        
        C1 threshold (a.u.) - increase to be more stringent on what is a focus.
        
        C1 foci minimum volume (voxels) - any detected "foci" below this volume (i.e. not real foci) will be removed.
        
        C2 threshold (a.u.) - increase to be more stringent on what is a focus.
        
        C2 foci minimum volume (voxels)- any detected "foci" below this volume (i.e. not real foci) will be removed.
        
 6. Choose other options:
 
        Remove edge cells? - Should cells that touch the edge of the image (in 2D, but not 3D) be removed from the analysis?
       
 7. Choose display options (mostly useful for optimising parameters). Otherwise many unnecessary windows will be opened.      
 
        Raw data - Shows a merge image of the three channels in 3D (the viewing parameters can be altered if necessary).
        
        Display segmention? - Shows a merged image of the binary signal from the three channels in 3D.
        
8. Choose saving options
  
        Save results as .xls? - Save all the extracted parameters, per cell, per image in an excel file.
          
        Save segmentation as .tif? - Save all the segmentation. One 3D tif per channel, per image will be generated. Useful to check             the segmentation, and for further analysis.

 
The script will then loop through all the images in the directory, analyse them and write the results (and/or segmentation files) to the same directory.

Once the first image has been analysed, the progress bar will give an estimate of the remaining time.
 
