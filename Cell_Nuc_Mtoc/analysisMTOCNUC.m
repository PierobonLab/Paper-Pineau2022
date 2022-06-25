%% analyse MTOC trajectories
% for each trajectory:
% * clean data
% * recenter everthing to the bead center
% * align bead and cell centers
% * analyse MTOC traj:
%     - polar coordinates
%     - timescales
%     - complanarity/spiral?
%     - angular change
%     -
% * sanity check:
%     - cell volume is constant
%     - axis cell-beads does not move too much
%
% NB version 12/9/21 does not consider nuclear orientation, this is solved
% by nucShape if needed

function data=analysisMTOCNUC(data, nucanalysis);
for i=1:length(data)
    % get x,y,z from data for everything and correct nan
    
    
    ldata=min([length(data(i).x1), length(data(i).xDrop), length(data(i).Xcen)]);
    px=[0.325, 0.325, 0.325];% for MTOC taken from interpolated data!! check!
    vBead=[data(i).xDrop(2:ldata), data(i).yDrop(2:ldata), data(i).zDrop(2:ldata)].*px;
    vCell0=[data(i).x0(2:ldata), data(i).y0(2:ldata), data(i).z0(2:ldata)].*px;
    vCell1=[data(i).x1(2:ldata), data(i).y1(2:ldata), data(i).z1(2:ldata)].*px;
    
    % clean MTOC data (get rid of first point nan)
         nancen=find(isnan(data(i).Xcen));
    
    % if a nan is found replace it with previous number
          if (~isempty(nancen))
              for t=nancen
                data(i).Xcen(t)=data(i).Xcen(t-1);
                data(i).Ycen(t)=data(i).Ycen(t-1);
                data(i).Zcen(t)=data(i).Zcen(t-1);
                data(i).MeanDist(t)=data(i).MeanDist(t-1);
              end
          end
    
    vMtoc=[data(i).Xcen(2:ldata), data(i).Ycen(2:ldata), data(i).Zcen(2:ldata)].*px;
    d=data(i).MeanDist;
    
    
    
    % correct translation beads:
    vBeadCorr=correct_outlayers(vBead); % correct PUNCTUAL problems in bead detection
    vMtocTr=vMtoc-vBeadCorr;    % referenced to the bead
    vCell1Tr=vCell1-vBeadCorr;  % referenced to the bead
    dMtocBead=sqrt(vMtocTr(:,1).^2+vMtocTr(:,2).^2+vMtocTr(:,3).^2);
    
    % spherical coord of cell wrt the bead
    [thC phiC rC]= cart2sph(vCell1Tr(:,1),vCell1Tr(:,2),vCell1Tr(:,3));
    phiC=unwrap(phiC);
    thC=unwrap(thC);
    
    
    % to compute the spherical coord of MTOC wrt the cell in a meaningful
    % way one needs first to align the COMcell to the COMbead and then the
    % traj plane to the XY plan. In this way possibly phi(t)=0 and theta(end)=0 as the
    % synapse will lay on the x axi
    % For the rotation use the angle/axis matrix define in RotMatrixAxix
    
    % define the average position of the cell and the vector defining it wrt to the bead (drift corrected)
    vCellTrAvg=mean(vCell1Tr,1);
    
    % define vectors wrt the cell COM:
    CB=-vCellTrAvg;
    CM=vMtocTr-vCellTrAvg;
    
    % rotation matrix that brings the CellCOM-BeadCOM to the x axis
    m1=rotMatrixAxis(CB, [1, 0 ,0]);
    
    % compute the new traj:
    CM1=(m1*CM')';
    
    % find plane of the whole curve (through the origin i.e. the cell avg
    % position)
    [vperp, vtrans, residues ]=curveonplan(CM1(:,1), CM1(:,2), CM1(:,3),0,0,0);
    
    CB1=(m1*CB')';
    
    
    % rotation matrix that brings the traj plane on the XY plane
    m2=rotMatrixAxis(vperp, [0,0,1]);
    CM2=(m2*CM1')';
    
    % NOW get the spherical coordinates
    [thM phiM rM]= cart2sph(CM2(:,1), CM2(:,2), CM2(:,3));
    thM=wrapToPi(unwrap(thM));
    phiM=wrapToPi(unwrap(phiM));
    
    % get angle mtoc-COM-bead
    for k=1:size(vCell1Tr,1)
        u=vMtocTr(k,:)-vCell1Tr(k,:);
        w=-vCell1Tr(k,:);
        thVector(k)=atan2d(norm(cross(u,w)),dot(u,w));
        rV(k)=norm(u);
    end
    
    
    
    % single vector distance
    m=vMtocTr;
    dm=diff(m);
    dr=sqrt(sum(dm.^2,2));
    
    % angle between consecutive vectors
    for j=1:(size(dm,1)-1)
        angle(j)=acos((dm(j,:)*dm(j+1,:)')/(norm(dm(j,:))*norm(dm(j+1,:))));
    end
    
    
    %% orientation plan
    % get approach time (threshold 1µm)
    tau=find(thM<0.3,1)-1;
    if (tau>3)
        % compute the correlation angle speed on the linear part
        rtheta=corr(thM(1:tau), diff(thM(1:tau+1)));
        rdist=corr(d(1:tau), diff(d(1:tau+1)));
    else
        tau=ldata;
        rtheta=corr(thM(1:end-1), diff(thM));
        rdist=corr(d(1:end-1), diff(d));
    end
    
    %% nuclear quantities
    if nucanalysis
        % distance to nucleus center
        vNuc=[data(i).xNuc(2:ldata), data(i).yNuc(2:ldata), data(i).zNuc(2:ldata)].*px;
        vNucTr=vNuc-vBeadCorr;
        vNucMtoc=vNuc-vMtoc;
        vNucCell=vNuc-vCell1;
        
        [thN phiN rN]= cart2sph(vNucTr(:,1),vNucTr(:,2),vNucTr(:,3));
        phiN=unwrap(phiN);
        thN=unwrap(thN);
        [dum1 dum2 dNucMtoc]= cart2sph(vNucMtoc(:,1),vNucMtoc(:,2),vNucMtoc(:,3));
        [dum1 dum2 dNucCell]= cart2sph(vNucCell(:,1),vNucCell(:,2),vNucCell(:,3));
        
        % distance nucleus droplet
         distNucSurfDrop=compute_distSurfDrop(data(i).dropSh, data(i).nucSh);

        
        %% orientation nucleus
        % this part is useless as it is correctly done with the software
        % NucShape based on nuclear indendation and is therefore replaced by
        % that
        
        %     vOrNuc= data(i).R1Nuc.*cos(pi/180*([data(i).XY0Nuc, data(i).XZ0Nuc, data(i).YZ0Nuc]));
        %     vOrNuc=vOrNuc(2:ldata,:);
        %     for k=1:size(vOrNuc,1)
        %         u=vOrNuc(k,:);
        %         w=vNucTr(k,:);
        %         thNuc(k)=atan2d(norm(cross(u,w)),dot(u,w));
        %     end
        %
        %% using NucSh information and correctvertex
        % nuclear COM cell (NB the voxesl is now ISOTROPIC on this set of data!
        % nb: vector have to be referred to the bead center
        %  The vector center is well computed in this case, no need for the
        %  nucSh calculation
        %      % compute real coordintate of indentation
        
        tmp=structfield2matrix(data(i).nucSh, 'corrvertexmin');
        vInd=([tmp(1,2:ldata); tmp(2,2:ldata); tmp(3,2:ldata)].*px')';
        vIndTr=vInd-vBeadCorr;
        vIndCell=vInd-vCell1;
        vIndMTOC=vInd-vMtoc;
        for t=1:length(vIndCell)
            w=-vCell1Tr(t,:);
            u=vIndCell(t,:);
            wm=vIndMTOC(t,:);
            distIndCell(t)=norm(u);
            distIndMTOC(t)=norm(wm);
            angleIndCom2(t)=atan2d(norm(cross(u,w)),dot(u,w));
        end
    else
        dNucCell=nan;
        dNucMtoc=nan;
        angleIndCom2=nan;
        distIndCell=nan;
        distIndMTOC=nan;
        data(i).distIndDrop=nan;
        data(i).distNucDrop=nan;
        data(i).distNucInd=nan;
        distNucSurfDrop=nan;
   
    end
    
    % save all results
    data(i).vBeadCorr=vBeadCorr;
    data(i).vCellTr=vCell1Tr;
    data(i).vCellTrAvg=vCellTrAvg;
    data(i).vMtocTr=vMtocTr;
    data(i).thC=thC;
    data(i).phiC=phiC;
    data(i).rC=rC;
    data(i).thM=thM;
    data(i).phiM=phiM;
    data(i).rM=rM;
    data(i).thV=thVector;
    data(i).rV=rV;
    data(i).CM=CM2;
    data(i).CB=CB1;
    data(i).rtheta=rtheta;
    data(i).rdist=rdist;
    data(i).vperp=vperp;
    data(i).vtrans=vtrans;
    data(i).residues=residues;
    data(i).dr=dr;
    data(i).angle=angle;
    data(i).tau=tau;
    data(i).rtheta=rtheta;
    data(i).rdist=rdist;
    %
    data(i).dNucCell=dNucCell;
    data(i).dNucMtoc=dNucMtoc;
    data(i).dMtocBead=dMtocBead;
    data(i).distNucSurfDrop=distNucSurfDrop;
    %
    % data(i).vOrNuc=vOrNuc;
    % data(i).thNuc=thNuc;
    data(i).angleIndCom2=angleIndCom2;
    data(i).distIndCell=distIndCell;
    data(i).distIndMTOC=distIndMTOC;
    if ((~isfield(data(i), 'flagdone')) || isempty(data(i).flagdone) || (data(i).flagdone==0))% check if the scale has not already been applied
        data(i).distIndDrop=data(i).distIndDrop*px(1);
        data(i).distNucDrop=data(i).distNucDrop*px(1);
        data(i).distNucInd=data(i).distNucInd*px(1);
        data(i).MeanDist=data(i).MeanDist*px(1);
        data(i).distNucSurfDrop=data(i).distNucSurfDrop*px(1);
        data(i).flagdone=1;
    end
    i
end
%
end

function distNucSurfDrop=compute_distSurfDrop(dropSh, nucSh);
   distNucSurfDrop=zeros(size(dropSh));
   for t=2:length(dropSh)     
        img = discreteEllipsoid(1:120, 1:120, 1:120, dropSh(t).ellipsoide);
        s = isosurface(img,0.5); % estract isosurface (in vertex/faces form)
        p=nucSh(t).COM;
        distNucSurfDrop(t) = dist_point_droplet(p, s);
        p=nucSh(t).corrvertexmin;
        distIndSurfDrop(t) = dist_point_droplet(p, s);
       
    end
end

function d=dist_point_droplet(p, s)
d=sqrt(min(sum((p-s.vertices).^2,2)));
end



%
% % figure
% n=1;
% plot3(data(n).x,data(n).y,data(n).z)
% grid on
% hold on
% plot3(data(n).syn(1),data(n).syn(2),data(n).syn(3),'*')
% [xx,yy]=meshgrid(data(n).x(1:end), data(n).y(1:end));
% surf(xx,yy,(-data(n).vperp(1)*(xx-data(n).vtrans(1))-data(n).vperp(2)*(yy-data(n).vtrans(2)))/data(n).vperp(3)+data(n).vtrans(3),'edgecolor','non','facecolor', 'g'); alpha 0.5
% [xx,yy]=meshgrid(data(n).x(1:data(n).tau), data(n).y(1:data(n).tau));
% surf(xx,yy,(-data(n).vperp1(1)*(xx-data(n).vtrans1(1))-data(n).vperp1(2)*(yy-data(n).vtrans1(2)))/data(n).vperp1(3)+data(n).vtrans1(3),'edgecolor','non','facecolor', 'r'); alpha 0.5
% surf(xx,yy,(-data(n).vperp2(1)*(xx-data(n).vtrans2(1))-data(n).vperp2(2)*(yy-data(n).vtrans2(2)))/data(n).vperp2(3)+data(n).vtrans2(3),'edgecolor','non','facecolor', 'b'); alpha 0.5
