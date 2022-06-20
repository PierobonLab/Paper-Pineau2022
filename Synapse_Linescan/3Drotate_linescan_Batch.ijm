
myDir = getDirectory("Choose a Directory ");

list = getFileList(myDir);


//dir="/media/paolo/Paolo/Judith samples/Nucleus/Nucleus_BSA_aIgG/IgG/";


list = getFileList(myDir);
for (i=0; i<list.length; i++) {
        if (endsWith(list[i], ".tif")) {
        	//nm=substring(list[i], 0, lengthOf(list[i])-10)+".tif";

			//run("TIFF Virtual Stack...", "open="+myDir+list[i]);
        	
        	open(myDir+list[i]);
          print(list[i]);
//	runMacro("/Functions/segment_synapse.ijm");
    	runMacro("/Functions/3Drotate_linescan.ijm");
		}
}


/**** uncomment to analyse the bead mask only 
// correct bead
dir="/home/paolo/Documents/PROJECTS/Judith/mtocmyD/CellLine/Igg/";

list = getFileList(dir);
for (i=0; i<list.length; i++) {
        if (endsWith(list[i], "Bead_Mask.tif")) {
        	open(dir+list[i]);
          print(list[i]);
     			runMacro("/home/paolo/Documents/PROJECTS/Judith/mtoc/beadCOM.ijm");
		}
}
*/
