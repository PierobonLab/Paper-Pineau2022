// split channels and prepare movies
run("3D OC Options", "volume nb_of_obj._voxels centroid centre_of_mass bounding_box dots_size=5 font_size=10 redirect_to=none");
nchannels=3;
frames=nSlices/(nchannels*21);
mydir=File.directory; print(mydir);

name=getTitle();
name0=substring(name, 0, lengthOf(name)-4);
mydir=File.directory; print(mydir+name);
run("Stack to Hyperstack...", "order=xyczt(default) channels="+nchannels+" slices=21 frames="+frames+" display=Color");
//run("Properties...", "channels="+nchannels+" slices=21 frames="+frames+" pixel_width=0.325 pixel_height=0.325 voxel_depth=0.7");
run("Properties...", "channels="+nchannels+" slices=21 frames="+frames+" pixel_width=0.325 pixel_height=0.325 voxel_depth=0.7 global");
outdir="~/out/";

mydir=File.directory; print(mydir);
name=getTitle();
//saveAs("Tiff", mydir+name); 

selectWindow(name);
run("Properties...", "channels="+nchannels+" slices=21 frames="+frames+" pixel_width=1 pixel_height=1 voxel_depth=1 global");


run("Split Channels");
// 2 channels
// selectWindow("C1-"+name); rename("Nuc");
// selectWindow("C2-"+name); rename("Bead");

// 3 channels
selectWindow("C2-"+name); rename("Nuc");
selectWindow("C3-"+name); rename("Bead");



// track droplet or import table

// general
selectWindow("Bead");
Stack.getDimensions(width, height, channels, slices, frames) 
timePoints=frames; //frames;)
createResultTable(timePoints);

xBead=newArray(frames);
yBead=newArray(frames);
zBead=newArray(frames);
xCell=newArray(frames);
yCell=newArray(frames);
Rmean=newArray(frames);
left=newArray(frames);
right=newArray(frames);
ratio=newArray(frames);

/******************** BEAD ************************/

resname=name0+"_Final.txt";
run("Results... ", "open="+mydir+resname);



for (t=1; t<(timePoints+1); t++){
	xBead[t-1]=getResul		
	yBead[t-1]=vec[timePoints+(t-1)];		
	zBead[t-1]=vec[2*timePoints+(t-1)]+1;		
	Rmean[t-1]=vec[3*timePoints+(t-1)];	
}

// waitForUser("b");



/******************** Cell/Nucleus ************************/
// track cell/nucleus based on bead z
// NB the 2D particl aanlaysis output x and y in real value so pass to 1 1 units!
selectWindow("Nuc");
//run("Properties...", "channels=1 slices=21 frames="+frames+" pixel_width=1 pixel_height=1 voxel_depth=1");
setBatchMode("hide");
for (t = 2; t < frames; t++) {
	selectWindow("Nuc");
	run("Select None");
	zmin=Math.round(zBead[t-1])-2;
	zmax=Math.round(zBead[t-1])+4;
	run("Duplicate...", "title=tmp duplicate slices="+zmin+"-"+zmax+" frames="+t);
	run("Z Project...", "projection=[Max Intensity]");
	run("Median...", "radius=2");
	run("8-bit");
	setAutoThreshold("Default dark");
	run("Analyze Particles...", "size=20-Infinity display exclude clear add");
	xCell[t-1]=getResult("X", 0);
	yCell[t-1]=getResult("Y", 0);
	close("tmp"); 
	close("MAX_tmp");
}


// generate linescan and extract max

selectWindow("Bead");
Sub_Bkg3D("Bead");

run("Duplicate...", "title=Bead_measurable duplicate slices=1");

for (t = 1; t < frames; t++) {
	selectWindow("Bead");
	zmin=Math.max(Math.round(zBead[t-1])-2,1);
	zmax=Math.min(Math.round(zBead[t-1])+4,21);
	Stack.setFrame(t);
	run("Duplicate...", "title=tmpbead duplicate slices="+zmin+"-"+zmax+" frames="+t);
	run("Z Project...", "projection=[Average Intensity]");
	run("Select All");
	run("Copy");
	selectWindow("Bead_measurable");
	Stack.setFrame(t);
	run("Paste");

}

// define radius
Array.getStatistics(Rmean, min, rmax, mean, stdDev);
selectWindow("Bead_measurable");
run("Subtract Background...", "rolling=200 stack");
for (t = 1; t < frames; t++) {
	selectWindow("Bead_measurable");
	Stack.setFrame(t);
	Xb=xBead[t];
	Yb=yBead[t];
	Xc=xCell[t];
	Yc=yCell[t];
	th=atan2(Yb-Yc, Xb-Xc);	
	R=floor(rmax*2);	

	
	makeLine(Xc, Yc, Xb+R*cos(th), Yb+R*sin(th),11);
	
 profile = getProfile();

 
// Array.print(profile);
 
 maxloc=Array.findMaxima(profile, 10);

	Array.getStatistics(maxloc, maxleft, maxright, mean, stdDev); 
//	Array.print(maxloc);
	left[t]=profile[maxleft];
	right[t]=profile[maxright];
	ratio[t]=left[t]/right[t];
	close("tmpbead");
	close("AVG_tmpbead");
}
setBatchMode("show");

// save results
IJ.renameResults("Final","Results");
for (t=1; t<(timePoints+1); t++){
	setResult("xBead", t-1, xBead[(t-1)]);		
	setResult("yBead", t-1, yBead[(t-1)]);		
	setResult("zBead", t-1, zBead[(t-1)]);		
	setResult("Rmean", t-1, Rmean[(t-1)]);		
	setResult("xNuc", t-1, xCell[(t-1)]);		
	setResult("yNuc", t-1, yCell[(t-1)]);		
	setResult("left", t-1, left[(t-1)]);		
	setResult("right", t-1, right[(t-1)]);		
	setResult("ratio", t-1, ratio[(t-1)]);		
}
IJ.renameResults("Results", "Final");
saveAs("results", outdir+name0+"_Final.txt");
run("Close");
run("Close All");


/*********************************************************************************/




/* beads can be done all at once*/
function COMbead(stk){
	selectWindow(stk);
 setBatchMode("hide");
	getDimensions(width, height, channels, slices, frames);

	run("Duplicate...", "title=maskbead duplicate");
	run("Median 3D...", "x=1 y=1 z=2");
	run("Gaussian Blur 3D...", "x=2 y=2 z=4");
//	run("Gaussian Blur...", "sigma=2 stack");
	//run("Auto Threshold", "method=Shanbhag white stack use_stack_histogram");
		
	run("Auto Threshold", "method=Otsu white stack use_stack_histogram");
	run("3D Fill Holes");

	x=newArray(frames);
	y=newArray(frames);
	z=newArray(frames);
	Rm=newArray(frames);
	
	for (t=1; t<frames+1; t++){
			selectWindow("maskbead");
			run("Duplicate...", "title=tmpbead duplicate frames="+t);
			run("3D Objects Counter", "threshold=128 slice=10 min.=500 max.=144060 objects statistics");
			
			sel=vecCheck(35,105,20,70);
			
			x[t-1]=getResult("X", sel);
			y[t-1]=getResult("Y", sel);
			z[t-1]=getResult("Z", sel);

			dx=getResult("B-width", sel);
			dy=getResult("B-height", sel);
			Rm[t-1]=(dx+dy)/4;
			selectWindow("Results"); run("Close");
			/*	
			selectWindow("Objects map of tmpbead");
			setThreshold(1, 255);
			run("3D Ellipsoid Fitting", " ");
			R1[t-1]=getResult("R1(unit)", sel);
			R2[t-1]=getResult("R2(unit)", sel);
			R3[t-1]=getResult("R3(unit)", sel);
		  close("Ellipsoids");
		  selectWindow("Results"); run("Close");
		  */			
			close("Objects map of tmpbead");	
			close("tmpbead");

	}
	setBatchMode("show");
  vec=Array.concat(Array.concat(Array.concat(x,y),z),Rm);
	return vec;
}


function vecCheck(x0,x1,y0,y1){
	selectWindow("Results");
	setLocation(10, 10, 100, 100);
	n=nResults;
	vol=newArray(n);
	if (n<2){
		if (n==0)	{sel=NaN;}
		else {sel=0;}
	}
	else {
		for (k=0; k<n; k++){
			x=getResult("XM", k);
			y=getResult("YM", k);
			vox=getResult("Nb of obj. voxels", k);
			if ((x>x0) & (x<x1) & (y>y0) & (y<y1)) {vol[k]=vox;}
			else {vol[k]=0;}
		}
//		Array.print(vol);
		s= Array.findMaxima(vol, 1);
//		Array.print(s);
		sel=s[0];
		}
	return sel;
}


function createResultTable(n){
for (t = 0; t <n; t++) {
	setResult("xBead", t, 0);
	setResult("yBead", t, 0);		
	setResult("zBead", t, 0);		
	setResult("Rmean", t, 0);		
	setResult("xNuc", t, 0);		
	setResult("yNuc", t, 0);		
	setResult("left", t, 0);		
	setResult("right", t, 0);		
	setResult("ratio", t, 0);
}
IJ.renameResults("Results","Final");
}


function Sub_Bkg3D(name){
	selectWindow(name);	
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.setPosition(1,1,1);
	makeRectangle(0, 0, 25, 25);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	run("Select None");
	run("Bleach Correction", "correction=[Simple Ratio] background="+mean);
}




function Sub_Bkg3DB(name){
	selectWindow(name);	
	Stack.getDimensions(width, height, channels, slices, frames);
	for (t = 1; t < frames+1; t++) {
		for (i = 1; i < slices+1; i++) {
		selectWindow("maskbead");
		Stack.setPosition(1,i,t);
		run("Create Selection");
		selectWindow(name);
		Stack.setPosition(1,i,t);
		run("Restore Selection");
		run("Clear", "slice");
		run("Select None");
		}
	}
}
