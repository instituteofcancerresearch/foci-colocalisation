function segIm=nucleiSeg(img, smallThresh, holeThresh, threshScale, removeEdge,nucVolThresh, gaussFilt)
%% Adam Tyson | 07/12/2017 | adam.tyson@icr.ac.uk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input:
% img - a 3D image of nuclei (DAPI, PI etc)
% smallThresh - size of minimum object to be retained after segmentation
% holeThresh - max volume of "holes" inside cells to be filled in
% threshScale - change sensitivity of threshold (roughly 0.5-2)
% removeEdge - binary - if 1, remove all cells that touch the sides (not
% top and bottom) of image volume

% output:
% segIm - segmented, binary image

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nuc.scale=double(img);
nuc.scale=scaleIm(nuc.scale, max(nuc.scale(:))); % scale slice by slice
nuc.smo=imgaussfilt(nuc.scale,gaussFilt); % smooth

% threshold
levelOtsu = threshScale*multithresh(nuc.smo);
nuc.bin=nuc.smo;
nuc.bin(nuc.smo<levelOtsu)=0;
nuc.bin(nuc.bin>0)=1;

% clean up
nuc.clean=logical(bwareaopen(nuc.bin, smallThresh)); % remove small objects
nuc.fill=~bwareaopen(~nuc.clean, holeThresh);   % fill in holes

% remove cells touching edge
if strcmp(removeEdge, 'Yes')
nuc.fill = imclearborder(nuc.fill,4);
else 
    
end
nuc.clean=bwareaopen(nuc.fill, nucVolThresh); % remove small objects
segIm=nuc.clean;
end