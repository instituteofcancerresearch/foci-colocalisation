function outIm=scaleIm(img, newMax)
% scales a 3D image between 0 and a supplied value (newMax)
%% Adam Tyson 11/11/2016 -- adamltyson@gmail.com

outIm=zeros(size(img));
 for z=1:size(img,3)
    temp=img(:,:,z);
     minVal=min(temp(:));
     maxVal=max(temp(:));
     outIm(:,:,z)=(img(:,:,z)-minVal)/(maxVal-minVal).*newMax;
 end
