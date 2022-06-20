// requirement for measurements
run("Set Measurements...", "area mean standard min centroid center perimeter fit shape feret's nan redirect=None decimal=3");
run("3D OC Options", "volume centroid centre_of_mass bounding_box dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");

// load trans

// load the fluo (3D+t)


baseName=getTitle();

drop="drop";
trans="trans";
selectWindow(drop);
Stack.getDimensions(width, height, channels, slices, frames);
/*
if (slices>frames) {
	Stack.setDimensions(channels, frames, slices);
}
*/
setVoxelSize(1,1,1, "pixel");
selectWindow(trans);
Stack.getDimensions(width, height, channels, slices, frames);
if (slices>frames) {
	Stack.setDimensions(channels, frames, slices);
}
setVoxelSize(1,1,1, "pixel");
timepoints=nSlices;
// timepoints=20;

// create result table
createResultTable(timepoints);

//for each time point
for (t=0; t<timepoints; t++){
	// detect center of the droplet
	selectWindow(drop);
	time=t+1;
 	run("Duplicate...", "title=Drop3D duplicate frames="+time);
	v=detectCenterFluo();
	xdrop=v[0];
	ydrop=v[1];
	zdrop=v[2];
	R=v[3];
	// Array.print(v);
	close("Drop3D");
	wait(100);
	
//	waitForUser("fluo");


	// use xy in trans
	selectWindow(trans);
	setSlice(time);
	run("Duplicate...", "title=trans_frame");
	v=detectCenterTrans("trans_frame", xdrop, ydrop, R);
	xc=v[0];
	yc=v[1];
	Rt=v[2];
//	Array.print(v);
	wait(100);
	
//waitForUser("drop");

 	flag=findCell("trans_frame",xc,yc, Rt);
 	print(flag);
	wait(100);
	
// 	waitForUser("findcell");
	
 	// detect boundaries
 	if (flag==1) {
 		v=findEdges2("trans_frame", xc, yc, Rt);
 		left=v[0]*PI/180;
 		right=v[1]*PI/180;
 		Array.print(v);
 	}
 	else {
		left=PI/3;
		right=2*PI/3;
 	}
	selectWindow("trans_frame"); run("Close");
//	waitForUser("findedge");
	
	// transfer the zone in 3D or measure the average of the contact zone in just one plane???
	selectWindow(drop);
 	run("Duplicate...", "title=Drop3D duplicate frames="+time);
	v=maskDrop(xdrop, ydrop, zdrop, R, left, right);
  close("Drop3D");
  Array.print(v);
	wait(100);
//	waitForUser("Done");	
	print("DONE "+t); 	

	// report results
	IJ.renameResults("Final","Results");
	setResult("Time", t, t);
 	setResult("Fluo1", t, v[0]);
  setResult("Fluo2", t, v[1]);
	setResult("Ratio", t, v[2]);
	setResult("Area1", t, v[3]);
	setResult("Area2", t, v[4]);
	setResult("Left", t, left);
	setResult("Right", t, right);
	setResult("Angle", t, right-left);
	setResult("Cell", t, flag);
	setResult("X", t, xdrop);
  setResult("Y", t, ydrop);
	setResult("Z", t, zdrop);
	setResult("R", t, R);	
	IJ.renameResults("Results","Final");
}

saveAs("results", "/home/paolo/Documents/PROJECTS/Judith/Recruit_correct/"+baseName+"Final.txt");
print("SAVED"); 	



/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/
// detect center in fluo
function detectCenterFluo(){
	selectWindow("Drop3D");
	run("Despeckle", "stack");
	run("Auto Threshold", "method=Default white stack use_stack_histogram");
	run("Dilate", "stack");
	run("Erode", "stack");
	run("Fill Holes", "stack");
	run("3D Objects Counter", "threshold=128 slice=10 min.=100 max.=150000 statistics");
	
	//get x, y, z
	IJ.renameResults("Statistics for Drop3D","Results");
	XM=getResult("XM", 0);
	YM=getResult("YM", 0);
	ZM=getResult("ZM", 0);
	z=Math.round(ZM);
  wait(200);
  selectWindow("Results"); run("Close");

  // detect radius (max in central z)
	selectWindow("Drop3D");
	setSlice(z);
	run("Duplicate...", "title=Dslice");
	selectWindow("Dslice");
  run("Analyze Particles...", "display clear add");
	radius=Math.round(getResult("Feret", 0)/2);

	close("Dslice");
//	wait(200);
	 run("Clear Results");
//	selectWindow("Results"); run("Close");		
	selectWindow("ROI Manager"); run("Close");
	return newArray(XM,YM,ZM,radius); 
}



/****************************************************************************************************/
// detect center and radius in trans (more precise for x and y, necessary to be used in the edge analysis)
function detectCenterTrans(trans_frame, XM, YM, radius){
	selectWindow(trans_frame);
	// crop around the fluo center
	L=radius*2+8;
	makeRectangle(XM-L/2-6, YM-L/2, L, L); // shift 6 due to aberrations
	run("Duplicate...", "title=Tslice");
	resetMinAndMax();
	run("8-bit");
	run("Duplicate...", "title=Tmask");
	run("Variance...", "radius=1");
	run("Auto Threshold", "method=Triangle white");
	run("Convert to Mask");
	run("Fill Holes");
	run("Erode");
	run("Analyze Particles...", "size=200-Infinity circularity=0.80-1.00 display exclude clear add");
	selectWindow("Tmask"); run("Close");
	
	// get x and y 
	if (nResults<1){
		x=XM-6;
		y=YM;
		Rt=radius;
	}
	else {
		selectWindow("Tslice");
		x=XM-L/2-6+getResult("X", 0)+1;
		y=YM-L/2+getResult("Y", 0);
    makeLine(1, L/2, L, L/2, 2);
	 	profile = getProfile();	
//	 	Array.print(profile);
//    Plot.create("Profile", "X", "Value", profile);
    minLocs= Array.findMinima(profile, 20,1);
//	Array.print(minLocs);
		a=minLocs[0];
	  b=minLocs[1];
		left=Math.min(a,b);
		right=Math.max(a,b);
		Rt=(right-left)/2;
		Xcorrect=((right+left)/2);
		if (Math.abs(Xcorrect-getResult("X", 0))>1){
			x=XM-L/2-6+Xcorrect+1;
		}
		print(x); print(y); print(Xcorrect);
	}
	wait(200);
	 run("Clear Results");
//	selectWindow("Results"); run("Close");
	selectWindow("Tslice"); run("Close");
	roiManager("reset");

	return newArray(x,y, Rt);

}


/****************************************************************************************************/
/*
function findEdges(trans_frame, xc, yc, R) { 
// function description: it computes the synapse edge left and right for a given frame and a fiven (xc,yc)
	selectWindow(trans_frame);
	getDimensions(width, height, channels, slices, frames);

	xcm=Math.ceil(width/2);
	ycm=Math.ceil(height/2);
	run("Gaussian Blur...", "sigma=2 stack");
	run("Variance...", "radius=1 stack");
	resetMinAndMax();
	xtr=xcm-xc;
	ytr=ycm-yc;
	run("Translate...", "x="+xtr+" y="+ytr+" interpolation=None");
	
	dsmall=Rt;
	dbig=dsmall+;
	makeOval(xcm-dsmall/2, ycm-dsmall/2, dsmall, dsmall);
	run("Clear", "slice");
	makeOval(xcm-dbig/2, ycm-dbig/2, dbig, dbig);
	run("Clear Outside");
	makeRectangle(xcm, 1, xcm, height);
	run("Clear", "slice");
	run("Select None");
  resetMinAndMax();
  run("Polar Transformer", "method=Polar degrees=360 default_center for_polar_transforms,");

	resetMinAndMax();
	linepos=floor((dbig+dsmall)/4);
	makeLine(linepos, 1, linepos, 360, dbig-dsmall+2);
	//run("Plot Profile");
	profile = getProfile();	
//  Plot.create("Profile", "X", "Value", profile);
  
  waitForUser;

  minLocs= Array.findMinima(profile, 30);
	Array.print(minLocs);

	if ((lengthOf(minLocs))>3){
		a=minLocs[2];
	  b=minLocs[3];
		left=Math.min(a,b)*PI/180;
		right=Math.max(a,b)*PI/180;
	}
	else {
	left=NaN;
	right=NaN;
	}
	return newArray(left, right); // these are two angles in deg tha identify the synapse in polar coordinates
}
*/

/****************************************************************************************************/
function maskDrop(xc, yc, zc, radius, left, right) { 
// function description
Z=Math.round(zc);
selectWindow("Drop3D");
run("Duplicate...", "title=Fslice duplicate range="+Z+"-"+Z);
// select slice and mask
run("Duplicate...", "title=mask");
run("Auto Threshold", "method=MaxEntropy white");
run("Create Selection");
roiManager("reset");
roiManager("Add");

selectWindow("mask");
R=radius*1.5;
makePolygon(xc, yc, xc-R*sin(left), yc-R*cos(left),  xc-R, yc, xc-R*sin(right), yc-R*cos(right));
roiManager("Add");
roiManager("Select", newArray(0,1));
roiManager("AND"); // synapse saved in ROI 2
roiManager("Add");
//roiManager("Select", newArray(0,2));
//roiManager("XOR"); // antisynapse saves in ROI 3
//roiManager("Add");
makePolygon(xc, yc, xc+R*sin(PI/3), yc-R*cos(PI/3),  xc+R, yc, xc+R*sin(2*PI/3), yc-R*cos(2*PI/3));
roiManager("Add");
roiManager("Select", newArray(0,3));
roiManager("AND"); 
roiManager("Add"); // antisynapse saved in ROI 4


// apply ROI measurements to fluoimage
selectWindow("Fslice");
roiManager("Select", 2);
run("Measure");
selectWindow("Fslice");
roiManager("Select", 4);
run("Measure");
F1=getResult("Mean", 0);
F2=getResult("Mean", 1);
A1=getResult("Area", 0);
A2=getResult("Area", 1);
wait(100);
run("Clear Results");
// selectWindow("Results"); run("Close");
Ratio=F1/F2;
roiManager("reset");
close("mask");
close("Fslice");
return newArray(F1, F2, Ratio, A1, A2);
}


/****************************************************************************************************/
function diff(v){
// differentiate a vector v (produce a n-1 vector v(i)-v(i-1)
  n=lengthOf(v);
  df= newArray(n-1);
  for (i = 0; i < (n-1); i++) {
    df[i]=v[i+1]-v[i];
  }
 return df;
}



/****************************************************************************************************/
//ANYWAY: it is a good idea to perfom first the variance and then smooth with a filter, the opposite washed out the pattern of the cell (it actually depends whether we use cell-medium contrast or intracellular contrast to identify the cell
function findEdges2(trans_frame, xc, yc, Rt) { 
// function description: it computes the synapse edge left and right for a given frame and a given (xc,yc)
	selectWindow(trans_frame);
	run("Select None");
	getDimensions(width, height, channels, slices, frames);

	xcm=Math.ceil(width/2);
	ycm=Math.ceil(height/2);
	resetMinAndMax();
	xtr=xcm-xc;
	ytr=ycm-yc;
	run("Translate...", "x="+xtr+" y="+ytr+" interpolation=None");
	
	dsmall=Rt*2;
	dbig=dsmall+24;
	makeOval(xcm-dsmall/2, ycm-dsmall/2, dsmall, dsmall);
	run("Clear", "slice");
	makeOval(xcm-dbig/2, ycm-dbig/2, dbig, dbig);

	run("Clear Outside");
	makeRectangle(xcm, 1, xcm, height);
	run("Clear", "slice");
	run("Select None");
  resetMinAndMax();
  makePoint(xcm, ycm);
  run("Polar Transformer", "method=Polar degrees=360 default_center for_polar_transforms,");
  selectWindow("Polar Transform of "+trans_frame);
  getDimensions(width, height, channels, slices, frames);
  makeRectangle(1, 90, width, 180);
  wait(100);
	run("Duplicate...", "title=tmp1 duplicate");
	run("Duplicate...", "title=tmp2 duplicate");
	setThreshold(1, 65535);
	run("Convert to Mask");
	run("Create Selection");
	roiManager("reset");
	roiManager("Add");
	selectWindow("tmp2"); run("Close");
	selectWindow("tmp1");
	roiManager("Select", 0);
	run("Duplicate...", "title=tmp");
	selectWindow("tmp1"); run("Close");
	selectWindow("tmp");
	run("Rotate 90 Degrees Right");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	run("Z Project...", "projection=[Standard Deviation]");
	selectWindow("STD_Reslice of tmp");
	run("Select All");
	profile = getProfile();
//	Array.print(profile);	
//	Plot.create("Profile", "X", "Value", profile);

	// left part
	profileLeft=Array.slice(profile,5,90);
	minLeft= Array.findMinima(profileLeft, 20,1);
//	print("LEFT:");Array.print(minLeft);
	
	profileRight=Array.slice(profile,90,175);
	minRight= Array.findMinima(profileRight, 20,1);
//	print("RIGHT:");Array.print(minRight);
	
	if ((lengthOf(minLeft))>0){
//		Array.getStatistics(minLeft, min, max, mean, std);
		left=minLeft[0]+5;
	}
	else{
 		left=60;
	}
	if  ((lengthOf(minRight))>0){
//		Array.getStatistics(minRight, min, max, mean, std);
		right=minRight[0]+90;	
	}
	else {
		right=120;
	}
	selectWindow("tmp"); run("Close");
	selectWindow("Polar Transform of "+trans_frame); run("Close");
	selectWindow("STD_Reslice of tmp"); run("Close");
	selectWindow("Reslice of tmp"); run("Close");
	roiManager("reset");
	return newArray(left, right); // these are two angles in deg tha identify the synapse in polar coordinates
}


/****************************************************************************************************/

function findCell(trans_frame, xc, yc, Rt) { 
// function description
  selectWindow(trans_frame);
// measure in the bead

   makeRectangle(xc-3, yc-3, 6, 6);
   getStatistics(area, mean, min, max, std, histogram);
	 eta0=std/mean;

// measure in front of the bead
   makeRectangle(xc-2*Rt-3, yc-3, 6, 6);
	 getStatistics(area, mean, min, max, std, histogram);
	 eta1=std/mean;

	if (eta1>1.5*eta0){
		flag=1;
	}
	else{
		flag=0;	
	}
	run("Select None");
	
	return flag;
}


function createResultTable(n){
for (t = 0; t <=n; t++) {
	setResult("Time", t, 0);
	setResult("Fluo1", t, 0);
	setResult("Fluo2", t, 0);
	setResult("Ratio", t, 0);
	setResult("Area1", t, 0);
	setResult("Area2", t, 0);
	setResult("Left", t, 0);
	setResult("Right", t, 0);
	setResult("Angle", t, 0);
	setResult("Cell", t, 0);
	setResult("X", t, 0);
  setResult("Y", t, 0);
	setResult("Z", t, 0);
	setResult("R", t, 0);

	}
IJ.renameResults("Results","Final");
}