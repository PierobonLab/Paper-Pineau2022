// split channels and prepare movies
run("3D OC Options", "volume nb_of_obj._voxels centroid centre_of_mass bounding_box dots_size=5 font_size=10 redirect_to=none");
 /* Dialog.create("Preset");
  items = newArray("Lines", "Primary");
  Dialog.addRadioButtonGroup("Cell type", items, 1, 2, "Lines");
  Dialog.show;
  a=Dialog.getRadioButton;
	if (a.matches('Lines')) lines=1;
	else lines=0;
*/
lines=0;
Stack.getDimensions(width, height, nchannels, slices, frames); 
if (nchannels==1){
	nchannels=2;
	slices=21;
	frames=nSlices/(nchannels*slices);
	run("Stack to Hyperstack...", "order=xyczt(default) channels="+nchannels+" slices="+slices+" frames="+frames+" display=Color");
}
Stack.getDimensions(width, height, nchannels, slices, frames); 
if (lines==1) run("Properties...", "channels="+nchannels+" slices="+slices +" frames="+frames+" pixel_width=0.325 pixel_height=0.325 voxel_depth=0.7 global"); // cell lines
else run("Properties...", "channels="+nchannels+" slices="+slices +" frames="+frames+" pixel_width=0.108 pixel_height=0.108 voxel_depth=0.7 global"); // primary

run("Properties...", "channels="+nchannels+" slices="+slices +" frames="+frames+" pixel_width=0.108 pixel_height=0.108 voxel_depth=0.7 global"); // primary


mydir=File.directory; 
print(mydir);

name=getTitle();
outdir="~/out/";
	saveAs("Tiff", outdir+name);

name0=substring(name, 0, lengthOf(name)-4);
//mydir=File.directory; print(mydir+name);
// outdir="/home/paolo/Documents/PROJECTS/Judith/";
outdir=mydir;
//mydir=File.directory; print(mydir);

name=getTitle();
selectWindow(name);

run("Duplicate...", "title=tmp duplicate slices=2-"+slices); // cell might need this correction
selectWindow(name);
run("Close");
selectWindow("tmp");
rename(name);
Stack.getDimensions(width, height, nchannels, slices, frames); 
// set unit to 1 to compute positions in pixel
run("Properties...", "channels="+nchannels+" slices="+slices+" frames="+frames+" pixel_width=1 pixel_height=1 voxel_depth=1 global");


run("Split Channels");
// 2 channels
selectWindow("C3-"+name); rename("Nuc");
selectWindow("C1-"+name); rename("Bead");

// 3 channels
//selectWindow("C2-"+name); rename("Nuc");
//selectWindow("C3-"+name); rename("Bead");



// track droplet or import table

// general
selectWindow("Bead");
Stack.getDimensions(width, height, channels, slices, frames);
timePoints=frames; //frames;)
//timePoints=56;
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
leftpos=newArray(frames);
rightpos=newArray(frames);

/******************** BEAD ************************/
// vector bead position
run("Duplicate...", "title=Bead2 duplicate");
vec=COMbead("Bead2");
close("Bead2");

for (t=1; t<(timePoints+1); t++){
	xBead[t-1]=vec[(t-1)];		
	yBead[t-1]=vec[timePoints+(t-1)];		
	zBead[t-1]=vec[2*timePoints+(t-1)];		
	Rmean[t-1]=vec[3*timePoints+(t-1)];	
}



/******************** Cell/Nucleus ************************/
// track cell/nucleus based on bead z
// NB the 2D particl aanlaysis output x and y in real value so pass to 1 1 units!
selectWindow("Nuc");
//run("Properties...", "channels=1 slices=21 frames="+frames+" pixel_width=1 pixel_height=1 voxel_depth=1");
//setBatchMode("hide");
for (t = 2; t < frames+1; t++) {
	print("z="+zBead[t-1]);
	selectWindow("Nuc");
	run("Select None");
	//zmin=Math.round(zBead[t-1])-2;
	//zmax=Math.round(zBead[t-1])+4;
	zmin=Math.max(1, Math.round(zBead[t-1])-2);
	zmax=Math.min(slices,Math.round(zBead[t-1])+4);
	zmin=2; zmax=slices-1;
	run("Duplicate...", "title=tmp duplicate slices="+zmin+"-"+zmax+" frames="+t);
	run("Z Project...", "projection=[Max Intensity]");
	run("Median...", "radius=4");
  getMinAndMax(min, max);
	setMinAndMax(min, max);
	run("8-bit"); 
	// setAutoThreshold("Default dark");
	 setAutoThreshold("Huang dark");
	
	//setAutoThreshold("Triangle dark");
	//
//	run("Analyze Particles...", "size=200-Infinity display exclude clear add");
	run("Analyze Particles...", "size=200-Infinity display clear add");
// waitForUser;

	// comment this 10 lines in case
	sel=vecCheck2D(1,200,1,460); 	//print(sel);
	if (isNaN(sel)){
		xCell[t-1]=xCell[t-2];
		yCell[t-1]=xCell[t-2];
	}else{
		xCell[t-1]=getResult("X", sel);
		yCell[t-1]=getResult("Y", sel);
	}
						
	//xCell[t-1]=getResult("X", 0);
	//yCell[t-1]=getResult("Y", 0);


	close("tmp"); 
	close("MAX_tmp");
  print("time="+t);
}
// correct the first point (where the cell is not there!)
xCell[0]=xCell[1];
yCell[0]=yCell[1];
// waitForUser;

Array.print(xBead);
Array.print(yBead);
Array.print(zBead);
Array.print(xCell);
Array.print(yCell);
// waitForUser;


// generate linescan and extract max

selectWindow("Bead");
Sub_Bkg3D("Bead");

run("Duplicate...", "title=Bead_measurable duplicate slices=1");
Stack.getDimensions(width, height, channels, slices, frames);

setBatchMode("show");
for (t = 1; t < frames+1; t++) {
	selectWindow("Bead");
	if (lines==1){
		zmin=Math.max(Math.round(zBead[t-1])-2,1); // cell lines
		zmax=Math.min(Math.round(zBead[t-1])+4,slices); // cell lines
	} else{
		zmin=Math.max(Math.round(zBead[t-1])-1,1); // primary
		zmax=Math.min(Math.round(zBead[t-1])+2,slices);// primary
	}
	
	Stack.setFrame(t);
	run("Duplicate...", "title=tmpbead duplicate slices="+zmin+"-"+zmax+" frames="+t);
	run("Z Project...", "projection=[Average Intensity]");
	run("Select All");
	run("Copy");
	run("Close");
	selectWindow("Bead_measurable");
	Stack.setFrame(t);
	run("Paste");
	close("tmpbead");

}

// define radius
Array.getStatistics(Rmean, min, rmax, mean, stdDev);
selectWindow("Bead_measurable");
run("Subtract Background...", "rolling=200 stack");

Array.print(Rmean);


for (t = 1; t < frames+1; t++) {
	selectWindow("Bead_measurable");
	Stack.setFrame(t);
	Xb=xBead[t-1];
	Yb=yBead[t-1];
	Xc=xCell[t-1];
	Yc=yCell[t-1];
	th=atan2(Yb-Yc, Xb-Xc);	
	R=floor(rmax*1.2);	

// NB: line thickness fits well in pixel for both line and primaries	
	makeLine(Xc, Yc, Xb+R*cos(th), Yb+R*sin(th),11);
	
	profile = getProfile();
	// find left
	
	subprofile=Array.slice(profile,0, profile.length-floor(R));
	rank=Array.rankPositions(subprofile);
	leftpos[t-1]=rank[rank.length-1];	
	
	// find right
if (leftpos[t-1]+floor(R)< (profile.length-1)) {
	subprofile=Array.slice(profile,leftpos[t-1]+floor(R), profile.length-1);
	rank=Array.rankPositions(subprofile);		
	rightpos[t-1]=leftpos[t-1]+floor(R)+rank[rank.length-1];
	left[t-1]=profile[leftpos[t-1]];
	right[t-1]=profile[rightpos[t-1]];
	ratio[t-1]=left[t-1]/right[t-1];
} else{
	leftpos[t-1]=NaN;
	rightpos[t-1]=NaN;
	left[t-1]=NaN;
	right[t-1]=NaN;
	ratio[t-1]=NaN;
}
print("time="+t);
	print(left[t-1]);
	print(right[t-1]);
	print(leftpos[t-1]);
		print(rightpos[t-1]);
	
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
	setResult("leftpos", t-1, leftpos[(t-1)]);		
	setResult("rightpos", t-1, rightpos[(t-1)]);		
	setResult("left", t-1, left[(t-1)]);		
	setResult("right", t-1, right[(t-1)]);		
	setResult("ratio", t-1, ratio[(t-1)]);		
}
IJ.renameResults("Results", "Final");
print(outdir+name0);
saveAs("results", outdir+name0+"_Recruit.txt");
run("Close");
run("Close All");
call("java.lang.System.gc"); 

/*********************************************************************************/




/* beads can be done all at once*/
function COMbead(stk){
	selectWindow(stk);
 setBatchMode("hide");
	getDimensions(width, height, channels, slices, frames);

	run("Duplicate...", "title=maskbead duplicate");
	run("Median 3D...", "x=2 y=2 z=1");
	run("Gaussian Blur 3D...", "x=2 y=2 z=1");
//	run("Gaussian Blur...", "sigma=2 stack");
	//run("Auto Threshold", "method=Shanbhag white stack use_stack_histogram");
		
	run("Auto Threshold", "method=Otsu white stack use_stack_histogram");
	run("3D Fill Holes");

	x=newArray(frames);
	y=newArray(frames);
	z=newArray(frames);
	Rm=newArray(frames);
	
	for (t=1; t<frames+1; t++){
	//	print(t);
			selectWindow("maskbead");
			run("Duplicate...", "title=tmpbead duplicate frames="+t);
			getRawStatistics(nPixels, mean, min, max, std, histogram); print(mean);
			if (mean==0){
				sel=NaN;
				print("salta");
			}
			else{
				run("3D Objects Counter", "threshold=128 slice=10 min.=500 max.=1440060 objects statistics");
				//sel=vecCheck(35,105,20,70);
			  wait(200);
			  sel=vecCheck(0,230,0,280);
			  print("ok");
			  wait(100);
			}
			if (isNaN(sel)){
				x[t-1]=x[t-2];
				y[t-1]=y[t-2];
				z[t-1]=z[t-2];
				Rm[t-1]=Rm[t-2];
			}
			else{
			x[t-1]=getResult("X", sel);
			y[t-1]=getResult("Y", sel);
			z[t-1]=getResult("Z", sel);
			dx=getResult("B-width", sel);
			dy=getResult("B-height", sel);
			Rm[t-1]=(dx+dy)/4;
			selectWindow("Results"); run("Close");

			}
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
			print(t);

	}
	setBatchMode("show");
  vec=Array.concat(Array.concat(Array.concat(x,y),z),Rm);
	return vec;
}

// Verifies if droplet is in the correct point
function vecCheck(x0,x1,y0,y1){
	//selectWindow("Results");
	//setLocation(10, 10, 100, 100);
	n=nResults; print(n);
	vol=newArray(n);
	print("ok2");
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
		print("ok2");
	return sel;
}

// Verifies if droplet is in the correct point
function vecCheck2D(x0,x1,y0,y1){
	// convert in pixel
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1 frame=[30 sec]");
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
			vox=getResult("Area", k);
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
	setResult("leftpos", t, 0);		
	setResult("rightpos", t, 0);		
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

