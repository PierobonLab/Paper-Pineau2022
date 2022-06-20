// Uses segmented synapses in 3Dfrom segment_synapse.ijm to rotate and generate line scan and kymograph of the synapse
// especially suitable for (quasi) isotropic 3D data (OMX)
// first run segement_synapse.ijm, than 3Drotate_linescan.ijm

filedir=getDir("image");
// filedir=File.directory();
name=getTitle();
nameSyn=name+"_maskSyn.tif";
print(nameSyn);
run("Options...", "iterations=1 count=1 black");

// work on original
getDimensions(width, height, channels, slices, frames);
run("Properties...", "channels=3 slices="+slices+" frames=1 pixel_width=0.0395 pixel_height=0.0395 voxel_depth=0.125");
getVoxelSize(dx, dy, dz, unit);


// load segmented synapse
print(filedir+"Mask/"+nameSyn);
open(filedir+"Mask/"+nameSyn);
getDimensions(width, height, channels, slices, frames);
run("Properties...", "channels=1 slices="+slices+" frames=1 pixel_width=0.0395 pixel_height=0.0395 voxel_depth=0.125");

//getDimensions(width, height, channels, slices, frames);
//Stack.setXUnit("pixel"); Stack.setYUnit("pixel"); Stack.setZUnit("pixel");
//run("Properties...", "channels=1 slices="+slices+" frames=1 pixel_width=1 pixel_height=1 voxel_depth=1"); //NB: homogenise and set to 1 the voxel
// run("3D Objects Counter", "threshold=1 slice=25 min.=500 max.=405450 exclude_objects_on_edges objects statistics");
run("3D Objects Counter", "threshold=1 slice=25 min.=500 max.=405450 objects statistics");


// setThreshold(1, 255);
// run("Convert to Mask", "method=Default background=Dark black");

// // compute BBox enlarge and crop in such a way that it is centered
d=50;
Bw=Math.ceil(getResult("B-width", 0)/2)+d;
Bh=Math.ceil(getResult("B-height", 0)/2)+d;
Bd=Math.ceil(getResult("B-depth", 0)/2)+Math.ceil(d*dx/dz);
Cx=getResult("XM", 0);
Cy=getResult("YM", 0);
Cz=getResult("ZM", 0);
selectWindow("Results"); run("Close");
BX0=maxOf(Cx-Bw,1);
BY0=maxOf(Cy-Bh,1);
BZ0=maxOf(Cz-Bd,1);


//Work on mask
selectWindow(nameSyn);
getDimensions(width, height, channels, slices, frames);
makeRectangle(BX0, BY0, 2*Bw, 2*Bh);
BZ1=BZ0+2*Bd;
print(BZ0);
print(BZ1);
run("Duplicate...", "title=Mask duplicate range="+BZ0+"-"+BZ1);
//run("Properties...", "channels=1 slices="+slices+" frames=1 pixel_width=0.0395 pixel_height=0.0395 voxel_depth=0.125");
make_isotropic("Mask",0);
getDimensions(width, height, channels, slices, frames);
run("Properties...", "channels=1 slices="+slices+" frames=1 pixel_width=1 pixel_height=1 voxel_depth=1"); //NB: homogenise and set to 1 the voxel

//waitForUser;

// Compute tranformation and euler angle (for some rason a check i need hance 2 EA are computed
run("3D Ellipsoid Fitting", " ");  
//make8bit();
EulerAngles1=compute_EulerAngles();
selectWindow("Results"); run("Close");
align_ellipsoid("Mask",EulerAngles1);
/*
rename("Tmp_aligned");
close("Mask");
selectWindow("Tmp_aligned");
rename("Mask");
run("3D Ellipsoid Fitting", " ");  
EulerAngles2=compute_EulerAngles();
selectWindow("Results"); run("Close");
align_ellipsoid("Mask",EulerAngles2);
*/

//waitForUser;

// recenter final image


run("3D Objects Counter", "threshold=1 slice=100 min.=500 max.=14997213 objects statistics");
xc=getResult("XM", 0);
yc=getResult("YM", 0);
selectWindow("Results"); run("Close");
selectWindow("Aligned_Mask");
getDimensions(width, height, channels, slices, frames);
dx=Math.ceil(width/2-xc);
dy=Math.ceil(height/2-yc);
run("Translate...", "x="+dx+" y="+dy+" interpolation=None stack");
saveAs(filedir+name+"_SynCropMask.tif");


/************************* apply tranformation on original movie ***********************************/
selectWindow(name);
getDimensions(width, height, channels, slices, frames);
//run("Properties...", "channels=3 slices="+slices+" frames=1 pixel_width=0.0395 pixel_height=0.0395 voxel_depth=0.125");
makeRectangle(BX0, BY0, 2*Bw, 2*Bh);
print(BZ0);
print(Bd);
run("Duplicate...", "title=Original duplicate slices="+BZ0+"-"+BZ0+2*Bd);
make_isotropic("Original",1);
getDimensions(width, height, channels, slices, frames);
run("Properties...", "channels=3 slices="+slices+" frames=1 pixel_width=1 pixel_height=1 voxel_depth=1"); //NB: homogenise and set to 1 the voxel

align_ellipsoid("Original", EulerAngles1);

run("Translate...", "x="+dx+" y="+dy+" interpolation=None stack");
saveAs(filedir+name+"_SynCrop.tif");

// select only few z and do linescan
build_linescan();
saveAs("Results", filedir+name+"_profile.csv");
run("Close");
selectWindow("FlatSyn");
saveAs(filedir+name+"_FlatSyn.tif");
run("Close All");



/*************************  FUNCTIONS *********************************************/
// make_isotropic("Original-2", 0);
function make_isotropic(image, interp){
	selectWindow(image);
	//interpolate z so that dx=dy=dz
	getVoxelSize(dx, dy, dz, unit);
	ratio=dz/dx;
	
	getDimensions(width, height, channels, slices, frames); 
	// implicitely assume dx<dz
	newslices=Math.round(slices*ratio);
	if (interp==1) {
	run("Size...", "width="+width+" height="+height+" depth="+newslices+" average interpolation=Bilinear");
	}
	else {
	run("Size...", "width="+width+" height="+height+" depth="+newslices+" average interpolation=None");
	}
}



function make8bit(){
	getMinAndMax(min, max);
	setMinAndMax(min, max);
	run("Multiply...", "value=255 stack");
	run("8-bit"); 
}

/*
name=getTitle();
run("3D Ellipsoid Fitting", " ");  
ea=compute_EulerAngles();
align_ellipsoid(name,ea)
*/



// Compute the Euler-Cardan angle for extrinsic rotation Z1Y2X3 to be used by TransformJ
function compute_EulerAngles(){
	x1=getResult("Vx2(pix)", 0);
	x2=getResult("Vy2(pix)", 0);
	x3=getResult("Vz2(pix)", 0);
	y1=getResult("Vx1(pix)", 0);
	y2=getResult("Vy1(pix)", 0);
	y3=getResult("Vz1(pix)", 0);
	z1=getResult("Vx0(pix)", 0);
	z2=getResult("Vy0(pix)", 0);
	z3=getResult("Vz0(pix)", 0);
	test=testOrientationSystem(x1,x2,x3,y1,y2,y3,z1,z2,z3);
	if (test==1){
		z1=-z1;
		z2=-z2;
		z3=-z3;	
	}
	ea=DCM2EA(x1,x2,x3,y1,y2,y3,z1,z2,z3);
	Array.print(ea);
	return ea;
}

// EulerAngles1=newArray(-3.1333, -78.2087, 67.3012);
// align_ellipsoid("Original-1", EulerAngles1);
function align_ellipsoid(name,ea){
	selectWindow(name);
	e1=-ea[0];
	e2=-ea[1];
	e3=-ea[2];
	run("TransformJ Rotate", "z-angle="+e1+" y-angle="+e2+" x-angle="+e3+" interpolation=[Nearest Neighbor] background=0.0 adjust resample anti-alias");
	rename("Aligned_"+name);
}



//ZYX int 
function  DCM2EA(x1,x2,x3,y1,y2,y3,z1,z2,z3){
	a=Math.atan2(x2,x1)*180/PI;
	b=Math.atan2(-x3, Math.sqrt(1-Math.sqr(x3)))*180/PI;
	c=Math.atan2(y3, z3)*180/PI;
	ea=newArray(a,b,c);
	return ea;
}


function build_linescan(){
	// select only few z
	getDimensions(width, height, channels, slices, frames);
	halfthick=12; // half thickness of the frame
	run("Properties...", "channels=3 slices="+slices+" frames=1 pixel_width=0.0395 pixel_height=0.0395 voxel_depth=0.0395");
	cenX=Math.floor(width/2)+1;
	cenY=Math.floor(height/2)+1;
	cenZ=Math.floor(slices/2)+1;
	L2=254/2; // 10um length
	run("Duplicate...", "duplicate slices="+(cenZ-halfthick)+"-"+(cenZ+halfthick));
	run("Z Project...", "start=88 stop=112 projection=[Average Intensity]");
	Stack.setChannel(1); run("Select All"); run("Clear", "slice");
	Stack.setChannel(2); run("Select All"); run("Clear", "slice");
	setBackgroundColor(0, 0, 0);
	Stack.setChannel(1);
	makeLine(cenX-L2,cenY, cenX+L2, cenY);
	run("Radial Reslice", "angle=360 degrees_per_slice=1 direction=Clockwise rotate_about_centre");
	run("Z Project...", "projection=[Average Intensity]");
	rename("FlatSyn");
	run("Select All");
  profile = getProfile();
  for (i=0; i<profile.length; i++)
      setResult("Value", i, profile[i]);
  updateResults;
 // Plot.create("Profile", "X", "Value", profile);
}

                                   
+-----------------------------------------------------------------------------+
| Processes:                                  



function testOrientationSystem(x1,x2,x3,y1,y2,y3,z1,z2,z3){
	x=newArray(x1,x2,x3);
	y=newArray(y1,y2,y3);
	z=newArray(z1,z2,z3);
	p=crossprod(x,y);
	if ((sign(p[0])!=sign(z[0])) | (sign(p[1])!=sign(z[1])) | (sign(p[2])!=sign(z[2]))){
		test=1; 	
	}
	else {
		test=0;
	}
	return test;
}

function sign(x){
	if (x==0){s=0;}
	else{s=x/abs(x);}
	return s;
}


function crossprod(v,w){
	p=newArray(3);
	p[0]=v[1]*w[2]-v[2]*w[1];
	p[1]=-v[0]*w[2]+v[2]*w[0];
	p[2]=v[0]*w[1]-v[1]*w[0];
	Array.print(p);
	return p;
}

