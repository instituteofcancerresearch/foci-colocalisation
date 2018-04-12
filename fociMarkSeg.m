function fociMarkSeg
%% Adam Tyson | 07/12/2017 | adam.tyson@icr.ac.uk
% loads 3 channel data, segments ch0 (nuclei) and two others (foci). Ch1
% and ch2 are masked, and various colocalisation parameters are extracted

%% to do
% optimise export

% inputs
imgFolder = uigetdir('', 'Choose directory containing images');
vars=getVars; % local function for variables
tic

cd(imgFolder) 
C0files=dir('*C0.tif'); % all tif's in this folder
numImages=length(C0files);

progressbar('Analysing images') % Init prog bar
count=0;
analyse=1; % 0 to speed up segmentation tests

for file=C0files' % go through them all
    C0.filename=file.name;
    disp(['Processing: ' C0.filename])
    count=count+1; 
    info = imfinfo(C0.filename);
    numZ = numel(info);
    
    C0.img=uint16(zeros(info(1).Height, info(1).Width, numZ)); %initalise
    C1.img=C0.img;
    C2.img=C1.img;
    C1.filename = strrep(C0.filename,'C0','C1');
    C2.filename = strrep(C0.filename,'C0','C2');

    for k = 1:numZ
        C0.img(:,:,k) = imread(C0.filename, k, 'Info', info);
        C1.img(:,:,k) = imread(C1.filename, k, 'Info', info);
        C2.img(:,:,k) = imread(C2.filename, k, 'Info', info);
    end  
    
    % segment & mask
    C0.seg=nucleiSeg(C0.img, vars.smallThresh, vars.holeThresh, vars.nucThreshScale, vars.removeEdge, vars.nucVolThresh, vars.gaussFiltNuc);
    C1.seg = segFoci3D(C1.img,vars.thresholdScaleC1, vars.minFociVoxC1,vars.gaussFiltC1);
    C2.seg = segFoci3D(C2.img,vars.thresholdScaleC2, vars.minFociVoxC2,vars.gaussFiltC2);

    C1.segMask=C1.seg.*C0.seg;
    C2.segMask=C2.seg.*C0.seg;
    
    % display - prep
    if strcmp(vars.rawDisp, 'Yes') || strcmp(vars.segDisp, 'Yes')
     dispScale=(vars.scrsz(4)/size(C0.img,1)*0.6);
     vars.screenSize=[10 10 dispScale*size(C0.img,2) dispScale*size(C0.img,2)];
    end
    
    % display - raw data
    if strcmp(vars.rawDisp, 'Yes')
    rgbDisp(3*C2.img, 5*C1.img, 5*C0.img, vars.screenSize, ['Raw data  -  ' file.name])
    end
    
    % display - segmentation
    if strcmp(vars.segDisp, 'Yes')
    rgbDisp(C2.segMask, C1.segMask, C0.seg, vars.screenSize, ['Segmentation  -  ' file.name])
    end
    
    % analyse
    if analyse==1
    colocParam{count}=analyseFociColoc(C0.img, C1.img, C2.img, C0.seg, C1.seg, C2.seg);
    end
    
    % progress bar
    frac1 =count/numImages;
    progressbar(frac1)
    
    % save as .tif
    if strcmp(vars.saveSeg, 'Yes')
           saveSegmentation(file.name, C0.seg, C1.seg, C2.seg, vars.stamp);
    end

end

  % save as .xls
if strcmp(vars.saveResults, 'Yes')
     saveResults(colocParam, C0files, vars.stamp);
end

toc

end
%% Internal functions
function vars=getVars
% specificy variables

% nuclear seg
vars.smallThresh=1000;
vars.holeThresh=10000;
vars.nucVolThresh=50000;
vars.gaussFiltNuc=5; % width of gaussian filter used to smooth nuclei prior to segmentation
vars.gaussFiltC1=2; % width of gaussian filter used to smooth foci prior to segmentation
vars.gaussFiltC2=2; % width of gaussian filter used to smooth foci prior to segmentation

vars.scrsz = get(0,'ScreenSize');

% for export
vars.stamp=num2str(fix(clock)); % date and time 
vars.stamp(vars.stamp==' ') = '';%remove spaces

prompt = {'Nuclear Threshold (a.u.):','C1 threshold (a.u.):', 'C1 foci minimum volume (voxels)', 'C2 threshold (a.u.)', 'C2 foci minimum volume (voxels)'};
dlg_title = 'Segmentation variables';
num_lines = 1;
defaultans = {'0.6', '1.0', '30', '2.0', '25'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
vars.nucThreshScale=str2double(answer{1});%change sensitivity of threshold (roughly 0.5-2)
vars.thresholdScaleC1=str2double(answer{2});% minimum foci volume in voxels (smaller than this are removed)
vars.minFociVoxC1=str2double(answer{3});%change sensitivity of threshold (roughly 0.5-2)
vars.thresholdScaleC2=str2double(answer{4});% minimum foci volume in voxels (smaller than this are removed)
vars.minFociVoxC2=str2double(answer{5});%change sensitivity of threshold (roughly 0.5-2)

vars.removeEdge = questdlg('Remove edge cells?', ...
	'Edge removal', ...
	'Yes', 'No', 'Yes'); 

vars.rawDisp = questdlg('Display raw data?', ...
	'Raw data viewing', ...
	'Yes', 'No', 'No'); 

vars.segDisp = questdlg('Display segmentation?', ...
	'Segmentation viewing', ...
	'Yes', 'No', 'No'); 

vars.saveResults = questdlg('Save results as .xls?', ...
	'Saving results', ...
	'Yes', 'No', 'Yes'); 

vars.saveSeg = questdlg('Save segmentation as .tif?', ...
	'Saving segmentation', ...
	'Yes', 'No', 'No'); 

end

function saveResults(colocParam, C0files, stamp)
% warning('off', 'MATLAB:xlswrite:AddSheet');

% prep results
 resultsGen{3,1}='Image';
  resultsGen{2,2}='Cell';
 for image=1:length(C0files)
  resultsGen{image+3, 1}=C0files(image).name;
 end
 for cell=1:30
   resultsGen{2, cell+2}=cell;
 end
 results.nucVol=resultsGen;
 results.ch1Vol=resultsGen;
 results.ch2Vol=resultsGen;
 results.nucInt=resultsGen;
 results.ch1Int=resultsGen;
 results.ch2Int=resultsGen;
 results.rawOverlap=resultsGen;
 results.overlapNorm2nucVol=resultsGen;
 results.overlapNorm2ch1vol=resultsGen;
 results.overlapNorm2ch2vol=resultsGen;
 results.overlapNorm2nucInt=resultsGen;
 results.overlapNorm2ch1Int=resultsGen;
 results.overlapNorm2ch2Int=resultsGen;
 % added 15/12/2017
 results.numFocich1=resultsGen;
 results.numFocich2=resultsGen;
 results.fracCh1Nuc=resultsGen;
 results.fracCh2Nuc=resultsGen;
 results.Ch1notOverlap=resultsGen;
 results.Ch2notOverlap=resultsGen;
 
 results.nucVol{1,1}='Nuclear volume (voxels)';
 results.ch1Vol{1,1}='Ch1 total foci volume (voxels)';
 results.ch2Vol{1,1}='Ch2 total foci volume (voxels)';
 results.nucInt{1,1}='Mean nuclear DNA intensity (a.u.)';
 results.ch1Int{1,1}='Mean nuclear ch1 intensity (a.u.)';
 results.ch2Int{1,1}='Mean nuclear ch2 intensity (a.u.)';
 results.rawOverlap{1,1}='Raw ch1/ch2 colocalisation (a.u.)';
 results.overlapNorm2nucVol{1,1}='Ch1/ch2 colocalisation, normalised to nuclear volume (a.u.)';
 results.overlapNorm2ch1vol{1,1}='Ch1/ch2 colocalisation, normalised to ch1 total foci volume (a.u.)';
 results.overlapNorm2ch2vol{1,1}='Ch1/ch2 colocalisation, normalised to ch2 total foci volume (a.u.)';
 results.overlapNorm2nucInt{1,1}='Ch1/ch2 colocalisation, normalised to mean nuclear DNA intensity (a.u.)';
 results.overlapNorm2ch1Int{1,1}='Ch1/ch2 colocalisation, normalised to mean ch1 intensity (a.u.)';
 results.overlapNorm2ch2Int{1,1}='Ch1/ch2 colocalisation, normalised to mean ch2 intensity (a.u.)';
 % added 15/12/2017
 results.numFocich1{1,1}='Number of ch1 foci';
 results.numFocich2{1,1}='Number of ch2 foci';
 results.fracCh1Nuc{1,1}='Fraction of nucleus with ch1';
 results.fracCh2Nuc{1,1}='Fraction of nucleus with ch2';
 results.Ch1notOverlap{1,1}='Raw ch1 not colocalised';
 results.Ch2notOverlap{1,1}='Raw ch2 not colocalised';
 
% move results into cells for saving
filecount=0;
 for file=C0files' 
     filecount=filecount+1;
for cell=1:length(colocParam{1,filecount}.nucVol)
    results.nucVol{filecount+3,cell+2}=colocParam{1,filecount}.nucVol(cell);
    results.ch1Vol{filecount+3,cell+2}=colocParam{1,filecount}.ch1Vol(cell);
    results.ch2Vol{filecount+3,cell+2}=colocParam{1,filecount}.ch2Vol(cell);
    results.nucInt{filecount+3,cell+2}=colocParam{1,filecount}.nucInt(cell);
    results.ch1Int{filecount+3,cell+2}=colocParam{1,filecount}.ch1Int(cell);
    results.ch2Int{filecount+3,cell+2}=colocParam{1,filecount}.ch2Int(cell);
    results.rawOverlap{filecount+3,cell+2}=colocParam{1,filecount}.rawOverlap(cell);
    results.overlapNorm2nucVol{filecount+3,cell+2}=colocParam{1,filecount}.overlapNorm2nucVol(cell);
    results.overlapNorm2ch1vol{filecount+3,cell+2}=colocParam{1,filecount}.overlapNorm2ch1vol(cell);
    results.overlapNorm2ch2vol{filecount+3,cell+2}=colocParam{1,filecount}.overlapNorm2ch2vol(cell);
    results.overlapNorm2ch1Int{filecount+3,cell+2}=colocParam{1,filecount}.overlapNorm2ch1Int(cell);
    results.overlapNorm2ch2Int{filecount+3,cell+2}=colocParam{1,filecount}.overlapNorm2ch2Int(cell);
    % added 15/12/2017
    results.numFocich1{filecount+3,cell+2}=colocParam{1,filecount}.numFocich1(cell);
    results.numFocich2{filecount+3,cell+2}=colocParam{1,filecount}.numFocich2(cell);
    results.fracCh1Nuc{filecount+3,cell+2}=colocParam{1,filecount}.fracCh1Nuc(cell);
    results.fracCh2Nuc{filecount+3,cell+2}=colocParam{1,filecount}.fracCh2Nuc(cell);
    results.Ch1notOverlap{filecount+3,cell+2}=colocParam{1,filecount}.Ch1notOverlap(cell);
    results.Ch2notOverlap{filecount+3,cell+2}=colocParam{1,filecount}.Ch2notOverlap(cell);
end
 end


% write to disk
xlswrite(['Foci_analysis_' stamp], results.nucVol,1)
xlswrite(['Foci_analysis_' stamp], results.numFocich1,2) 
xlswrite(['Foci_analysis_' stamp], results.numFocich2,3) 
xlswrite(['Foci_analysis_' stamp], results.ch1Vol,4) 
xlswrite(['Foci_analysis_' stamp], results.ch2Vol,5) 
xlswrite(['Foci_analysis_' stamp], results.fracCh1Nuc,6) 
xlswrite(['Foci_analysis_' stamp], results.fracCh2Nuc,7) 
xlswrite(['Foci_analysis_' stamp], results.nucInt,8)
xlswrite(['Foci_analysis_' stamp], results.ch1Int,9) 
xlswrite(['Foci_analysis_' stamp], results.ch2Int,10)
xlswrite(['Foci_analysis_' stamp], results.rawOverlap,11) 
xlswrite(['Foci_analysis_' stamp], results.Ch1notOverlap,12) 
xlswrite(['Foci_analysis_' stamp], results.Ch2notOverlap,13) 
xlswrite(['Foci_analysis_' stamp], results.overlapNorm2nucVol,14) 
xlswrite(['Foci_analysis_' stamp], results.overlapNorm2ch1vol,15)
xlswrite(['Foci_analysis_' stamp], results.overlapNorm2ch2vol,16) 
xlswrite(['Foci_analysis_' stamp], results.overlapNorm2ch1Int,17) 
xlswrite(['Foci_analysis_' stamp], results.overlapNorm2ch2Int,18)
 end
 
function saveSegmentation(filename, C0seg, C1seg, C2seg, stamp)
    for frame=1:size(C0seg,3)
        outfileC0=['C0_seg_' stamp '_' filename];
        outfileC1=['C1_seg_' stamp '_'  filename];
        outfileC2=['C2_seg_' stamp '_'  filename];
        imwrite(C0seg(:,:,frame),outfileC0, 'tif', 'WriteMode', 'append', 'compression', 'none');
        imwrite(C1seg(:,:,frame),outfileC1, 'tif', 'WriteMode', 'append', 'compression', 'none');
        imwrite(C2seg(:,:,frame),outfileC2, 'tif', 'WriteMode', 'append', 'compression', 'none');
    end 
end
 
 