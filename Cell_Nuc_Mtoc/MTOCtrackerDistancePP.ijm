
myDir = getDirectory("Choose a Directory ");

list = getFileList(myDir);

     for (k=0; k<list.length; k++) {
     	print(list[k]);
        if (!(endsWith(list[k], "/")) & (endsWith(list[k], "drop.tif"))){
			name=list[k];
		   
			open(myDir+list[k]);
			getDimensions(width, height, channels, slices, frames);
			rename("Drop");
		
			CenDist=newArray(frames-1);
			Xcen=newArray(frames);
			Ycen=newArray(frames);
			Zcen=newArray(frames);




nameDrop=list[k];
nameRes=substring(list[k],0,lengthOf(list[k])-9)+"_MTOC.txt";

print(nameRes);

run("Table... ", "open="+myDir+nameRes);
IJ.renameResults("Results");

nFrame=nResults;

for (t = 1; t < nFrame; t++) {
		print(t);
	Xcen[t-1]=getResult("Xcen", t);
	Ycen[t-1]=getResult("Ycen", t);
	Zcen[t-1]=Math.round(getResult("Zcen", t)*136/21);
	print(t);
}
close("Results");

Array.print(Xcen);
Array.print(Ycen);
Array.print(Zcen);

/* TREAT THE DROPLET*/

slices=136;
			
// setBatchMode("hide");
		
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
			

/* THRESHOLD*/	
      selectWindow("Drop");
      run("Select None"); 
			run("Median 3D...", "x=2 y=2 z=2");
			run("Gaussian Blur...", "sigma=2 stack");
			run("Auto Threshold", "method=Otsu white stack use_stack_histogram");
			run("3D Fill Holes");

// setBatchMode("show");

				

for(t = 1; t < nFrame; t++) {
	if ((Xcen[t-1]*Ycen[t-1]*Zcen[t-1])!=0){
			selectWindow("Drop");
			Stack.setFrame(t);
			run("Duplicate...", "title=tmp duplicate frames="+t);
			
			//run("Distance transform (3D) REQUIRING ISOTROPIC IMAGE!");
			run("Distance Transform 3D");
			
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

			// create results Table
			for(j=0;j<(frames-1);j++){
				setResult("MeanDist", j, CenDist[j]);
				setResult("Xcen", j, Xcen[j]);
				setResult("Ycen", j, Ycen[j]);
				setResult("Zcen", j, Zcen[j]);
			}
			updateResults();
			
		
			//Stack.setDisplayMode("composite");

			selectWindow("Results");
			saveAs("Results", myDir+name+"_distMTOC.txt");

			
		   	close("Results");
		   	run("Close All");
		   
		   	print(list[k]+" done");
   }
}



