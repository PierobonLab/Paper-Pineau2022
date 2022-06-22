// Judith Pineau 20220210
//Quantify GEF-H1 at IS
// Using 2D image, on the plane of the synapse, saved in the SynapsePlane directory under name + _synapse_plane.tif
//Step 2 : Measurement of GEF-H1 within a 1um layer at the IS (near the droplet, within cell mask)


myDir = getDirectory("Choose a Directory ");

list = getFileList(myDir);
dirMask=myDir+"Mask"+File.separator();
dir=myDir+"SynapsePlane"+File.separator();

imagenames=getFileList(myDir);

Imagename=newArray("name");
GEFH1_Sum_1um=newArray(1);
GEFH1_Sum_total=newArray(1);
GEFH1_RatioSum_1um_total=newArray(1);

run("Set Measurements...", "area mean standard modal min centroid perimeter bounding shape integrated redirect=None decimal=3");

for (k=0; k<list.length; k++) {
     	print(list[k]);
        if (!(endsWith(list[k], "/")) & (endsWith(list[k], ".tif"))){
			name=list[k];
			name=imagenames[k];   
			totnamelength=lengthOf(name); 
			namelength=totnamelength-4;   
			name1=substring(name, 0, namelength);  
			extension=substring(name, namelength, totnamelength);
			path=substring(name,0,lengthOf(name)-4);
			print(path);

		   open(dir+name1+"_synapse_plane.tif");
		   rename("Image");
			open(myDir+name);
			selectWindow(name);
			getDimensions(width, height, channels, slices, frames);

			imageTitle=getTitle();
		

			//Open masks
			open(dirMask + name1+"_Cell.tif");
			rename("MaskCell");

			open(dirMask + name1+"_Drop.tif");
			rename("MaskDrop");
			
			selectWindow("Image");
			run("Split Channels");
			getDimensions(width, height, channels, slices, frames);			
			
			
			selectWindow("C2-Image");
			rename("GEFH1");


			// Getting 1um layer around droplet mask
			selectWindow("MaskDrop");
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
			
			// Get signal of GEF-H1 intersecting with this mask
			selectWindow("Cell_within1um");
			run("Divide...", "value=255 stack");
			imageCalculator("Multiply create stack", "GEFH1","Cell_within1um");

			// Get RawIntDen of GEFH1 within 1um
			selectWindow("Result of GEFH1");
			rename("GEFH1_1um");
			//run("Z Project...", "projection=[Sum Slices]");
			run("Measure");
			getValue("RawIntDen");
			RawIntDen_GEFH1_1umcell=getResult("RawIntDen",0);
			run("Clear Results");


			// Get RawIntDen of GEFH1 total
			selectWindow("MaskCell");
			run("Divide...", "value=255 stack");
			imageCalculator("Multiply create stack", "GEFH1","MaskCell");
			//run("Z Project...", "projection=[Sum Slices]");
			run("Measure");
			getValue("RawIntDen");
			RawIntDen_GEFH1_total_cell=getResult("RawIntDen",0);
			run("Clear Results");


			GEFH1_Sum_1um1=newArray(1);
			GEFH1_Sum_total1=newArray(1);
			GEFH1_RatioSum_1um_total1=newArray(1);
			Imagename1=newArray(1);
			
			GEFH1_Sum_1um1[0]=RawIntDen_GEFH1_1umcell;
			GEFH1_Sum_total1[0]=RawIntDen_GEFH1_total_cell;
			GEFH1_RatioSum_1um_total1[0]=RawIntDen_GEFH1_1umcell/RawIntDen_GEFH1_total_cell;
			Imagename1[0]=name1;


			GEFH1_Sum_1um=Array.concat(GEFH1_Sum_1um,GEFH1_Sum_1um1);
			GEFH1_Sum_total=Array.concat(GEFH1_Sum_total,GEFH1_Sum_total1);
			GEFH1_RatioSum_1um_total=Array.concat(GEFH1_RatioSum_1um_total,GEFH1_RatioSum_1um_total1);
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
	setResult("RawIntDen of GEFH1 within 1µm",i,GEFH1_Sum_1um[i+1]);
	setResult("RawIntDen of GEFH1 in whole cell",i,GEFH1_Sum_total[i+1]);
	setResult("Ratio of GEFH1 RaxwIntDen within 1µm/total",i,GEFH1_RatioSum_1um_total[i+1]);	
	
}
updateResults();
selectWindow("Results");
saveAs("Results",myDir+"Results.xls");

