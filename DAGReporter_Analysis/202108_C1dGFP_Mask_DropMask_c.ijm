//202108 Judith Pineau
// Make masks of cell and droplet


myDir = getDirectory("Choose a Directory ");

list = getFileList(myDir);
Maskdir= myDir + "/Mask/"; 
print(Maskdir); 
File.makeDirectory(Maskdir);
     for (k=0; k<list.length; k++) {
     	print(list[k]);
        if (!(endsWith(list[k], "/")) & (endsWith(list[k], ".tif"))){
			name=list[k];
			path=substring(name,0,lengthOf(name)-4);
			print(path);
		   
			open(myDir+list[k]);
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
			run("8-bit");
			
			run("Duplicate...", "title=drop_all duplicate frames=2-"+frames+"");
			
		

			selectWindow("C2-Image");
			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			setMinAndMax(min, max);
			run("8-bit");
			
			run("Duplicate...", "duplicate frames=2-"+frames+"");
			selectWindow("C2-Image-1");
			run("Bleach Correction", "correction=[Simple Ratio]");
			selectWindow("DUP_C2-Image-1");
			rename("Factin_all");
			
				
			selectWindow("drop_all");
			run("Median 3D...", "x=1 y=1 z=1");
			run("Gaussian Blur...", "sigma=2 stack");
			run("Auto Threshold", "method=Li white stack use_stack_histogram");
			run("3D Fill Holes");
			

			newImage("Mask", "8-bit black",width, height, slices);
			newImage("MaskCell", "8-bit black",width, height, slices);
			
			for(i=1;i<frames ;i++) {
							
							selectWindow("Mask");
							rename("Black");
							selectWindow("MaskCell");
							rename("BlackCell");
							//i=2;
							slices=21;
							print(i);

							selectWindow("drop_all");
							run("Duplicate...", "title=drop duplicate slices=1-"+slices+" frames="+i+"-"+i+"");

							
							// Processing F-actin
							selectWindow("Factin_all");
							run("Duplicate...", "title=Factin duplicate slices=1-"+slices+" frames="+i+"-"+i+"");
							
							selectWindow("Factin"); 
							Stack.getStatistics(voxelCount, mean, min, max, stdDev);
							print(voxelCount);
							setMinAndMax(min, max);
							run("Median 3D...", "x=2 y=2 z=1");
								
							selectWindow("Factin");
							run("Duplicate...", "title=Factin_mask duplicate");
							selectWindow("Factin");
							run("Z Project...", "projection=[Max Intensity]");
							selectWindow("Factin");
							
							setAutoThreshold("Moments dark stack");
							
							getThreshold(lower, upper);
							selectWindow("Factin_mask");
							setThreshold(lower, upper);
							setOption("BlackBackground", true);
							run("Convert to Mask", "method=Otsu background=Dark black list");

							selectWindow("Factin_mask");
							
							run("Options...", "iterations=1 count=1 black pad do=Erode stack");
							run("Options...", "iterations=1 count=1 black pad do=Dilate stack");
							run("Concatenate...", "  title=MaskCell keep open image1=BlackCell image2=Factin_mask image3=[-- None --]");
							selectWindow("Factin_mask");
							run("Divide...", "value=255 stack");
							

							// Processing the droplet							
							selectWindow("drop");
							setSlice(11);
							run("Enhance Contrast", "saturated=0.35");
							Stack.getStatistics(voxelCount, mean, min, max, stdDev);
							setMinAndMax(min, max);

							
							selectWindow("drop");
							run("Duplicate...", "title=Rdrop duplicate");
							run("Concatenate...", "  title=Mask keep open image1=Black image2=Rdrop image3=[-- None --]");

						
							
							close("BlackCell");
							close("Black");
							
							close("MAX_drop");
							close("MAX_Factin");
							close("Factin");
							close("Factin_mask");
							close("drop");
							close("Rdrop");
							
						
							
							
			}
			
			
		   	name0 =path;

			print(Maskdir+name+".tif");
			selectWindow("Mask");
			
			Stack.getDimensions(width, height, channels, slices, frames);
			print(frames);
			selectWindow("Mask");
			saveAs("Tiff",Maskdir+name+"drop.tif");

			selectWindow("MaskCell");
			saveAs("Tiff",Maskdir+name+"Cell.tif");

		   	run("Close All");
		   call("java.lang.System.gc");
		   	print(list[k]+" done");
   }
}



