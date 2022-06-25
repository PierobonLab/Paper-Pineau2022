%% h=patch_indent_movie(shape, fvname, colorfield, domovie, dropSh)
% Plot the movie of the surface defined by 'fvname' and colored according
% to 'colorfield'
% Ex: patch_indent_movie(shape, 'fv1', 'Cmean')
%
%
% Inputs:
% shape: shape structure defined by nuclear_shape_movie
% fvname: string of the field name to plot, must correspond to an fv structure
% colorfield: string of the field name use to color the mesh (must be a
% vector of the size size(vertices)
% domovie: produce the corresponding avi file
% Output:
%     h: handle to the graph


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
function patch_indent_movie(shape, fvname, colorfield, domovie, dropSh);

% determine max min
ctot=extract_field(shape,colorfield);
cmin=nanmean(ctot)-1.50*nanstd(ctot);
cmax=nanmean(ctot)+1.70*nanstd(ctot);
% caxis([cmin cmax]/10);
xmax=shape(10).COM(1)*2;
ymax=shape(10).COM(2)*2;
zmax=shape(10).COM(3)*2;

if (nargin==5)
    COMdrop=[dropSh.COM];
    xDrop=COMdrop(1:3:end);
    yDrop=COMdrop(2:3:end);
    zDrop=COMdrop(3:3:end);
    
    % create sphere
    [x,y,z]=sphere(40);
    
    % figure
    
    for i=2:length(shape)
        fv=getfield(shape(i), fvname);
        c=getfield(shape(i), colorfield);
       % p=shape(i).corrvertexmin;
        p=shape(i).vertexmin;

        if ~isnan(c)
            p1=patch(fv,'FaceColor','interp','FaceVertexCData',c,'edgecolor','none');
          % alpha(p1,0.5); % transparency
            %view(3);
            % orientation along bead COM axis
            %        [th ph]=cart2sph(p(1), p(2), p(3));
            
            %v=[shape(i).COM(1)-xDrop(i), shape(i).COM(2)-yDrop(i), shape(i).COM(3)-zDrop(i)];
            %[th ph]=cart2sph(v(1), v(2), v(3));
            %view(rad2deg([th ph])+[0 -0]);
            view(30,30);
            colormap jet;
            caxis([cmin cmax]);
            grid on;
            colorbar;
            hold on
            plot3(p(1), p(2), p(3),'*g')
            
            
            %        drawnow;
            
            daspect([1 1 1]);
            
            %%% add drop
            if (nargin==5)
                hold on;
                %X=x+xDrop(i); Y=y+yDrop(i); Z=z+zDrop(i);
                [X,Y,Z]=drawEllipsoid(dropSh(i).ellipsoide);
                surf(X,Y,Z,'edgecolor','none','facecolor', 'g')
              %  alpha(0.5)
               camlight('right')
            end
                camlight; lighting gouraud;
       
            % %%%%%% determine axis
            xlim([0 xmax]); ylim([0 ymax]); zlim([0 zmax]);
            %        xlim([10 90]); ylim([20 70]); zlim([0 40]);
            %         axis tight
            title([colorfield ' t=',num2str(floor(i*0.5)), ' min']);
            frame(i)=getframe(gcf);
            pause(0.01);
            
            cla;
        end
    end
    
    if ((nargin>3) & domovie)
        frameclean=frame;
        for i=1:length(frame)
            if isempty(frame(i).cdata)
                frameclean(i)=[];
            end
        end
        transfermovie(frameclean, 'shape_movie_bead.avi');
    end
    
end
end




function [f nf]=extract_field(s,fname)
for i=1:length(s)
    tmp=getfield(s(i),fname);
    f{i}=tmp;
    
end
nf=length(s);
f=cell2mat(f(:));
end

function transfermovie(frame, fileOut)
writerObj = VideoWriter(fileOut, 'Uncompressed AVI');
open(writerObj);
for i=1:length(frame)
    sz1(i)=size(frame(i).cdata,1);
    sz2(i)=size(frame(i).cdata,2);
end
msz1=min(sz1);
msz2=min(sz2);
for i=1:length(frame)
    frame(i).cdata=frame(i).cdata(1:msz1,1:msz2,:);
    writeVideo(writerObj,frame(i));
end
close(writerObj);
end

