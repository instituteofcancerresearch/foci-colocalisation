  function fociSegData = segFoci3D(img,thresholdScale, minFociVox,gaussFilt)
%% Adam Tyson | 11/12/2017 | adam.tyson@icr.ac.uk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input:
% img - 3D image of foci to be segmented
% thresholdScale - change sensitivity of threshold (roughly 0.5-2)
% gaussFilt -  width of gaussian filter used to smooth foci prior to segmentation
% minFociVox - minimum foci volume in voxels (smaller than this are removed)

% output:
% fociSegData - a binary image of the segmented foci
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img=double(img);
img=scaleIm(img, max(img(:))); % scale slice by slice
% prep 
foci.smo=imgaussfilt(img,gaussFilt); % smooth

% threshold
levelOtsu=multithresh(foci.smo,2);
foci.bin=img;
foci.bin(img<thresholdScale*levelOtsu(2))=0;
foci.bin(foci.bin>0)=1;

% clean up
foci.smallRem=logical(bwareaopen(foci.bin, minFociVox)); % remove small objects rather than erode (need double for doubleColorMap later on)
fociSegData=foci.smallRem;

% figure; imshow3D(fociSegData)


 end