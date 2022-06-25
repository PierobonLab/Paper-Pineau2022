function fm=imfill3(m)
fm=zeros(size(m));
for i=1:size(m,3)
    fm(:,:,i)=imfill(m(:,:,i),'holes');
end
