
run("3D OC Options", "volume nb_of_obj._voxels centroid centre_of_mass bounding_box dots_size=5 font_size=10 redirect_to=none");


mydir=File.directory; 

name=getTitle();
nucTitle=name+"_nuc.tif";
beadTitle=name+"_drop.tif"

// change dz
nch=2;
chNuc=1;
chDrop=2;

Stack.getDimensions(width, height, channels, slices, frames);
frames=fr=nSlices/(nch*21);
run("Stack to Hyperstack...", "order=xyczt(default) channels="+nch+" slices=21 frames=" + frames + " display=Color");
Stack.getDimensions(width, height, channels, slices, frames);
run("Properties...", "channels="+nch+" slices="+slices+" frames="+frames+" pixel_width=0.3250000 pixel_height=0.3250000 voxel_depth=0.7 global");
// interpolate
run("Size...", "width="+width+" height="+height+" depth=45 time="+frames+" average interpolation=Bicubic");
// change voxel size
run("Properties...", "channels="+nch+" slices=45 frames="+frames+" pixel_width=0.3250000 pixel_height=0.3250000 voxel_depth=.325 frame=[2 min] global");


// save only nucleus channel
run("Duplicate...", "title="+nucTitle+" duplicate channels="+chNuc);
// convert to 8 bit
correctMinMax(nucTitle);
run("8-bit");

// save
saveAs("Tiff", mydir+nucTitle);

// select droplet and TRACK it
selectWindow(name);
run("Duplicate...", "title="+beadTitle+" duplicate channels="+chDrop);
// convert to 8 bit
correctMinMax(beadTitle);
run("8-bit");


Stack.setPosition(1, 45, 1);
getStatistics(area, mean, min, max, std, histogram);
noise=mean;
run("Bleach Correction", "correction=[Simple Ratio] background="+noise);
rename("Corrected");
close(beadTitle);
selectWindow("Corrected");
rename(beadTitle);
saveAs("Tiff", mydir+beadTitle);


vec=COMbead(beadTitle);
createResultTable(frames);
IJ.renameResults("Final","Results");
for (t=1; t<(frames); t++){
	setResult("xBead", t-1, vec[(t-1)]);		
	setResult("yBead", t-1, vec[frames+(t-1)]);		
	setResult("zBead", t-1, vec[2*frames+(t-1)]);
	setResult("R1Bead", t-1, vec[3*frames+(t-1)]);		
	setResult("R2Bead", t-1, vec[4*frames+(t-1)]);		
	setResult("R3Bead", t-1, vec[5*frames+(t-1)]);
}

IJ.renameResults("Results", "Final");
saveAs("results", mydir+name+"DropCOM.txt");run("Close");

close("*");



/* beads can be done all at once*/
function COMbead(stk){
	selectWindow(stk);
 setBatchMode("hide");
	getDimensions(width, height, channels, slices, frames);
	run("Median 3D...", "x=2 y=2 z=2");
	run("Gaussian Blur...", "sigma=2 stack");
	run("Auto Threshold", "method=Otsu white stack use_stack_histogram");
	run("3D Fill Holes");

	x=newArray(frames);
	y=newArray(frames);
	z=newArray(frames);
	R1=newArray(frames);
	R2=newArray(frames);
	R3=newArray(frames);
	
	for (t=1; t<frames; t++){
			run("Duplicate...", "title=tmpbead duplicate frames="+t);
			run("3D Objects Counter", "threshold=128 slice=10 min.=500 max.=144060 objects statistics");
			sel=0;
	//	sel=vecCheck(35,105,20,70);
	//		if (isNaN(sel)){
	//			sel=0;
	//		}
			x[t-1]=getResult("X", sel);
			y[t-1]=getResult("Y", sel);
			z[t-1]=getResult("Z", sel);
			selectWindow("Results"); run("Close");

			selectWindow("Objects map of tmpbead");
			setThreshold(1, 255);
			run("3D Ellipsoid Fitting", " ");
			R1[t-1]=getResult("R1(unit)", sel);
			R2[t-1]=getResult("R2(unit)", sel);
			R3[t-1]=getResult("R3(unit)", sel);
	
		  close("Ellipsoids");
		  selectWindow("Results"); run("Close");			
			close("Objects map of tmpbead");	
			close("tmpbead");
	}
	setBatchMode("show");
  vec=Array.concat(Array.concat(Array.concat(Array.concat(Array.concat(x,y),z),R1),R2),R3);
	return vec;
}


function createResultTable(n){
for (t = 0; t <=n; t++) {
	setResult("xBead", t, 0);		
	setResult("yBead", t, 0);		
	setResult("zBead", t, 0);	
	setResult("R1Bead", t, 0);				
	setResult("R2Bead", t, 0);		
	setResult("R3Bead", t, 0);		
	
	}
IJ.renameResults("Results","Final");
}



function vecCheck(x0,x1,y0,y1){
	selectWindow("Results");
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
		Array.print(vol);
		s= Array.findMaxima(vol, 1);
		Array.print(s);
		sel=s[0];
		}
		print(sel);
	return sel;
}


function correctMinMax(stk){
	selectWindow(stk);
	run("Duplicate...", "title=tmp8bit duplicate");
	run("Median...", "radius=3 stack");
	Stack.getStatistics(voxelCount, mean, min, max, stdDev) // Calculates and returns stack statistics. 
	close();
	selectWindow(stk);
	setMinAndMax(min, max);
}