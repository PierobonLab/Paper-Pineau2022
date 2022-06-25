% compute the rotation matrix that take a vector v to the vector w (and
% threfore the plane perpendicular to v onto the plane perpendicular to w).

function rotmat=rotMatrixAxis (v,w)
v=v(:);
w=w(:);
rotaxis = cross(v, w)/norm(cross(v, w));

c = dot(v,w)/(norm(v)*norm(w));
s=sqrt(1-c*c);
C=1-c;

x=rotaxis(1);
y=rotaxis(2);
z=rotaxis(3);

rotmat= [x*x*C+c    x*y*C-z*s  x*z*C+y*s;...
         y*x*C+z*s  y*y*C+c    y*z*C-x*s;...
         z*x*C-y*s  z*y*C+x*s  z*z*C+c];

