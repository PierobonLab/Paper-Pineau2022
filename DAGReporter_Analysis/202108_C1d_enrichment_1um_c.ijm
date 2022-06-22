// Judith Pineau 20210803
// Use Masks (in MaskCheck folder) and movies (bleach corrected beforehand) to measure the enrichment in DAG near the droplet (1um)
// This is a slightly modified version of the actin enrichment macro, therefore the DAG image is referred to as "Factin" here.

// Measuring sum intensity near droplet, total intensity, ratio, and total area near droplet (the disk), area of actin near droplet, and 

myDir = getDirectory("Choose a Directory ");

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
			selectWindow("C1-Image");
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			setMinAndMax(min, max);

			selectWindow("C2-Image");
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			setMinAndMax(min, max);

			rename("Factin_all");
			


			Sum_in1um=newArray(frames-1);
			Sum_totalFactin=newArray(frames-1);	
			RatioSum1um_total=newArray(frames-1);
			
			
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
							
							
							//getting total F-actin volume
							selectWindow("MaskCell");
							run("Duplicate...", "title=Factin_mask duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
							selectWindow("Factin_mask");

							
							imageCalculator("Multiply create stack", "Factin","Factin_mask");
							selectWindow("Result of Factin");
							
							setSlice(10);
							
							
							//getting drop volume
							selectWindow("Mask");
							run("Duplicate...", "title=Rdrop duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
							
							selectWindow("Rdrop");
							run("Multiply...", "value=255.000 stack");	
							//

							selectWindow("Rdrop");
							run("Invert", "stack");
							run("Properties...", "channels=1 slices=21 frames=1 unit=um pixel_width=0.325 pixel_height=0.325 voxel_depth=0.7");
							run("Distance Map (with Calibration)", "input=Rdrop implementation=ImageJ-Ops");
							rename("Distance");
			
							
							selectWindow("Distance");
							run("Duplicate...", "title=Distance_under1um duplicate");
							setThreshold(0, 1.0000);
							run("Convert to Mask", "method=Otsu background=Dark black");
							selectWindow("Distance_under1um");
							run("Divide...", "value=255 stack");

							
							imageCalculator("Multiply create stack", "Distance_under2um","Result of Factin");
							selectWindow("Result of Factin");
							run("Z Project...", "projection=[Sum Slices]");
							selectWindow("Result of Distance_under2um");
							run("Z Project...", "projection=[Sum Slices]");
							
							run("Set Measurements...", "area mean standard modal min integrated redirect=None decimal=3");
					        selectWindow("SUM_Result of Factin");
					        run("Measure");
							selectWindow("SUM_Result of Distance_under2um");
							run("Measure");
							
							
							Sum_in1umt = getResult("RawIntDen", 1);
							Sum_totalFactint = getResult("RawIntDen", 0);
							Ratio1um_totalt = Sum_in1umt/Sum_totalFactint ;
							
							Sum_in1um[i-2] = Sum_in1umt;
							Sum_totalFactin[i-2] = Sum_totalFactint;
							RatioSum1um_total[i-2] = Ratio1um_totalt;

							

							close("Distance");
							close("Factin");
							close("Factin_mask");
							
							close("Distance_under2um");
							close("Result of Factin");
							close("Result of Distance_under2um");
							close("SUM_Result of Factin");
							close("SUM_Result of Distance_under2um");
							close("Results");
							close("Rdrop");
							close("Result of drop");
							
			}
			// create results Table
			for(j=0;j<(frames-1);j++){
				setResult("Sum_in1um", j, Sum_in1um[j]);
				setResult("Sum_totalFactin", j, Sum_totalFactin[j]);
				setResult("RatioSum1um_total", j, RatioSum1um_total[j]);
				
				
			}
			updateResults();

		   	name0 =path;
			

			
			Stack.getDimensions(width, height, channels, slices, frames);
			print(frames);

			
			selectWindow("Results");
			saveAs("Results", myDir+name+"_Factin_1umarea_rawintden.csv");

			
		   	close("Results");
		   	run("Close All");
		   call("java.lang.System.gc");
		   	print(list[k]+" done");
   }
}



