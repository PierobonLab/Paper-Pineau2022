		//20201005  Judith Pineau/ 062021 PP
// Centrosome - droplet distance 3D batch
// uses isotropic images


myDir = getDirectory("Choose a Directory ");

list = getFileList(myDir);

     for (k=0; k<list.length; k++) {
     	print(list[k]);
        if (!(endsWith(list[k], "/")) & (endsWith(list[k], ".tif"))){
			name=list[k];
			path=substring(name,0,lengthOf(name)-4);
			print(path);
			beadTitle=path+"_drop.tif";   
			open(myDir+list[k]);
			getDimensions(width, height, channels, slices, frames);
		
			// convert stack to hyperstack
			// slices = 21;
			//run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices="+slices+" frames="+T+" display=Color");
			
			imageTitle=getTitle();
			rename("Image");
		//	selectWindow(name);px
			getDimensions(width, height, channels, slices, frames);			

			/* interpolate*/
			// change dz
			Stack.getDimensions(width, height, channels, slices, frames);
			
			px=0.325;
			nInterp=Math.round(0.7/px*slices);    // 45 for 0.325µm 136 for 0.108µm 
			
			run("Size...", "width="+width+" height="+height+" depth="+nInterp+" time="+frames+" average interpolation=Bicubic");
			// change voxel size
			run("Properties...", "channels="+channels+" slices="+nInterp+" frames="+frames+" pixel_width="+px+" pixel_height="+px+" voxel_depth="+px+" frame=[30 sec] global");
	
			Stack.getDimensions(width, height, channels, slices, frames);
		
			
			nbTime=frames;
			selectWindow("Image");
			Stack.setChannel(1);
			getMinAndMax(min, max);
			setMinAndMax(min, max);
			Stack.setChannel(3);
			getMinAndMax(min, max);
			setMinAndMax(min, max);


			

			selectWindow("Image");
		//	run("8-bit");
			run("Split Channels");
			getDimensions(width, height, channels, slices, frames);			

			selectWindow("C3-Image");
			run("Duplicate...", "title=drop_all duplicate frames=2-"+frames+"");
	//		saveAs("Tiff", myDir+beadTitle);
			rename("drop_all");

			
			selectWindow("C1-Image");
			run("Duplicate...", "title=Centro_all duplicate frames=2-"+frames+"");
			run("8-bit");
			run("Median 3D...", "x=2 y=2 z=2");
					

			
      selectWindow("drop_all");


			/* CORRECT noise */
	/*	
		 roiManager("reset");
			selectWindow("drop_all"); 
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			run("Duplicate...", "title=tmp duplicate frames=1-1");
			setThreshold(0, 0);
		//	setOption("BlackBackground", false);
		//	run("Convert to Mask");
			run("Create Selection");
			roiManager("Add");
			selectWindow("drop_all");
			roiManager("Select", 0);
			setColor(mean);
			run("Fill", "stack");
  		run("Add Specified Noise...", "stack standard="+stdDev);
			close("tmp");


      /* THRESHOLD*/	
      selectWindow("drop_all"); 
			run("Median 3D...", "x=2 y=2 z=2");
			run("Gaussian Blur...", "sigma=2 stack");
			run("Auto Threshold", "method=Otsu white stack use_stack_histogram");
			run("3D Fill Holes");
		//	newImage("Mask", "8-bit black",width, height, slices);

		Stack.getDimensions(width, height, channels, slices, frames);
				
			CenDist=newArray(frames-1);
			Xcen=newArray(frames);
			Ycen=newArray(frames);
			Zcen=newArray(frames);




			/* LOOP ON FRAMES */

			for(i=1;i< frames ;i++) {
setBatchMode("hide");
							selectWindow("drop_all");
							run("Duplicate...", "title=drop duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
					
							//rename("drop");

							selectWindow("Centro_all");
							run("Duplicate...", "title=centro duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
						

					
							// CHECK PIXEL SIZE ISOTROPIC
						//	run("Properties...", "channels=1 slices="+nInterp+" frames=1 unit=um pixel_width=0.325 pixel_height=0.325 voxel_depth=0.325");
				
							//run("Distance transform (3D) REQUIRING ISOTROPIC IMAGE!");
							selectWindow("drop");
							run("Distance Transform 3D");
							
							selectWindow("centro");
							Med = getValue("Median");
							Mean = getValue("Mean");
							StDev = getValue("StdDev");
							//print(Mean); print(StDev); print(Med);
							Noi = Mean+5*StDev;
							//run("3D Maxima Finder", "radiusxy=5 radiusz=3 noise="+Med+"");
							run("3D Maxima Finder", "radiusxy=5 radiusz=5 noise="+Noi+"");
							
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
							else {
								CenDist[i-1]=NaN;
								Xcen[i-1] = NaN;
								Ycen[i-1] = NaN;
								Zcen[i-1] = NaN;
								}
							//selectWindow("C2-Framei");
							//close();

print(CenDist[i-1]);
							
							close("centro");
							close("drop");
							close("peaks");
							close("Results");
							close("Distance");
										}
			// create results Table
			for(j=0;j<(frames-1);j++){
				setResult("MeanDist", j, CenDist[j]);
				setResult("Xcen", j, Xcen[j]);
				setResult("Ycen", j, Ycen[j]);
				setResult("Zcen", j, Zcen[j]);
			}
			updateResults();

		   	name0 =path;

			//Stack.setDisplayMode("composite");

			selectWindow("Results");
			saveAs("Results", myDir+name+"_MTOC.txt");

			
		   	close("Results");
		 	run("Close All");
		   setBatchMode("show");
		   	print(list[k]+" done");
   }
}
/*
sel=selectMax0(3);
print(sel);
*/

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
	


