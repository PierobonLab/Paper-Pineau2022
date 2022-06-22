// Judith Pineau 20220203
//Trying to quantify EXOC7 enrichment on IF, for control cells at different time points, 
//Step 1: Make masks of cell (actin) and droplet

myDir = getDirectory("Choose a Directory ");

list = getFileList(myDir);
dirMask=myDir+"Mask_3D"+File.separator();
File.makeDirectory(dirMask); 

imagenames=getFileList(myDir);
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
		   
			open(myDir+name);
			selectWindow(name);
			getDimensions(width, height, channels, slices, frames);
			
			imageTitle=getTitle();
			selectWindow(name);
			rename("Image");
			Stack.setDisplayMode("composite");
			getDimensions(width, height, channels, slices, frames);			

			
			selectWindow("Image");
			run("Split Channels");
			getDimensions(width, height, channels, slices, frames);			
			
			selectWindow("C1-Image");
			rename("Actin");
			selectWindow("C4-Image");
			rename("Drop");
			


			// Cell Mask
			selectWindow("Actin");
 
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			print(voxelCount);
			setMinAndMax(min, max);
			run("Median 3D...", "x=2 y=2 z=1");
			run("Duplicate...", "title=CellMask duplicate slices=1-"+slices);
			run("Threshold...");
			waitForUser("Do Cell threshold");
			setAutoThreshold("Li dark stack");
			setOption("BlackBackground", true);
			run("Convert to Mask");
	
			
			run("Fill Holes", "stack");
			run("Erode", "stack");
			run("Erode", "stack");
			run("Erode", "stack");
			run("Dilate", "stack");
			run("Dilate", "stack");
			run("Dilate", "stack");

			
			// Droplet Mask
			selectWindow("Drop");
 
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			print(voxelCount);
			setMinAndMax(min, max);
			run("Median 3D...", "x=2 y=2 z=1");
			run("Duplicate...", "title=DropMask duplicate slices=1-"+slices);
			waitForUser("Do Drop threshold");
			setAutoThreshold("Li dark stack");
			setOption("BlackBackground", true);
			run("Convert to Mask");

			run("Fill Holes", "stack");
			run("Erode", "stack");
			run("Erode", "stack");
			run("Erode", "stack");
			run("Dilate", "stack");
			run("Dilate", "stack");
			run("Dilate", "stack");

			
			selectWindow("CellMask");
			waitForUser("Clean Cell Mask");
			run("Fill Holes", "stack");
			
			selectWindow("DropMask");
			waitForUser("Clean Droplet Mask");
			run("Fill Holes", "stack");
			
			
			run("Select None");

			selectWindow("CellMask");
			saveAs("Tiff", dirMask + name1+"_Cell.tif");
			run("Close");

			selectWindow("DropMask");
			saveAs("Tiff", dirMask + name1+"_Drop.tif");
			run("Close");

							
			}
			
		   	run("Close All");
		   call("java.lang.System.gc");
		   	print(list[k]+" done");
}


