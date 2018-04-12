   function colocParam=analyseFociColoc(ch0, ch1, ch2, ch0seg, ch1seg, ch2seg)
%% Adam Tyson | 11/12/2017 | adam.tyson@icr.ac.uk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input:
% ch0 - raw image of nuclei
% ch1 & ch2 - raw image of other nuclear signal
% ch0seg - binary, segmented image of nuclei
% ch1seg & ch2seg - binary, segmented image of other nuclear signal

% output:
% colocParam - structure of cell by cell parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to do
% make n-channel 
% speed up - remove loops etc

%% prep
% make individual cell masks
connComp=bwlabeln(ch0seg); 
indvCellMasks=zeros(size(ch0seg));

for cell=1:max(connComp(:))
  temp=zeros(size(ch0seg));
  temp(connComp==cell)=1;
  indvCellMasks(:,:,:,cell)=temp;  
end

% make 4d arrays for each channel (raw and segmented), each 3D volume is one cell
indvCh1seg=repmat(ch1seg, 1,1,1, max(connComp(:)));
indvCh2seg=repmat(ch2seg, 1,1,1, max(connComp(:)));

indvCh0raw=repmat(ch0, 1,1,1, max(connComp(:)));
indvCh1raw=repmat(ch1, 1,1,1, max(connComp(:)));
indvCh2raw=repmat(ch2, 1,1,1, max(connComp(:)));

indvCh1seg=indvCh1seg.*indvCellMasks;
indvCh2seg=indvCh2seg.*indvCellMasks;

indvCh0raw=double(indvCh0raw).*double(indvCellMasks);
indvCh1raw=double(indvCh1raw).*double(indvCellMasks);
indvCh2raw=double(indvCh2raw).*double(indvCellMasks);

%%  cell by cell analysis 
for cell=1:max(connComp(:))
    
    % temp files for cell by cell analysis
    tmpcellBin=indvCellMasks(:,:,:,cell);
    tmpch1Bin=indvCh1seg(:,:,:,cell);
    tmpch2Bin=indvCh2seg(:,:,:,cell);

    tmpcellRaw=indvCh0raw(:,:,:,cell);
    tmpch1Raw=indvCh1raw(:,:,:,cell);
    tmpch2Raw=indvCh2raw(:,:,:,cell);
    
    % added 15/12/2017
    CCch1 = bwconncomp(tmpch1Bin);
    colocParam.numFocich1(cell)=CCch1.NumObjects;
    CCch2 = bwconncomp(tmpch2Bin);
    colocParam.numFocich2(cell)=CCch2.NumObjects;
    
    % binary vols
    colocParam.nucVol(cell)=sum(tmpcellBin(:));
    colocParam.ch1Vol(cell)=sum(tmpch1Bin(:));
    colocParam.ch2Vol(cell)=sum(tmpch2Bin(:));
    
    % added 15/12/2017
    colocParam.fracCh1Nuc(cell)=colocParam.ch1Vol(cell)/colocParam.nucVol(cell);
    colocParam.fracCh2Nuc(cell)=colocParam.ch2Vol(cell)/colocParam.nucVol(cell);
    
    % raw intensities
    colocParam.nucInt(cell)=mean(tmpcellRaw(:));
    colocParam.ch1Int(cell)=mean(tmpch1Raw(:));
    colocParam.ch2Int(cell)=mean(tmpch2Raw(:));
    
    tmp=indvCh1seg(:,:,:,cell).*indvCh2seg(:,:,:,cell);
    colocParam.rawOverlap(cell)=sum(tmp(:));
    
    % added 15/12/2017
    colocParam.Ch1notOverlap(cell)=colocParam.ch1Vol(cell)-colocParam.rawOverlap(cell);
    colocParam.Ch2notOverlap(cell)=colocParam.ch2Vol(cell)-colocParam.rawOverlap(cell);

    % normalise to binary volumes
    colocParam.overlapNorm2nucVol(cell)=colocParam.rawOverlap(cell)/colocParam.nucVol(cell);
    colocParam.overlapNorm2ch1vol(cell)=colocParam.rawOverlap(cell)/colocParam.ch1Vol(cell);
    colocParam.overlapNorm2ch2vol(cell)=colocParam.rawOverlap(cell)/colocParam.ch2Vol(cell);
    
    % normalise to raw intensities
    colocParam.overlapNorm2nucInt(cell)=colocParam.rawOverlap(cell)/colocParam.nucInt(cell);
    colocParam.overlapNorm2ch1Int(cell)=colocParam.rawOverlap(cell)/colocParam.ch1Int(cell);
    colocParam.overlapNorm2ch2Int(cell)=colocParam.rawOverlap(cell)/colocParam.ch2Int(cell);
    

end

end