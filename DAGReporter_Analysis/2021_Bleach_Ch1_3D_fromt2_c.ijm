// Judith Pineau 2021 Bleach correction of 1 channel, from second time point (when cell arrives)

myDir = getDirectory("Choose a Directory ");
Bleachdir= myDir + "/_bleachCell_2021_exp/"; 
print(Bleachdir); 
File.makeDirectory(Bleachdir);
list = getFileList(myDir);

     for (i=0; i<list.length; i++) {
     	print(list[i]);
        if (!(endsWith(list[i], "/")) & (endsWith(list[i], ".tif"))){
           name=list[i];
		   path=substring(name,0,lengthOf(name)-4);
		   print(path);
		   
		   open(myDir+list[i]);
			
			selectWindow(name);
			
		   	name0 =path;
		   	selectWindow(name);
 			
			getDimensions(width, height, channels, slices, frames);
			//REMEMBER TO CHANGE ACCORDING TO NUMBER OF Z
			T =nSlices/42;
			run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices=21 frames="+T+" display=Color");

			imageTitle=getTitle();
		
			run("Split Channels");
			selectWindow("C1-"+name); //Should be cell
			run("Duplicate...", "title=C1-t1 duplicate frames=1-1");
			selectWindow("C1-"+name); //Should be cell
			run("Duplicate...", "title=C1-tother duplicate frames=2-"+T);
			selectWindow("C1-tother");
			
			run("Bleach Correction", "correction=[Histogram Matching]");
			
			run("Concatenate...", "  title=DUP_C1-"+name+" keep open image1=C1-t1 image2=DUP_C1-tother image3=[-- None --]");
	
			

			run("Merge Channels...", "c1=DUP_C1-"+name+" c2=C2-"+name+" create");
			rename("Merged");
			

			
			print(Bleachdir+name+".tif");
			selectWindow("Merged");
			saveAs("Tiff",Bleachdir+name+".tif");
		   
		   run("Close All");
		   print(list[i]+" done");
   }
}

