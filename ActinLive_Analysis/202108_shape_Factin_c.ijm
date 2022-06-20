// Judith Pineau 20210803
// Use Masks (in MaskCheck folder) to measure shape characteristics of the cell


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
		   
			open(Maskdir+name+"Cell.tif");
			
			selectWindow(name+"Cell.tif");
			rename("MaskCell");


			selectWindow("MaskCell");
			run("Duplicate...", "title=MaskCell2 duplicate frames=2-"+frames+"");
			selectWindow("MaskCell2");
			run("Z Project...", "projection=[Max Intensity] all");
			selectWindow("MAX_MaskCell2");
			run("Set Measurements...", "area mean standard modal min center perimeter fit shape feret's integrated stack redirect=None decimal=3");
			
			run("Make Binary", "method=Default background=Default calculate");
			run("Analyze Particles...", "size=700-Infinity display exclude clear stack");
			saveAs("Results", myDir+name+"shape.txt");
			
			
		   	close("Results");
		   	run("Close All");
		   call("java.lang.System.gc");
		   	print(list[k]+" done");
   }
}

