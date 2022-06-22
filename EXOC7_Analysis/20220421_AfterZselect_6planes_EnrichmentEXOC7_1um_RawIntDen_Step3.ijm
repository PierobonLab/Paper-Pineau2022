// Judith Pineau 20220203
//Trying to quantify EXOC7 enrichment on IF, for control cells at different time points, 
//Step 3: Automatic quantification of EXOC7 enrichment at IS

myDir = getDirectory("Choose a Directory ");
run("Set Measurements...", "area mean standard modal min center shape integrated redirect=None decimal=3");
list = getFileList(myDir);
Maskdir= myDir +"MaskZselect"+File.separator();  
print(Maskdir); 

imagenames=getFileList(myDir);

Imagename=newArray("name");
EXOC7_Sum_1um=newArray(1);
EXOC_Sum_total=newArray(1);
EXOC7_RatioSum_1um_total=newArray(1);



for (k=0; k<list.length; k++) {
     	print(list[k]);
        if (!(endsWith(list[k], "/")) & (endsWith(list[k], ".tif"))){
			

			name=list[k];
			
			path=substring(name,0,lengthOf(name)-12);
			print(path);
		   
			open(myDir+name);
			open(Maskdir+path+"_MaskCell_zselect.tif");
			open(Maskdir+path+"_Drop_zselect.tif");

			selectWindow(path+"_MaskCell_zselect.tif");
			rename("MaskCell");
			selectWindow(path+"_Drop_zselect.tif");
			rename("Rdrop");
			
			selectWindow("MaskCell");
			Stack.getStatistics(voxelCount, mean, min, maxCell, stdDev);
			if (maxCell==1) {
				selectWindow("MaskCell");
				run("Multiply...", "value=255 stack");
			}
			selectWindow("Rdrop");
			Stack.getStatistics(voxelCount, mean, min, maxDr, stdDev);
			if (maxDr==1) {
				selectWindow("Rdrop");
				run("Multiply...", "value=255 stack");
			}
			
			selectWindow(name);
			getDimensions(width, height, channels, slices, frames);
			
			
			imageTitle=getTitle();
			selectWindow(name);
			rename("Image");

			selectWindow("Image");
			
			run("Split Channels");
			selectWindow("C2-Image");
			rename("Stain");
			
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			setMinAndMax(min, max);
			run("Z Project...", "projection=[Sum Slices]");
			selectWindow("Rdrop");
			run("Z Project...", "projection=[Max Intensity]");
			
			//Getting distance map from droplet
			
			selectWindow("MAX_Rdrop");
			run("Invert", "stack");		
			run("Distance Map (with Calibration)", "input=MaskDrop implementation=ImageJ-Ops");
			rename("Distance");
			

							
			selectWindow("Distance");
			run("Duplicate...", "title=Distance_under1um duplicate");
			setThreshold(0, 1.0000);
			setOption("BlackBackground", false);
			run("Convert to Mask", "method=Default background=Dark");
			selectWindow("Distance_under1um");
			run("Divide...", "value=255 stack");

			// Get Mask of cell intersecting with the 1um layer around the droplet
			selectWindow("MaskCell");
			imageCalculator("Multiply create stack", "Distance_under1um","MaskCell");
			selectWindow("Result of Distance_under1um");
			rename("Cell_within1um");
			
			// Get signal of EXOC7 intersecting with this mask
			selectWindow("Cell_within1um");
			run("Divide...", "value=255 stack");
			imageCalculator("Multiply create stack", "Stain","Cell_within1um");

			// Get RawIntDen of EXOC7 within 1um
			selectWindow("Result of Stain");
			rename("Image_1um");
			run("Z Project...", "projection=[Sum Slices]");
			run("Measure");
			getValue("RawIntDen");
			RawIntDen_1umcell=getResult("RawIntDen",0);
			run("Clear Results");


			// Get RawIntDen of EXOC7 total
			selectWindow("MaskCell");
			run("Divide...", "value=255 stack");
			imageCalculator("Multiply create stack", "Stain","MaskCell");
			run("Z Project...", "projection=[Sum Slices]");
			run("Measure");
			getValue("RawIntDen");
			RawIntDen_total_cell=getResult("RawIntDen",0);
			run("Clear Results");


			EXOC7_Sum_1um1=newArray(1);
			EXOC7_Sum_total1=newArray(1);
			EXOC7_RatioSum_1um_total1=newArray(1);
			Imagename1=newArray(1);
			
			EXOC7_Sum_1um1[0]=RawIntDen_1umcell;
			EXOC7_Sum_total1[0]=RawIntDen_total_cell;
			EXOC7_RatioSum_1um_total1[0]=RawIntDen_1umcell/RawIntDen_total_cell;
			Imagename1[0]=name;


			EXOC7_Sum_1um=Array.concat(EXOC7_Sum_1um,EXOC7_Sum_1um1);
			EXOC7_Sum_total=Array.concat(EXOC7_Sum_total,EXOC7_Sum_total1);
			EXOC7_RatioSum_1um_total=Array.concat(EXOC7_RatioSum_1um_total,EXOC7_RatioSum_1um_total1);
			Imagename=Array.concat(Imagename,Imagename1);

			run("Close All");
		   call("java.lang.System.gc");
		   	print(list[k]+" done");
			
			}
			

}

if(isOpen("Results")) {
	selectWindow("Results");
	run("Close");
}


for(i=0;i<(lengthOf(Imagename)-1);i++) {
	setResult("ImageName",i,Imagename[i+1]);
	setResult("RawIntDen of EXOC7 within 1µm",i,EXOC7_Sum_1um[i+1]);
	setResult("RawIntDen of EXOC7 in whole cell",i,EXOC7_Sum_total[i+1]);
	setResult("Ratio of EXOC7 RawIntDen within 1µm/total",i,EXOC7_RatioSum_1um_total[i+1]);	
	
}
updateResults();
selectWindow("Results");
saveAs("Results",myDir+"ResultsEXOC_1um_Total.xls");
