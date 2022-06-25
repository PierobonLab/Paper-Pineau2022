function [elem,node]=N_MeshResample(f,v,keepratio)
%N_MeshResample is just a file wrapper on a meshresample from the iso2mesh
%               toolbox (See below) to maintain consistency in variable and
%               file naming.
%
% INPUT:
%   f         - matrix containing faces of the mesh surface
%   v         - matrix of containing vertices of the surface
%   keepratio - scalar less than 1 specifying fraction of elements after
%               resampling
%
% OUTPUT:
%   elem - matrix containing faces of the resampled mesh surface
%   node - matrix of containing vertices of the resampled surface
%
%---------------- Original File Content ----------------------------------%
% [node,elem]=meshresample(v,f,keepratio)
%
% resample mesh using CGAL mesh simplification utility
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/12
%
% input:
%    v: list of nodes
%    f: list of surface elements (each row for each triangle)
%    keepratio: decimation rate, a number less than 1, as the percentage
%               of the elements after the sampling
%
% output:
%    node: the node coordinates of the sampled surface mesh
%    elem: the element list of the sampled surface mesh
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

[node,elem]=domeshsimplify(v,f,keepratio);

% Commented as our isosurface mesh has not topological defects (Matlab's
% Output)
% if(length(node)==0)
%     warning(['Your input mesh contains topological defects, and the ',...
%            'mesh resampling utility aborted during processing. Now iso2mesh ',...
%            'is trying to repair your mesh with meshcheckrepair. ',...
%            'You can also call this manually before passing your mesh to meshresample.'] );
%     [vnew,fnew]=meshcheckrepair(v,f);
%     [node,elem]=domeshsimplify(vnew,fnew,keepratio);
% end

[node,I,J]=unique(node,'rows');
elem=J(elem);
saveoff(node,elem,mwpath('post_remesh.off'));

end

% Internal functions

function exesuff=getexeext()
%
% exesuff=getexeext()
%
% get meshing external tool extension names for the current platform
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
%
% output:
%     exesuff: file extension for iso2mesh tool binaries
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

exesuff='.exe';
if(isunix) 
	exesuff=['.',mexext];
end
if(isoctavemesh)
   if(~ispc)
      if(~ismac)
	   if(isempty(regexp(computer,'86_64')))
	      exesuff='.mexglx';
	   else
              exesuff='.mexa64';
	   end
      else
           if(isempty(regexp(computer,'86_64')))
              exesuff='.mexmaci';
           else
              exesuff='.mexmaci64';
           end
      end
   else
      exesuff='.exe';
   end
end
end
function p=getvarfrom(ws,name)
%
% p=getvarfrom(ws,name)
%
% get variable value by name from specified work-space
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
%
% input:
%    ws: name of the work-space, for example, 'base'
%    name: name string of the variable
%
% output:
%    p: the value of the specified variable, if the variable does not
%       exist, return empty array
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

wsname=ws;
if(~iscell(ws))
   wsname=cell(1);
   wsname{1}=ws;
end

p=[];
for i=1:length(wsname)
    isdefined=evalin(wsname{i},['exist(''' name ''')']);
    if(isdefined==1)
        p=evalin(wsname{i},name);
        break;
    end
end
end
function binname=mcpath(fname)
%
% binname=mcpath(fname)
%
% get full executable path by prepending a command directory path
% parameters:
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
%
% input:
%    fname: input, a file name string
%
% output:
%    binname: output, full file name located in the bin directory
%
%    if global variable ISO2MESH_BIN is set in 'base', it will
%    use [ISO2MESH_BIN filesep cmdname] as the command full path,
%    otherwise, let matlab pass the cmdname to the shell, which
%    will search command in the directories listed in system
%    $PATH variable.
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

p=getvarfrom({'caller','base'},'ISO2MESH_BIN');
binname=[];
if(isempty(p))
	% the bin folder under iso2mesh is searched first
	tempname=[fileparts(which(mfilename)) filesep 'bin' filesep fname];
	if(exist([fileparts(which(mfilename)) filesep 'bin'])==7)
		binname=tempname;
	else
		binname=fname;
	end
else
	binname=[p filesep fname];
end

end

function exesuff=fallbackexeext(exesuffix, exename)
%
% exesuff=fallbackexeext(exesuffix, exename)
%
% get the fallback external tool extension names for the current platform
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
%
% input:
%     exesuffix: the output executable suffix from getexeext
%     exename: the executable name
%
% output:
%     exesuff: file extension for iso2mesh tool binaries
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

exesuff=exesuffix;
if(strcmp(exesuff,'.mexa64') & exist([mcpath(exename) exesuff],'file')==0) % fall back to i386 linux
        exesuff='.mexglx';
	return;
end
if(strcmp(exesuff,'.mexmaci64') & exist([mcpath(exename) exesuff],'file')==0) % fall back to i386 mac
        exesuff='.mexmaci';
end
if(strcmp(exesuff,'.mexmaci') & exist([mcpath(exename) exesuff],'file')==0) % fall back to ppc mac
        exesuff='.mexmac';
end

end

function [isoctave verinfo]=isoctavemesh
%
% [isoctave verinfo]=isoctavemesh
%
% determine whether the code is running in octave
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
%
% output:
%   isoctave: 1 if in octave, otherwise 0
%   verinfo: a string, showing the version of octave (OCTAVE_VERSION)
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%
verinfo='';
isoctave=(exist('OCTAVE_VERSION')~=0);
if(nargout==2 && isoctave)
    verinfo=OCTAVE_VERSION;
end
end
function tempname=mwpath(fname)
%
% tempname=meshtemppath(fname)
%
% get full temp-file name by prepend working-directory and current session name
%
% author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%
% input:
%    fname: input, a file name string
%
% output:
%    tempname: output, full file name located in the working directory
%
%    if global variable ISO2MESH_TEMP is set in 'base', it will use it
%    as the working directory; otherwise, will use matlab function tempdir
%    to return a working directory.
%
%    if global variable ISO2MESH_SESSION is set in 'base', it will be
%    prepended for each file name, otherwise, use supplied file name.
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

p=getvarfrom({'caller','base'},'ISO2MESH_TEMP');
session=getvarfrom({'caller','base'},'ISO2MESH_SESSION');

username=getenv('USER'); % for Linux/Unix/Mac OS

if(isempty(username))
   username=getenv('UserName'); % for windows
end

if(~isempty(username))
   username=['iso2mesh-' username];
end

tempname=[];
if(isempty(p))
      if(isoctavemesh & tempdir=='\')
		tempname=['.'  filesep session fname];
	else
		tdir=tempdir;
		if(tdir(end)~=filesep)
			tdir=[tdir filesep];
		end
		if(~isempty(username))
                    tdir=[tdir username filesep];
                    if(exist(tdir)==0) mkdir(tdir); end
        end
        if(nargin==0)
            tempname=tdir;
        else
            tempname=[tdir session fname];
        end
	end
else
	tempname=[p filesep session fname];
end
end
function saveoff(v,f,fname)
%
% saveoff(v,f,fname)
%
% save a surface mesh to Geomview Object File Format (OFF)
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/03/28
%
% input:
%      v: input, surface node list, dimension (nn,3)
%      f: input, surface face element list, dimension (be,3)
%      fname: output file name
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

fid=fopen(fname,'wt');
if(fid==-1)
    error('You do not have permission to save mesh files.');
end
fprintf(fid,'OFF\n');
fprintf(fid,'%d\t%d\t%d\n',length(v),length(f),0);
fprintf(fid,'%f\t%f\t%f\n',v');
face=[size(f,2)*ones(size(f,1),1) f-1];
format=[repmat('%d\t',1,size(face,2)-1) '%d\n'];
fprintf(fid,format,face');
fclose(fid);

end

function flag=deletemeshfile(fname)
%
% flag=deletemeshfile(fname)
%
% delete a given work mesh file under the working directory
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
%
% input: 
%     fname: specified file name (without path)
%
% output:
%     flag: not used
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

try
    if(exist(fname)) 
	delete(fname); 
    end
catch
    error(['You do not have permission to delete temporary files. If you are working in a multi-user ',...
         'environment, such as Unix/Linux and there are other users using iso2mesh, ',...
         'you may need to define ISO2MESH_SESSION=''yourstring'' to make your output ',...
         'files different from others; if you do not have permission to ',mwpath(''),...
         ' as the temporary directory, you have to define ISO2MESH_TEMP=''/path/you/have/write/permission'' ',...
         'in matlab/octave base workspace.']);
end

end

function [node,elem]=readoff(fname)
%
% [node,elem]=readoff(fname)
%
% read Geomview Object File Format (OFF)
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% date: 2008/03/28
%
% input:
%    fname: name of the OFF data file
%
% output:
%    node: node coordinates of the mesh
%    elem: list of elements of the mesh	    
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

node=[];
elem=[];
fid=fopen(fname,'rt');
line=fgetl(fid);
dim=sscanf(line,'OFF %d %d %d');
line=nonemptyline(fid);
if(size(dim,1)~=3)
    dim=sscanf(line,'%d',3);
    line=nonemptyline(fid);
end
nodalcount=3;
if(~isempty(line))
    [val nodalcount]=sscanf(line,'%f',inf);
else
    fclose(fid);
    return;
end
node=fscanf(fid,'%f',[nodalcount,dim(1)-1])';
node=[val(:)';node];

line=nonemptyline(fid);
facetcount=4;
if(~isempty(line))
    [val facetcount]=sscanf(line,'%f',inf);
else
    fclose(fid);
    return;
end
elem=fscanf(fid,'%f',[facetcount,dim(2)-1])';
elem=[val(:)';elem];
fclose(fid);
elem(:,1)=[];

if(size(elem,2)<=3)
    elem(:,1:3)=round(elem(:,1:3))+1;
else
    elem(:,1:4)=round(elem(:,1:4))+1;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str=nonemptyline(fid)
str='';
if(fid==0) error('invalid file'); end
while((isempty(regexp(str,'\S')) || ~isempty(regexp(str,'^#')))  && ~feof(fid))
    str=fgetl(fid);
    if(~ischar(str))
        str='';
        return;
    end
end
end
% function to perform the actual resampling
function [node,elem]=domeshsimplify(v,f,keepratio)
  exesuff=getexeext;
  exesuff=fallbackexeext(exesuff,'cgalsimp2');

  saveoff(v,f,mwpath('pre_remesh.off'));
  deletemeshfile(mwpath('post_remesh.off'));
  system([' "' mcpath('cgalsimp2') exesuff '" "' mwpath('pre_remesh.off') '" ' num2str(keepratio) ' "' mwpath('post_remesh.off') '"']);
  [node,elem]=readoff(mwpath('post_remesh.off'));
end
