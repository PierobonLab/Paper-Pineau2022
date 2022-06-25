% curvonlplan: fit the interpolating plan to a set of 3D points (that might
% define a curve)
% Use SVD to return
% - vperp: unitary vector perpendicular to the plane
% - vtrans: vector that translates the plan (if no origin is given the linear manifold pass through th origin
% - rs: vector of the sum of square residues (projectred on the vperp direction); useful
% to compurt a sort of correlaction coefficient, it is importnat to have it
% as vecor to consider residues in different portion of the curve.


function [vperp, vtrans, sr ]=curveonplan(x,y,z, x0, y0, z0)

m=[x(:), y(:), z(:)]';

if nargin<=3
    vtrans=mean(m,2);
else
    vtrans=[x0,y0,z0]';
end
vperp=svdfit(m, vtrans);


% residual sum of square
sr=sum((m-vtrans).*repmat(vperp,[1, size(m,2)]),1).^2;


end

function vperp=svdfit(m, vtrans)
A=(m-vtrans);
[U,S,V] = svd(A);
vperp=U(:,3);
end

