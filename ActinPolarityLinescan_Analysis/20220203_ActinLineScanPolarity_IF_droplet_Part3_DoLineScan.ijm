//Judith Pineau 2022/03/21
//To measure actin intensity along the polarity axis, and evaluate actin polarisation on IF
//Step3: do linescan

myDir = getDirectory("Choose a Directory ");
run("Set Measurements...", "area mean standard modal min center integrated redirect=None decimal=3");
list = getFileList(myDir);
Maskdir= myDir +"MaskZselect"+File.separator();  
print(Maskdir); 


Imagename=newArray("name");
nb_max=newArray(1);
sd_maxdist = newArray(1);
mean_maxdist =newArray(1);
Max_DistanceCell =newArray(1);
PolarityIndex_Actinmax =newArray(1);

     for (k=0; k<list.length; k++) {
     	print(list[k]);
        if (!(endsWith(list[k], "/")) & (endsWith(list[k], ".tif"))){
			name=list[k];
			
			path=substring(name,0,lengthOf(name)-18);
			print(path);
		   
			open(myDir+name);
			open(Maskdir+path+"_MaskCell_zselect.tif");
			open(Maskdir+path+"_Drop_zselect.tif");

			selectWindow(path+"_MaskCell_zselect.tif");
			rename("MaskCell");
			selectWindow(path+"_Drop_zselect.tif");
			rename("Rdrop");

			selectWindow(name);
			getDimensions(width, height, channels, slices, frames);
			
			
			imageTitle=getTitle();
			selectWindow(name);
			rename("Image");

			selectWindow("Image");

			Stack.getStatistics(voxelCount, mean, min, max, stdDev);
			setMinAndMax(min, max);
			run("Z Project...", "projection=[Sum Slices]");
			selectWindow("Rdrop");
			run("Z Project...", "projection=[Max Intensity]");
			
			run("Line Width...", "line="+150);
			
			Dialog.createNonBlocking("Draw a ling along the cell - starting at the IS")
			Dialog.show();
			
			run("Clear Results");
			profile = getProfile();
			for (i=0; i<profile.length; i++){
  				setResult("Value", i, profile[i]);
			}
			updateResults();
			saveAs("Measurements", myDir+path+"Profile_Actin.txt");
			selectWindow("Results");
			run("Close");
			
			run("Close All");
			call("java.lang.System.gc");

	}
}


