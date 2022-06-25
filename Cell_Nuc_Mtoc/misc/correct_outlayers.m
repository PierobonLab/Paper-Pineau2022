function v=correct_outlayers(v)
dnorm=@(m) sqrt(sum(m.^2, 2));
diff_vect= dnorm(diff(v));
cpt=find(diff_vect>3*mean(dnorm(diff(v))))+1;
if ~isempty(cpt)
    for k=1:2:length(cpt)
        v(cpt(k),:)=v(cpt(k)-1,:);
    end
end
        
