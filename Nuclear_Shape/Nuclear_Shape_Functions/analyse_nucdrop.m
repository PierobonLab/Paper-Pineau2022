%%  *****************************************************************
%  Copyright 2022 by Paolo Pierobon (CNRS, Institut Curie, PSL Research
%  University, INSERM U932, 26 rue d'Ulm, 75248 Paris, Cedex 05, France.)
%  Email: <pppierobon@gmail.com>
%  
%  Licensed under GNU General Public License 3.0 or later. 
%  Some rights reserved. See COPYING, AUTHORS.
%  @license GPL-3.0+ <http://spdx.org/licenses/GPL-3.0+>
%
%%  *****************************************************************



function data=analyse_nucdrop(nuclearSh, dropSh);

nTimes=min(length(nuclearSh), length(dropSh));
for t=2:nTimes
    % principal axis (first column of the rotation matrix exit in ellipsoid)
    pa=nuclearSh(t).eigvec(1:3,1);
    if (isnan(nuclearSh(t).vertexmin(1)))
        nuclearSh(t).vertexmin=[NaN NaN NaN];
    end
    t
    % vector nComDcom
    w=[dropSh(t).COM(1)-nuclearSh(t).COM(1), dropSh(t).COM(2)-nuclearSh(t).COM(2), dropSh(t).COM(3)-nuclearSh(t).COM(3)];
    data(t).vNucDrop=w;
    data(t).distNucDrop=norm(w);
    
    % vector indent-dCOMd=getAllDataMtocNuc(dir('*MTOC.txt'))
    v=[dropSh(t).COM(1)-nuclearSh(t).vertexmin(1),dropSh(t).COM(2)-nuclearSh(t).vertexmin(2), dropSh(t).COM(3)-nuclearSh(t).vertexmin(3)];
    data(t).vIndDrop=v;
    data(t).distIndDrop=norm(v);
    
    % vector nCOM-indent
    u=-[nuclearSh(t).COM(1)-nuclearSh(t).vertexmin(1),nuclearSh(t).COM(2)-nuclearSh(t).vertexmin(2), nuclearSh(t).COM(3)-nuclearSh(t).vertexmin(3)];
    data(t).vNucInd=u;
    data(t).distNucInd=norm(u);
    
    % angle indent-nCOM-dCOM
    data(t).angleIndCom=atan2d(norm(cross(u,w)),dot(u,w));
    
    % angle dCOM-nCOM-PA
    data(t).angleComPA=atan2d(norm(cross(w,pa)),dot(w,pa));
    
    % angle indent-nCOM-principal axis (this should say if the indentation has or not a random position)
    % this measure could suffer of the dz anysotropy
    data(t).angleIndPA=atan2d(norm(cross(u,pa)),dot(u,pa));
    
    
end

    