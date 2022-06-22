// Judith Pineau 20220203
//Generating Masks of the cell (acetyl-tubulin staining) and the droplet on IF images


myDir = getDirectory("Choose a Directory ");

list = getFileList(myDir);
dirMask=myDir+"Mask"+File.separator();
File.makeDirectory(dirMask); 

imagenames=getFileList(myDir);
for (k=0; k<list.length; k++) {
     	print(list[k]);
        if (!(endsWith(list[k], "/")) & (endsWith(list[k], ".tif"))){
			name=list[k];
			name=imagenames[k];   /// ici prends le nom des images dans le dossier dirdata dans l'ordre de la boucle
			totnamelength=lengthOf(name); /// enleve l'extension a name
			namelength=totnamelength-4;   /// exemple ici, on enleve les 4 derniers caracteres
			name1=substring(name, 0, namelength);  /// name1==name sans le .tif
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

			Dialog.createNonBlocking("Channels of interest")
			Dialog.addNumber("Droplet Channel", 1);
			Dialog.addNumber("Alpha-tubulin Channel",3);
			Dialog.addNumber("Acetyl Tubulin Channel",2);
			Dialog.show();
			Ch_drop = Dialog.getNumber();
			Ch_tub = Dialog.getNumber();
			Ch_acet = Dialog.getNumber();
			
			selectWindow("Image");
			run("Split Channels");
			getDimensions(width, height, channels, slices, frames);			
			
			selectWindow("C"+Ch_tub+"-Image");
			rename("Actin");
			selectWindow("C"+Ch_drop+"-Image");
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


