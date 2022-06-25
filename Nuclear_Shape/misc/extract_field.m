% function extract all values from a field in a single concatenated vector
function [f nf]=extract_field(s,fname)
for i=1:length(s)
    tmp=getfield(s(i),fname);
    if isempty(tmp)
        tmp=NaN;
    end
    f{i}=tmp;
    
end
nf=length(s);
f=cell2mat(f(:));
end
