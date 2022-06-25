function  mask=importTIF(filename);
    nFrames=length(imfinfo(filename));
    for i=1:nFrames
        mask(:,:,i)=imread(filename,i);
    end
end