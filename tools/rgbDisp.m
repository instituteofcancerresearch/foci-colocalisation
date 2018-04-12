function rgbDisp(ch1, ch2, ch3, screenSize, figTitle)

rgb=cat(4, ch1, ch2, ch3);
figure('position', screenSize,'Name',figTitle)
imshow3D(rgb) % call function to display (needs to be newest version, which accepts RGB as well as greyscale)
end