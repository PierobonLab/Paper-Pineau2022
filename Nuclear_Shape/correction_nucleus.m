% NB this function correct the vertex in nucSh and several distances (that
% might be computed wronly 

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
function s=correction_nucleus(s)
for i=1:length(s)
    i
    
   s(i).nucSh=correct_ind(s(i).nucSh, 'fv2');
% 
%  
     if ~isfield(s(i).nucSh(10), 'corrvertexmin')
        for j=1:length(s(i).nucSh)
            s(i).nucSh(j).corrvertexmin=s(i).nucSh(j).vertexmin;
        end
    end    
% %    
    [s(i).comp, s(i).distNucDrop, s(i).distIndDrop, s(i).distNucInd,...
    s(i).angleIndCom, s(i).angleComPA, s(i).angleIndPA]=local_analyse_nucdrop(s(i).nucSh, s(i).dropSh);
    
    s(i).rough_dist=extract_field(s(i).nucSh,'rough_dist');
    s(i).rough_Cgauss=extract_field(s(i).nucSh,'rough_Cgauss');
    s(i).rough_Cmean=extract_field(s(i).nucSh,'rough_Cmean');
    
%    end
end
end


function [comp, distNucDrop, distIndDrop, distNucInd, angleIndCom, angleComPA, angleIndPA]=local_analyse_nucdrop(nuclearSh, dropSh);

nTimes=min(length(nuclearSh), length(dropSh));
for t=2:nTimes
    % principal axis (first column of the rotation matrix exit in ellipsoid)
    pa=nuclearSh(t).eigvec(1:3,1);
    if (isnan(nuclearSh(t).corrvertexmin(1)))
        nuclearSh(t).corrvertexmin=[NaN NaN NaN];
    end
    
    % vector nComDcom
    w=[dropSh(t).COM(1)-nuclearSh(t).COM(1), dropSh(t).COM(2)-nuclearSh(t).COM(2), dropSh(t).COM(3)-nuclearSh(t).COM(3)];
    comp(t).vNucDrop=w;
    distNucDrop(t)=norm(w);
    
    % vector indent-dCOM
    v=[dropSh(t).COM(1)-nuclearSh(t).corrvertexmin(1),dropSh(t).COM(2)-nuclearSh(t).corrvertexmin(2), dropSh(t).COM(3)-nuclearSh(t).corrvertexmin(3)];
    comp(t).vIndDrop=v;
    distIndDrop(t)=norm(v);
    
    % vector nCOM-indent
    u=-[nuclearSh(t).COM(1)-nuclearSh(t).corrvertexmin(1),nuclearSh(t).COM(2)-nuclearSh(t).corrvertexmin(2), nuclearSh(t).COM(3)-nuclearSh(t).corrvertexmin(3)];
    comp(t).vNucInd=u;
    distNucInd(t)=norm(u);
    
    % angle indent-nCOM-dCOM
   angleIndCom(t)=atan2d(norm(cross(u,w)),dot(u,w));
    
    % angle dCOM-nCOM-PA
   angleComPA(t)=atan2d(norm(cross(w,pa)),dot(w,pa));
    
    % angle indent-nCOM-principal axis (this should say if the indentation has or not a random position)
    % this measure could suffer of the dz anysotropy
   angleIndPA(t)=atan2d(norm(cross(u,pa)),dot(u,pa));
    
    %% introduce ag aggregation here
    
end


end

    

function [comp, distNucDrop, distIndDrop, distNucInd, angleIndCom, angleComPA, angleIndPA]=local_analyse_nucdrop2(nuclearSh, dropSh);

nTimes=min(length(nuclearSh), length(dropSh));
for t=2:nTimes
    % principal axis (first column of the rotation matrix exit in ellipsoid)
    pa=nuclearSh(t).eigvec(1:3,1);
    if (isnan(nuclearSh(t).corrvertexmin(1)))
        nuclearSh(t).corrvertexmin=[NaN NaN NaN];
    end
    
    % vector nComDcom
    w=[dropSh(t).COM(1)-nuclearSh(t).COM(1), dropSh(t).COM(2)-nuclearSh(t).COM(2), dropSh(t).COM(3)-nuclearSh(t).COM(3)];
    comp(t).vNucDrop=w;
    distNucDrop(t)=norm(w);
    
    % vector indent-dCOM
    v=[dropSh(t).COM(1)-nuclearSh(t).corrvertexmin(1),dropSh(t).COM(2)-nuclearSh(t).corrvertexmin(2), dropSh(t).COM(3)-nuclearSh(t).corrvertexmin(3)];
    comp(t).vIndDrop=v;
    distIndDrop(t)=norm(v);
                                           
    % vector nCOM-indent
    u=-[nuclearSh(t).COM(1)-nuclearSh(t).corrvertexmin(1),nuclearSh(t).COM(2)-nuclearSh(t).corrvertexmin(2), nuclearSh(t).COM(3)-nuclearSh(t).corrvertexmin(3)];
    comp(t).vNucInd=u;
    distNucInd(t)=norm(u);
    
    % angle indent-nCOM-dCOM
   angleIndCom(t)=atan2d(norm(cross(u,w)),dot(u,w));
    
    % angle dCOM-nCOM-PA
   angleComPA(t)=atan2d(norm(cross(w,pa)),dot(w,pa));
    
    % angle indent-nCOM-principal axis (this should say if the indentation has or not a random position)
    % this measure could suffer of the dz anysotropy
   angleIndPA(t)=atan2d(norm(cross(u,pa)),dot(u,pa));
    
   %% reference nuclear system to the center of the cell system:
   % vector cellCOM indent
    u=-[nuclearSh(t).COM(1)-nuclearSh(t).corrvertexmin(1),nuclearSh(t).COM(2)-nuclearSh(t).corrvertexmin(2), nuclearSh(t).COM(3)-nuclearSh(t).corrvertexmin(3)];
   
   
    %% introduce ag aggregation here
    
end


end

