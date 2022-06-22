// Judith Pineau 20220203
//To measure actin intensity along the polarity axis, and evaluate actin polarisation on IF
//Step 2: Select 6 z around the synapse plane

myDir = getDirectory("Choose a Directory ");
run("Set Measurements...", "area mean standard modal min center integrated redirect=None decimal=3");
list = getFileList(myDir);
Maskdir= myDir + "Mask_3D"+File.separator(); 
print(Maskdir); 
dirZselect=myDir+"Zselect"+File.separator();
File.makeDirectory(dirZselect);
dirZselectMask=dirZselect+"MaskZselect"+File.separator(); 
File.makeDirectory(dirZselectMask);

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
			
			path=substring(name,0,lengthOf(name)-4);
			print(path);
		   
			open(myDir+name);
			open(Maskdir+path+"_Cell.tif");
			open(Maskdir+path+"_Drop.tif");

			selectWindow(path+"_Cell.tif");
			rename("MaskCell");
			selectWindow(path+"_Drop.tif");
			rename("Rdrop");

			selectWindow(name);
			getDimensions(width, height, channels, slices, frames);
			
			
			imageTitle=getTitle();
			selectWindow(name);
			rename("Image");
			
			selectWindow("Image");
			Stack.setDisplayMode("composite");
			run("Channels Tool...");
			Stack.setActiveChannels("10010");
			
			
			
			
			// Ask to select the z min and z max of interest 
			Dialog.createNonBlocking("z of interests")
			Dialog.addCheckbox("Keep this cell for analysis", true);
			Dialog.addNumber("Zmin",1);
			Dialog.addNumber("Zmax",30);
			Dialog.show();
			keep = Dialog.getCheckbox();
			Zmin = Dialog.getNumber();
			//Zmax = Dialog.getNumber();
			Zmax = Zmin+6;

			selectWindow("MaskCell");
			run("Duplicate...", "title=MaskCell_z duplicate range="+Zmin+"-"+Zmax+"");
			run("Z Project...", "projection=[Max Intensity]");

			
			selectWindow("Image");
			run("Duplicate...", "title=Image_z duplicate slices="+Zmin+"-"+Zmax+"");

			
			selectWindow("Rdrop");
			run("Duplicate...", "title=Rdrop_z duplicate range="+Zmin+"-"+Zmax+"");
				
				
		
			selectWindow("MaskCell_z");
			saveAs("Tiff", dirZselectMask + path+"_MaskCell_zselect.tif");

			selectWindow("Rdrop_z");
			saveAs("Tiff", dirZselectMask + path+"_Drop_zselect.tif");
			
			selectWindow("Image_z");
			saveAs("Tiff", dirZselect + path+"_zselect.tif");

			run("Close All");
			}




}



call("java.lang.System.gc");

 


