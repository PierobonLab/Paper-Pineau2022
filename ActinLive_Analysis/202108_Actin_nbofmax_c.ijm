// Judith Pineau 20210814
// Measure number of actin hotspots and their distance from the droplet

myDir = getDirectory("Choose a Directory ");
run("Set Measurements...", "area mean standard modal min center integrated redirect=None decimal=3");
list = getFileList(myDir);
Maskdir= myDir + "/MaskCheck/"; 
print(Maskdir); 

     for (k=0; k<list.length; k++) {
     	print(list[k]);
        if (!(endsWith(list[k], "/")) & (endsWith(list[k], ".tif"))){
			name=list[k];
			
			path=substring(name,0,lengthOf(name)-4);
			print(path);
		   
			open(myDir+name);
			open(Maskdir+name+"Cell.tif");
			open(Maskdir+name+"drop.tif");

			selectWindow(name+"Cell.tif");
			rename("MaskCell");
			selectWindow(name+"drop.tif");
			rename("Mask");

			selectWindow(name);
			getDimensions(width, height, channels, slices, frames);
			//REMEMBER TO CHANGE ACCORDING TO NUMBER OF Z
			T =nSlices/42;
			run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices=21 frames="+T+" display=Color");
			
			imageTitle=getTitle();
			selectWindow(name);
			rename("Image");
			getDimensions(width, height, channels, slices, frames);			
			nbTime=frames;

			selectWindow("Image");
			run("Split Channels");
			getDimensions(width, height, channels, slices, frames);			
			selectWindow("C2-Image");
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			setMinAndMax(min, max);
			run("8-bit");
			
			
		

			selectWindow("C1-Image");
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			setMinAndMax(min, max);
			run("8-bit");
			
			run("Duplicate...", "duplicate frames=1-"+frames+"");
			selectWindow("C1-Image-1");
			run("Bleach Correction", "correction=[Simple Ratio]");
			selectWindow("DUP_C1-Image-1");
			rename("Factin_all");
			

			nb_max=newArray(frames-1);
			sd_maxdist = newArray(frames-1);
			mean_maxdist =newArray(frames-1);
			
			for(i=2;i<frames ;i++) {
														
							slices=21;
							print(i);
							
							// Processing F-actin
							selectWindow("Factin_all");
							run("Duplicate...", "title=Factin duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
							
							selectWindow("Factin"); 
							Stack.getStatistics(voxelCount, mean, min, max, stdDev);
							print(voxelCount);
							setMinAndMax(min, max);
							run("Median (3D)");
	
							selectWindow("Median of Factin");
							run("Z Project...", "projection=[Max Intensity]");
	
							run("Find Maxima...", "prominence=30 exclude output=[Point Selection]");
							roiManager("Add");
							
							//if need cell mask
							selectWindow("MaskCell");
							run("Duplicate...", "title=Factin_mask duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
							selectWindow("Factin_mask");

							//getting drop mask at right time
							selectWindow("Mask");
							run("Duplicate...", "title=Rdrop duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
			
							selectWindow("Rdrop");
							run("Z Project...", "projection=[Max Intensity]");
							selectWindow("MAX_Rdrop");
							run("Invert", "stack");
							//run("Properties...", "channels=1 slices=21 frames=1 unit=um pixel_width=0.325 pixel_height=0.325 voxel_depth=0.7");
							run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.325 pixel_height=0.325 voxel_depth=0.7");
							run("Distance Map (with Calibration)", "input=Rdrop implementation=ImageJ-Ops");
							rename("Distance");
			
							
							selectWindow("Distance");
							roiManager("select", 0);
							roiManager("measure");
							nbmaxpt = nResults;
							selectWindow("Results");
							Results_distances=newArray(nbmaxpt);
							for(j=0;j<(nbmaxpt);j++){
									Results_distances[j] = getResult("Mean", j);
				
							}
							Array.getStatistics(Results_distances, min, max, mean, stdDev);
							
							
							mean_maxdist[i-1]=mean;
							sd_maxdist[i-1]=stdDev;
							nb_max[i-1]=nbmaxpt;
							
							

							roiManager("deselect");
							roiManager("delete");
							close("Distance");
							close("Factin");
							close("Factin_mask");
							
							
							
							close("Result of Factin");			
							close("SUM_Result of Factin");
							close("Results");
							close("Rdrop");
							close("Result of drop");
							close("Median of Factin");
							close("MAX_Median of Factin");
							close("MAX_Rdrop");
			}


			
		   	name0 =path;
			Stack.getDimensions(width, height, channels, slices, frames);
			print(frames);
			close("Results");
			
			// create results Table
			for(j=0;j<(frames-1);j++){
				setResult("NbMax", j, nb_max[j]);
				setResult("AvgDist", j, mean_maxdist[j]);
				setResult("SDDist", j, sd_maxdist[j]);
				
				
			}
			updateResults();
			
			selectWindow("Results");
			saveAs("Results", myDir+name+"_Factin_Maximum_analysis.csv");
			
			
		   	close("Results");
		   	run("Close All");
		   call("java.lang.System.gc");
		   	print(list[k]+" done");
   }
}



