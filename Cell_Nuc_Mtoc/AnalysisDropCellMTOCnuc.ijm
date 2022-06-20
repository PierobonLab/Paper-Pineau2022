/***************  Analysis_DropCellMtocNuc   ********* in soft *********
*   Full analsyis of a 3D 4 our 2 color file
*
*
*
****************************************************************/
/*
myDir = getDirectory("Choose a Directory ");

list = getFileList(myDir);

for (k=0; k<list.length; k++) {
	print(list[k]);
  if (!(endsWith(list[k], "/")) & (endsWith(list[k], ".tif"))){
			name=list[k];
			path=substring(name,0,lengthOf(name)-4);
			print(path);
			open(myDir+list[k]);
*/

/**************************** preliminary **********************/


name=getTitle();


mydir="~/data/";
outdir=mydir;

run("Options...", "iterations=1 count=1 black do=Nothing");
run("3D OC Options", "volume nb_of_obj._voxels centroid mean_distance_to_surface centre_of_mass bounding_box dots_size=5 font_size=10 redirect_to=none");

name=getTitle();
nucTitle=name+"_nuc.tif";
DropTitle=name+"_drop.tif";
cellMaskTitle=name+"_cellMask.tif";
dropMaskTitle=name+"_dropMask.tif";
nucMaskTitle=name+"_NucMask.tif";


// change dz
chCell=3;
chNuc=2;
chDrop=1;
nInterp=45;
px=0.325;
nZ=21;
Stack.getDimensions(width, height, channels, slices, frames);
/*
if (slices!=nZ){
	frames=nSlices/(channels*nZ);
	run("Stack to Hyperstack...", "order=xyczt(default) channels="+channels+" slices="+nZ+" frames=" + frames + " display=Color");
}
*/
wait(100);
run("Properties...", "channels="+channels+" slices="+nZ+" frames="+frames+" pixel_width="+px+" pixel_height="+px+" voxel_depth=0.7 global");
// interpolate
run("Size...", "width="+width+" height="+height+" depth="+nInterp+" time="+frames+" average interpolation=Bicubic");
// change voxel size
run("Properties...", "channels="+channels+" slices="+nInterp+" frames="+frames+" pixel_width="+px+" pixel_height="+px+" voxel_depth="+px+" frame=[30 sec] global");

run("Split Channels");
/*
selectWindow("C1-"+name); rename("Cell");
selectWindow("C2-"+name); rename("Nuc");
selectWindow("C3-"+name); rename("Drop");
*/
selectWindow("C3-"+name); rename("Cell");
selectWindow("C2-"+name); rename("Nuc");
selectWindow("C1-"+name); rename("Drop");


createResultTable(frames);


/*********************** NUCLEUS *********************************/
// save only nucleus channel
selectWindow("Nuc");
correctMinMax("Nuc"); // convert to 8 bit
run("8-bit");
saveAs("Tiff", outdir+nucTitle);
rename("Nuc");

// vector Nuc position
selectWindow("Nuc");
Stack.setPosition(1, 1, 1);
getStatistics(area, mean, min, max, std, histogram);
noise=mean;
run("Bleach Correction", "correction=[Simple Ratio] background="+noise);
rename("Corrected");
close("Nuc");
selectWindow("Corrected");
rename("Nuc");
vecn=COMNuc("Nuc"); // results saved in table (but xNuc and yNuc)
// xNuc=Array.slice(vecn,0,frames-1)
// yNuc=Array.slice(vecn,frames-1,2*frames-2);
close("Nuc");


IJ.renameResults("Final","Results");
selectWindow("Results");
saveAs("Results", outdir+name+"_Final0.txt");
IJ.renameResults("Results", "Final");


/********************** CELL **************************************/

TrackCELL(); // results saved in table

IJ.renameResults("Final","Results");
selectWindow("Results");
saveAs("Results", outdir+name+"_Final1.txt");
IJ.renameResults("Results","Final");
wait(200);

selectWindow("Corrected");
saveAs("Tiff", outdir+cellMaskTitle);

run("Close");
selectWindow("Mon");
saveAs("Tiff", outdir+name+"_Montage.tif");
wait(200);
run("Close");


/************************* DROPLET *********************************/

selectWindow("Drop");
Stack.setPosition(1, nInterp, 1);
getStatistics(area, mean, min, max, std, histogram);
noise=mean;
run("Bleach Correction", "correction=[Simple Ratio] background="+noise);
wait(200);
rename("Corrected");
correctMinMax("Corrected");
wait(200);

run("8-bit");
close("Drop");
selectWindow("Corrected");
rename("Drop");
saveAs("Tiff", outdir+DropTitle);
wait(200);

// track COM drop, KEEP MASK
rename("Drop");

vecDrop=COMDrop("Drop"); // to be USED FOR AG RECRUIT
//	waitForUser("comdrop2");
wait(500);


IJ.renameResults("Final","Results");
selectWindow("Results");
saveAs("Results", outdir+name+"_Final2.txt");
IJ.renameResults("Results", "Final");


/************************ MTOC *************************************/

TrackMTOC("dropmask","Cell");  // CHECK THE WINDOW AND SYNTAX!!!!!!!!!!!!
//	waitForUser("mtoc2");




// save all results

wait(500);
IJ.renameResults("Final","Results");
selectWindow("Results");
saveAs("Results", outdir+name+"_Final.txt");
close("Results");

// close all
close("*");
run("Collect Garbage");
print(IJ.freeMemory());




/********************* FUNCTIONS *************************************/

function TrackCELL(){   // track of cell
	selectWindow("Cell");

	//setBatchMode("hide"); /************************************************************/

	time0=2;
//	run("Duplicate...", "title=tmptmp duplicate");
	Stack.setPosition(1, 1, time0);
	Stack.getDimensions(width, height, channels, slices, frames) 
	
	// treat full stack 
	Stack.setPosition(1, 1, 1);
	getStatistics(area, mean, min, max, std, histogram);
	noise=mean;
	run("Bleach Correction", "correction=[Simple Ratio] background="+noise);
	rename("Corrected");
	run("Median 3D...", "x=3 y=3 z=3");
	correctThreshold();
// check routine to select which threshold
//setThreshold(11, 255);
//run("Convert to Mask", "method=Default background=Dark black");

	 run("Auto Threshold", "method=Huang white stack use_stack_histogram");
	//setThreshold(53, 255);
	//run("Make Binary", "method=Li background=Dark black");

	run("Dilate", "stack");
	run("Fill Holes", "stack");
	run("Erode", "stack");
	// setBatchMode("show"); /************************************************************/
	
	testvalue=testThreshold("Corrected");
	if (testvalue) {
		thsize=2000;	

		for (t=time0-1; t<frames; t++){
	//	setBatchMode("hide"); /************************************************************/

			time=t+1;
			selectWindow("Corrected");
			run("Duplicate...", "title=tmp duplicate frames="+time);
			if (t==(time0-1)) {
				posCOM=COMfinder("tmp", thsize);	
				wait(200);
	  		selectWindow("Objects map of tmp");
				run("Make Montage...", "columns=9 rows=5 scale=1");
				rename("Mon");
			}
			else {
				posCOM=COMfinder("tmp", thsize);
				wait(100);
				selectWindow("Objects map of tmp");
				run("Make Montage...", "columns=9 rows=5 scale=1");
				run("Concatenate...", "  title=Mon open image1=Mon image2=Montage image3=[-- None --]");
			}
		
//	Array.print(posCOM);
		close("tmp");
		close("Objects map of tmp");
	//	setBatchMode("show"); /************************************************************/
	wait(200);

		IJ.renameResults("Final","Results");
		if (isNaN(posCOM[0])) {
			setResult("x0", t, getResult("x0", t-1));
			setResult("y0", t, getResult("y0", t-1));
			setResult("z0", t, getResult("z0", t-1));
			setResult("V0", t, getResult("V0", t-1));
			setResult("x", t, getResult("x", t-1));
			setResult("y", t, getResult("y", t-1));
			setResult("z", t, getResult("z", t-1));
			setResult("V", t, getResult("V", t-1));
			setResult("R1", t, getResult("R1", t-1));
			setResult("R2", t, getResult("R2", t-1));
			setResult("R3", t, getResult("R3", t-1));
			setResult("XY0", t, getResult("XY0", t-1));
			setResult("XZ0", t, getResult("XZ0", t-1));
			setResult("YZ0", t, getResult("YZ0", t-1));	
		}
		else {
			setResult("x0", t, posCOM[0]);
			setResult("y0", t, posCOM[1]);
			setResult("z0", t, posCOM[2]);
			setResult("V0", t, posCOM[3]);		
			setResult("x", t, posCOM[4]);
			setResult("y", t, posCOM[5]);
			setResult("z", t, posCOM[6]);
			setResult("V", t, posCOM[7]);
			setResult("R1", t, posCOM[8]);
			setResult("R2", t, posCOM[9]);
			setResult("R3", t, posCOM[10]);
			setResult("XY0", t, posCOM[11]);
			setResult("XZ0", t, posCOM[12]);
			setResult("YZ0", t, posCOM[13]);
		}
		IJ.renameResults("Results","Final");
		print(t);	
		}
	}
	else {
		print("Problem");
		break;
	}
// waitForUser("trackCELL");
// selectWindow("Final");
}



/*********************************************************************************************************/

function COMfinder(stk, thsize) { 
	// find cell COM position based on binary segmentation
	selectWindow(stk);
//	rename("sub");
/* insert here the segmentation treatment*/
	// check if an obj exist to avoid 3D OC to bug:
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	if (mean==0) {
		th=0;
	}
	else {
		th=128;
	}
//	thsize=4000;
  run("3D Objects Counter", "threshold="+th+" min.="+thsize+" max.=500000 objects statistics"); 

  objFound=nResults;
//	print(objFound);

	if (objFound>0){	
		// segmentation with convex part 
		x0=getResult("XM", 0);
		y0=getResult("YM", 0);
		z0=getResult("ZM", 0);	
		V0=getResult("Nb of obj. voxels", 0);
		selectWindow("Results"); run("Close");

	  selectWindow("Objects map of tmp");
	  rename("tmp1");
		setThreshold(1, 1);   // select only larger object
		run("Convert to Mask","method=Default background=Default black");
//	 print(nResults);
		// segmentation on convex hull 2D
	  correct_convex();
    selectWindow("tmp1");
  	run("3D Objects Counter", "threshold="+th+" min.="+thsize+" max.=500000 objects statistics");  
  	x=getResult("XM", 0);
		y=getResult("YM", 0);
		z=getResult("ZM", 0);	
		V=getResult("Nb of obj. voxels", 0);
		selectWindow("Results"); run("Close");
	
		selectWindow("Objects map of tmp1");
	  rename("Objects map of tmp");
	  setThreshold(1, 1);
	  run("Convert to Mask","method=Default background=Default black");
	/*  
    run("3D Ellipsoid Fitting", " ");
		R1=getResult("R1(unit)", 0);
		R2=getResult("R2(unit)", 0);
		R3=getResult("R3(unit)", 0);
		XY0=getResult("XY0(deg)", 0);
		XZ0=getResult("XZ0(deg)", 0);
		YZ0=getResult("YZ0(deg)", 0);
		*/
	}
	else {
		x0=NaN;
		y0=NaN;
		z0=NaN;
		V0=NaN;
		x=NaN;
		y=NaN;
		z=NaN;
		V=NaN;
		R1=NaN;
		R2=NaN;
		R3=NaN;
		XY0=NaN;
		XZ0=NaN;
		YZ0=NaN;
	}
	close("tmp1");
  // close("Ellipsoids");
	// selectWindow("Results"); run("Close");
  	
  	R1=NaN;
		R2=NaN;
		R3=NaN;
		XY0=NaN;
		XZ0=NaN;
		YZ0=NaN;

	return newArray(x0,y0, z0, V0, x, y, z, V, R1, R2, R3, XY0, XZ0, YZ0);
}




/*********************************************************************************************************/

/* find COM of NUCLEUS */
function COMNuc(stk){
	setBatchMode("hide");
	selectWindow(stk);
	getDimensions(width, height, channels, slices, frames);

  run("Median 3D...", "x=1 y=1 z=1");
	run("Gaussian Blur...", "sigma=2 stack");
	run("Auto Threshold", "method=Otsu white stack use_stack_histogram");
	run("3D Fill Holes");

	x=newArray(frames);
	y=newArray(frames);
	z=newArray(frames);
	V=newArray(frames);
	R1=newArray(frames);
	R2=newArray(frames);
	R3=newArray(frames);
	XY0=newArray(frames);
	XZ0=newArray(frames);
	YZ0=newArray(frames);
	XY1=newArray(frames);
	XZ1=newArray(frames);
	YZ1=newArray(frames);
	
	for (t=2; t<frames+1; t++){
			run("Duplicate...", "title=tmpNuc duplicate frames="+t);
			
			getStatistics(area, mean, min, max, std, histogram); 
			if (mean<1){ // this check avoid error if by chance the figure is empty
				th=0;
			}
			else{
				th=128;
			}
			run("3D Objects Counter", "threshold="+th+" slice=22 min.=100 max.=400000 objects statistics");
			print(t);
 			 objFound=nResults;
			//	print(objFound);
			
		//	sel=vecCheck(25,65,20,70);
	sel=vecCheck(1,100,20,70);
			if (isNaN(sel) || (objFound<1)){
			x[t-1]=x[t-2];
			y[t-1]=y[t-2];
			z[t-1]=z[t-2];
			V[t-1]=V[t-2];
			} else{
			x[t-1]=getResult("X", sel);
			y[t-1]=getResult("Y", sel);
			z[t-1]=getResult("Z", sel);
			V[t-1]=getResult("Nb of obj. voxels", sel);
	
/*
			selectWindow("Objects map of tmpNuc");
			setThreshold(1, 255);
			run("3D Ellipsoid Fitting", " ");
			R1[t-1]=getResult("R1(unit)", sel);
			R2[t-1]=getResult("R2(unit)", sel);
			R3[t-1]=getResult("R3(unit)", sel);
			XY0[t-1]=getResult("XY0(deg)", sel);
			XZ0[t-1]=getResult("XZ0(deg)", sel);
			YZ0[t-1]=getResult("YZ0(deg)", sel);
			XY1[t-1]=getResult("XY1(deg)", sel);
			XZ1[t-1]=getResult("XZ1(deg)", sel);
			YZ1[t-1]=getResult("YZ1(deg)", sel);
	
		  close("Ellipsoids");
		  selectWindow("Results"); run("Close");
	*/
			}
			if (isOpen("Results")){selectWindow("Results"); run("Close");}

			close("Objects map of tmpNuc");	
			close("tmpNuc");
	}
 	setBatchMode("show");
 
	IJ.renameResults("Final","Results");
	for (t=0; t<frames-1; t++){
		setResult("xNuc", t, x[t]);		
		setResult("yNuc", t, y[t]);		
		setResult("zNuc", t, z[t]);	
		setResult("VNuc", t, V[t]);		
		setResult("R1Nuc", t, R1[t]);		
		setResult("R2Nuc", t, R2[t]);		
		setResult("R3Nuc", t, R3[t]);
		setResult("XY0Nuc", t, XY0[t]);		
		setResult("XZ0Nuc", t, XZ0[t]);		
		setResult("YZ0Nuc", t, YZ0[t]);
		setResult("XY1Nuc", t, XY1[t]);		
		setResult("XZ1Nuc", t, XZ1[t]);		
		setResult("YZ1Nuc", t, YZ1[t]);
		// copy the vectors 
	}
	IJ.renameResults("Results","Final");
  vec=Array.concat(x,y);
	return vec;
}




/*********************************************************************************************************/

/* Find COM of droplets (can be done all at once) */
function COMDrop(stk){
	selectWindow(stk);
 getDimensions(width, height, channels, slices, frames);
	run("Median 3D...", "x=1 y=1 z=1");
	run("Gaussian Blur...", "sigma=2 stack");
	run("Auto Threshold", "method=Otsu white stack use_stack_histogram");
	run("3D Fill Holes");
	rename("dropmask");

	x=newArray(frames);
	y=newArray(frames);
	z=newArray(frames);
	R1=newArray(frames);
	R2=newArray(frames);
	R3=newArray(frames);
	Rmean=newArray(frames);

//	waitForUser("comdrop");
	wait(300);
 setBatchMode("hide");
	
	for (t=1; t<frames+1; t++){
		  selectWindow("dropmask");
			run("Duplicate...", "title=tmpDrop duplicate frames="+t);
			run("3D Objects Counter", "threshold=128 slice=22 min.=100 max.=400000 objects statistics");
	
			wait(50);
	
			objFound=nResults;
			//	print(objFound);
			
				//		sel=vecCheck(35,105,20,70);
	sel=0;
			if (isNaN(sel) || (objFound<1)){
				x[t-1]=x[t-2];
				y[t-1]=y[t-2];
				z[t-1]=z[t-2];
				Rmean[t-1]=Rmean[t-2];
			}
			else {
				x[t-1]=getResult("X", sel);
				y[t-1]=getResult("Y", sel);
				z[t-1]=getResult("Z", sel);
				Rmean[t-1]=getResult("Mean dist. to surf. (µm)", sel);
			}
			if (isOpen("Results")){selectWindow("Results"); run("Close");}
			/*
			selectWindow("Objects map of tmpDrop");
			setThreshold(1, 1);
	  	run("3D Ellipsoid Fitting", " ");
			R1[t-1]=getResult("R1(unit)", sel);
			R2[t-1]=getResult("R2(unit)", sel);
			R3[t-1]=getResult("R3(unit)", sel);
			Rmean[t-1]=(R1[t-1]+R2[t-1]+R3[t-1])/3;
			close("Ellipsoids");
			*/
			
			close("Objects map of tmpDrop");	
			close("tmpDrop");
			}
	wait(2000);
	setBatchMode("show");
	wait(4000);
	
//	waitForUser("drop");

	IJ.renameResults("Final","Results");
	for(j=0;j<(frames);j++){
				setResult("xDrop", j, x[j]);
				setResult("yDrop", j, y[j]);
				setResult("zDrop", j, z[j]);
		//		setResult("R1Drop", j, R1[j]);
		//		setResult("R2Drop", j, R2[j]);
		//		setResult("R3Drop", j, R3[j]);
				setResult("Rmean", j, Rmean[j]);
		}
	IJ.renameResults("Results","Final");
	vec=Array.concat(Array.concat(x,y),z);
	
	return vec;	
}





/*********************************************************************************************/

function correct_convex(){
for (i=1; i<nSlices; i++){
	setSlice(i);
	getStatistics(area, mean, min, max, std, histogram);
	if (mean>0) {
		run("Create Selection");
		run("Convex Hull");
		run("Fill", "slice");
		run("Select None");
	}
}
}


/*********************************************************************************************************/

function correctThreshold(){
	selectWindow("Corrected");
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Duplicate...", "title=tmp1 duplicate frames=1");
	run("Gaussian Blur 3D...", "x=4 y=4 z=4");
	selectWindow("Corrected");
	rename("Corrected1");
	run("Gaussian Blur 3D...", "x=2 y=2 z=2");
	run("Duplicate...", "title=tmp0 duplicate frames=2-"+frames);
	run("Concatenate...", "  title=tmp2 open image1=tmp1 image2=tmp0 image3=[-- None --]");
	
	Stack.getDimensions(width, height, channels, slices, frames);

	for (i = 1; i < slices+1; i++) {
		for (j = 1; j < frames+1; j++) {
			Stack.setPosition(1,i,1);
			run("Copy");
			Stack.setPosition(1,i,j);
			run("Paste");
		}
	}
	imageCalculator("Subtract create 32-bit stack", "Corrected1","tmp2");
	rename("Corrected");
	close("tmp2");
	close("Corrected1");

	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	setMinAndMax(min, max);
	run("8-bit");
}


/*********************************************************************************************************/

function testThreshold(name){
	selectWindow(name);
	run("Duplicate...", "title=tmpanalysis duplicate frames=2");
  Stack.getStatistics(voxelCount, mean, min, max, stdDev);
 if (mean>80){
		test=0;
	}
	else { 
	 	test=1;
	}	 	
	close("tmpanalysis");
	print(mean);
	return test;	
	
}





/*********************************************************************************************************/

function createResultTable(n){
for (t = 0; t <n; t++) {
	//cell
	setResult("x0", t, 0);
	setResult("y0", t, 0);
	setResult("z0", t, 0);
	setResult("V0", t, 0);
	setResult("x", t, 0);
	setResult("y", t, 0);
	setResult("z", t, 0);
	setResult("V", t, 0);
	setResult("R1", t, 0);
	setResult("R2", t, 0);
	setResult("R3", t, 0);
	setResult("XY0", t, 0);
	setResult("XZ0", t, 0);
	setResult("YZ0", t, 0);
		// droplet
	setResult("xDrop", t, 0);		
	setResult("yDrop", t, 0);		
	setResult("zDrop", t, 0);	
	setResult("Rmean", t, 0);		
	setResult("R1Drop", t, 0);				
	setResult("R2Drop", t, 0);		
	setResult("R3Drop", t, 0);
		// antigen recruitment
	setResult("left", t, 0);		
	setResult("right", t, 0);		
	setResult("ratio", t, 0);	
		// nucleus
	setResult("xNuc", t, 0);		
	setResult("yNuc", t, 0);		
	setResult("zNuc", t, 0);		
	setResult("VNuc", t, 0);	
	setResult("R1Nuc", t, 0);		
	setResult("R2Nuc", t, 0);		
	setResult("R3Nuc", t, 0);		
	setResult("XY0Nuc", t, 0);		
	setResult("XZ0Nuc", t, 0);		
	setResult("YZ0Nuc", t, 0);		
	setResult("XY1Nuc", t, 0);		
	setResult("XZ1Nuc", t, 0);		
	setResult("YZ1Nuc", t, 0);		
		//MTOC
	setResult("MeanDist",t,0);
	setResult("Xcen", t, 0);		
	setResult("Ycen", t, 0);		
	setResult("Zcen", t, 0);		
	
	
	}
IJ.renameResults("Results","Final");
}



/*********************************************************************************************************/

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
	//	print(sel);
	return sel;
}


/*********************************************************************************************************/

function correctMinMax(stk){
	selectWindow(stk);
	run("Duplicate...", "title=tmp8bit duplicate");
	run("Median...", "radius=3 stack");
	Stack.getStatistics(voxelCount, mean, min, max, stdDev) // Calculates and returns stack statistics. 
	close();
	selectWindow(stk);
	setMinAndMax(min, max);
}




/*************************Distance********************************************************************************/

function ComputeCenDist(Xcen, Ycen, Zcen){
	selectWindow("Cell");
	getDimensions(width, height, channels, slices, frames);
	CenDist=newArray(frames-1);
	

		// CORRECT noise 
			roiManager("reset");
			selectWindow("Drop");
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			print(mean);
			print(stdDev);
			run("Duplicate...", "title=tmp duplicate frames=1-1");
			setThreshold(0, 0);
		//	setOption("BlackBackground", false);
		//	run("Convert to Mask");
			run("Create Selection");
			roiManager("Add");
			selectWindow("Drop");
			roiManager("Select", 0);
			setForegroundColor(Math.floor(mean),Math.floor(mean),Math.floor(mean));
			run("Fill", "stack");
  		run("Add Specified Noise...", "stack standard="+stdDev);
			close("tmp");
			
			for(t = 1; t < frames; t++) {
					if ((Xcen[t-1]*Ycen[t-1]*Zcen[t-1])!=0){
					selectWindow("Drop");
					Stack.setFrame(t);
					run("Duplicate...", "title=tmp duplicate frames="+t);
					run("Distance Transform 3D");
					rename("Distance");
					selectWindow("Distance");
					setSlice(Zcen[t-1]);
					quantif = getPixel(Xcen[t-1],Ycen[t-1]);
					print(quantif);
					CenDist[t-1]=quantif;
					close("Distance");
					close("tmp");
			}
			else {
			CenDist[t-1]=NaN;
			}
		}
	wait(500);

		IJ.renameResults("Final","Results");
		for(j=0;j<(frames-1);j++){
				setResult("MeanDist", j, CenDist[j]);
		}
		IJ.renameResults("Results","Final");
}


TrackMTOC("dropmask", "Cel")
/*********************************************************************/
function TrackMTOC(dropmask, cell){
	selectWindow(cell);
	getDimensions(width, height, channels, slices, frames);			
	run("Duplicate...", "title=Centro_all duplicate frames=1-"+frames+"");
	correctMinMax("Centro_all"); // convert to 8 bit
	run("8-bit");
	// this median filter (on isotropic images) it is necessay in some movie
	run("Median 3D...", "x=2 y=2 z=2");

	selectWindow(dropmask);
	run("Invert", "stack");
	run("Divide...", "value=255 stack");
	imageCalculator("Multiply stack", cell, dropmask);  // exclude the droplet from MTOC (avoid distance=0);

	selectWindow(dropmask);
	run("Multiply...", "value=255 stack");
	run("Invert", "stack");
	
	Xcen=newArray(frames);
	Ycen=newArray(frames);
	Zcen=newArray(frames);
	CenDist=newArray(frames);
 

	/* LOOP ON FRAMES */
	for(i=2;i< frames ;i++) {
	//	 setBatchMode("hide");
 		selectWindow(dropmask); 
		run("Duplicate...", "title=drop duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
		run("Distance Transform 3D");
		
		selectWindow("Centro_all");	
		run("Duplicate...", "title=centro duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
		selectWindow("centro");
		Med = getValue("Median");
		Mean = getValue("Mean");
		StDev = getValue("StdDev"); //print(Mean); print(StDev); print(Med);
		Noi = Mean+5*StDev;
		//run("3D Maxima Finder", "radiusxy=5 radiusz=3 noise="+Med+"");
		run("3D Maxima Finder", "radiusxy=5 radiusz=5 noise="+Noi+"");
   // setBatchMode("show");
	
		
		// Checking that there was indeed a peak detection, otherwise putting NaN
		selectWindow("Results");
							
		Nbpeak = nResults();
		print(Nbpeak);
		if (Nbpeak>0) {
			if (Nbpeak>1) {
				sel=selectMax0(Nbpeak);
			}
			else{
				sel=0;
			}
			if (!isNaN(sel)){
				Xmax= getResult("X", sel);
				Ymax = getResult("Y", sel);
				Zmax = getResult("Z", sel)+1;
				selectWindow("Distance");
				setSlice(Zmax);
				quantif = getValue(Xmax, Ymax);
				print("Distance= "+quantif);
					
				CenDist[i-1]=quantif;
				Xcen[i-1] = Xmax;
				Ycen[i-1] = Ymax;
				Zcen[i-1] = Zmax;
			} else {
				CenDist[i-1]=NaN;
				Xcen[i-1] = NaN;
				Ycen[i-1] = NaN;
				Zcen[i-1] = NaN;
			}
			if ((Xmax==0) | (Ymax==0)){
				CenDist[i-1]=NaN;
				Xcen[i-1] = NaN;
				Ycen[i-1] = NaN;
				Zcen[i-1] = NaN;
			}
		}
		else
		{
			CenDist[i-1]=NaN;
			Xcen[i-1] = NaN;
			Ycen[i-1] = NaN;
			Zcen[i-1] = NaN;
			}
			
			close("centro");
			close("drop");
			close("peaks");
			close("Results");
			close("Distance");
			// create results Table
	
	}
	wait(500);

		IJ.renameResults("Final","Results");
		for(j=0;j<(frames-1);j++){
				setResult("MeanDist", j, CenDist[j]);
				setResult("Xcen", j, Xcen[j]);
				setResult("Ycen", j, Ycen[j]);
				setResult("Zcen", j, Zcen[j]);
		}
		IJ.renameResults("Results","Final");
}







/*********************************************************************/
function selectMax0(Nbpeak) { 
// Select the local peak with max intensity
	d=newArray(Nbpeak);
	V=newArray(Nbpeak);
	for (i = 0; i < Nbpeak; i++) {
			Xmax= getResult("X", i);
			Ymax = getResult("Y", i);
			Zmax = getResult("Z", i)+1;
			
			if ((Xmax==0) | (Ymax==0)){ // eliminate points on the border
					V[i]=0;
		  }
		  else{
			 	V[i] = getResult("V", i);
		  }			
			selectWindow("Distance");
			setSlice(Zmax);
			d[i] = getPixel(Xmax, Ymax);
	}

	apos=Array.rankPositions(d); 
	sel1=apos[0];
	sel2=apos[1];

	if (d[sel1]>50) {
		sel=NaN;
	}
	else{
		if (d[sel2]<50){
			if (V[sel1]*1.30<V[sel2]){
  		sel=sel2;
  	}
  	else { 
  		sel=sel1;
  	}
		}
		else{
			sel=sel1;
		}
		}
	return sel;
}
	




/*********************************************************************/

function selectMax(Nbpeak) { 
// Select the local peak with max intensity
	d=newArray(Nbpeak);
	V=newArray(Nbpeak);
	for (i = 0; i < Nbpeak; i++) {
			Xmax= getResult("X", i);
			Ymax = getResult("Y", i);
			Zmax = getResult("Z", i)+1;
			
			if ((Xmax==0) | (Ymax==0)){
					V[i]=0;
		  }
		  else{
			 	V[i] = getResult("V", i);
		  }			
			selectWindow("Distance");
			setSlice(Zmax);
			d[i] = getPixel(Xmax, Ymax);
	}

	apos=Array.rankPositions(V); 
	sel1=apos[Nbpeak-1];
	sel2=apos[Nbpeak-2];
	if (V[sel1]<(V[sel2]*1.30)){
  	if (d[sel1]<d[sel2]){		
  		sel=sel1;
  	}
  	else { 
  		sel=sel2;
  	}
  }
  else {
			sel=sel1;
  }
	return sel;
}
	





