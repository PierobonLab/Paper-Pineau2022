function m=structfield2matrix(s,fname,ll)
for i=1:length(s)
    i
    tmp=getfield(s(i),fname);
    f{i}=tmp(:);    
    ll(i)=length(tmp);
end
m=nan(max(ll),length(s))
for i=1:length(s)
    m(1:length(f{i}),i)=f{i};
end
