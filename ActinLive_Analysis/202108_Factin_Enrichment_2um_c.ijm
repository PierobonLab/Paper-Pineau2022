// Judith Pineau 20210803
// Use Masks (in MaskCheck folder) and movies (bleach corrected in this macro) to measure the enrichment in F actin near the droplet (2um)

// Measuring sum intensity near droplet, total intensity, ratio, and total area near droplet (the disk), area of actin near droplet, and also other variables that I did not use in the end

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
		   namei =name;
			open(myDir+name);
			open(Maskdir+namei+"Cell.tif");
			open(Maskdir+namei+"drop.tif");

			selectWindow(namei+"Cell.tif");
			rename("MaskCell");
			selectWindow(namei+"drop.tif");
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
			
			
		
			// C1: F-actin
			selectWindow("C1-Image");
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			setMinAndMax(min, max);
			run("8-bit");
			
			run("Duplicate...", "duplicate frames=2-"+frames+"");
			selectWindow("C1-Image-1");
			run("Bleach Correction", "correction=[Simple Ratio]");
			selectWindow("DUP_C1-Image-1");
			rename("Factin_all");
			

			Sum_in2um=newArray(frames-1);
			Sum_totalFactin=newArray(frames-1);	
			RatioSum2um_total=newArray(frames-1);
			Avg_in2um=newArray(frames-1);
			Avg_totalFactin=newArray(frames-1);
			Ratio_avg2um_total=newArray(frames-1);
			VolActin2um=newArray(frames-1);
			VolActin_tot=newArray(frames-1);
			Voldroplet_plus_2um=newArray(frames-1);
			Voldroplet=newArray(frames-1);
			SurfActin2um=newArray(frames-1);

			
			for(i=1;i<frames ;i++) {
							

							slices=21;
							print(i);
					
							// Processing F-actin
							selectWindow("Factin_all");
							run("Duplicate...", "title=Factin duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
							
							selectWindow("Factin"); 
							Stack.getStatistics(voxelCount, mean, min, max, stdDev);
							print(voxelCount);
							setMinAndMax(min, max);
							run("Median 3D...", "x=2 y=2 z=1");
							
							
							//getting total F-actin volume
							selectWindow("MaskCell");
							run("Duplicate...", "title=Factin_mask duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
							selectWindow("Factin_mask");
							run("Z Project...", "projection=[Sum Slices]");
							selectWindow("SUM_Factin_mask");
							VolActin= getValue("RawIntDen");
							close("SUM_Factin_mask");

							VolActin_unit= VolActin*0.325*0.325*0.7;
							//
							
							imageCalculator("Multiply create stack", "Factin","Factin_mask");
							selectWindow("Result of Factin");
							
							setSlice(10);
							
						
							//getting drop volume
							selectWindow("Mask");
							run("Duplicate...", "title=Rdrop duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
							
							selectWindow("Rdrop");
							run("Z Project...", "projection=[Sum Slices]");
							selectWindow("SUM_Rdrop");
							Voldrop = getValue("RawIntDen");
							close("SUM_Rdrop");
							selectWindow("Rdrop");
							run("Multiply...", "value=255.000 stack");	

							Voldropunit= Voldrop*0.325*0.325*0.7;
							//

							
							selectWindow("Rdrop");
							run("Invert", "stack");
							run("Properties...", "channels=1 slices=21 frames=1 unit=um pixel_width=0.325 pixel_height=0.325 voxel_depth=0.7");
							run("Distance Map (with Calibration)", "input=Rdrop implementation=ImageJ-Ops");
							rename("Distance");
			
							
							selectWindow("Distance");
							run("Duplicate...", "title=Distance_under2um duplicate");
							setThreshold(0, 2.0000);
							run("Convert to Mask", "method=Otsu background=Dark black");
							selectWindow("Distance_under2um");
							run("Divide...", "value=255 stack");

							//Get Volume of droplet + 2um
							selectWindow("Distance_under2um");
							run("Z Project...", "projection=[Sum Slices]");
							selectWindow("SUM_Distance_under2um");
							Voldrop2um = getValue("RawIntDen");
							close("SUM_Distance_under2um");
							Voldrop2umunit= Voldrop2um*0.325*0.325*0.7;
							//

							// Get Volume of F-actin mask in the 2µm 
							selectWindow("Factin_mask");
							run("Invert", "stack");
							imageCalculator("Multiply create stack", "Distance_under2um","Factin_mask");
							selectWindow("Result of Distance_under2um");
							run("Divide...", "value=255 stack");
							run("Z Project...", "projection=[Sum Slices]");
							VolActin2umt = getValue("RawIntDen");
							//waitForUser("Check");

							selectWindow("SUM_Result of Distance_under2um");
							setThreshold(1, 30);
							setOption("BlackBackground", true);
							run("Convert to Mask");
							SurfActin2umt = getValue("RawIntDen");
							SurfActin2umt_unit = SurfActin2umt*0.325*0.325;
							
							close("SUM_Result of Distance_under2um");
							close("Result of Distance_under2um");
							VolActin2umtunit= VolActin2umt*0.325*0.325*0.7;
							//
							
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
							
							
							Sum_in2umt = getResult("RawIntDen", 1);
							Sum_totalFactint = getResult("RawIntDen", 0);
							Ratio2um_totalt = Sum_in2umt/Sum_totalFactint ;
							
							Sum_in2um[i-1] = Sum_in2umt;
							Sum_totalFactin[i-1] = Sum_totalFactint;
							RatioSum2um_total[i-1] = Ratio2um_totalt;

							Voldroplet[i-1] = Voldropunit;
							Voldroplet_plus_2um[i-1] = Voldrop2umunit ;
							VolActin2um[i-1] = VolActin2umtunit;
							VolActin_tot[i-1] = VolActin_unit ;
							SurfActin2um[i-1] = SurfActin2umt_unit;
							Avg_totalFactin[i-1] = Sum_totalFactint/VolActin;
							Avg_in2um[i-1] = Sum_in2umt/VolActin2umt;
							Ratio_avg2um_total[i-1] = Avg_in2um[i-1]/ Avg_totalFactin[i-1];

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
				setResult("Sum_in2um", j, Sum_in2um[j]);
				setResult("Sum_totalFactin", j, Sum_totalFactin[j]);
				setResult("RatioSum2um_total", j, RatioSum2um_total[j]);
				setResult("Voldroplet_unit", j, Voldroplet[j]);
				setResult("Voldroplet_unit_2umrad", j, Voldroplet_plus_2um[j]);
				setResult("VolActintotal_unit", j, VolActin_tot[j]);
				setResult("VolActin2um_unit", j, VolActin2um[j]);
				setResult("SurfActin2um_unit", j, SurfActin2um[j]);
				setResult("Avg_totalFactin", j, Avg_totalFactin[j]);
				setResult("Avg_in2um", j, Avg_in2um[j]);
				setResult("Ratio_avg2um_total", j, Ratio_avg2um_total[j]);
				
			}
			updateResults();

		   	name0 =path;

			
			Stack.getDimensions(width, height, channels, slices, frames);
			print(frames);

			
			selectWindow("Results");
			saveAs("Results", myDir+name+"_Factin_2umarea_rawintden.csv");

			
		   	close("Results");
		   	run("Close All");
		   call("java.lang.System.gc");
		   	print(list[k]+" done");
   }
}



