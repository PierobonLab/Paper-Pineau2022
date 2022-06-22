// Judith Pineau 20220320
//Quantify Total intensity of acetyl tubuln in cell mask, and of alpha-tubulin in cell mask and ratio

myDir = getDirectory("Choose a Directory ");

list = getFileList(myDir);
dirMask=myDir+"Mask"+File.separator();


imagenames=getFileList(myDir);

Imagename=newArray("name");
AcetylTub_Sum=newArray(1);
AlphTub_Sum=newArray(1);
RatioSum_Acetyl_alpha=newArray(1);

run("Set Measurements...", "area mean standard modal min perimeter bounding shape integrated redirect=None decimal=3");

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
			rename("Image");
			getDimensions(width, height, channels, slices, frames);
			
			imageTitle=getTitle();
			
			
			Dialog.createNonBlocking("Channels of interest")
			Dialog.addNumber("Droplet Channel", 1);
			Dialog.addNumber("Alpha-tubulin Channel",3);
			Dialog.addNumber("Acetyl Tubulin Channel",2);
			Dialog.show();
			Ch_drop = Dialog.getNumber();
			Ch_tub = Dialog.getNumber();
			Ch_acet = Dialog.getNumber();
			
			
			//Open masks
			open(dirMask + name1+"_Cell.tif");
			rename("MaskCell");

			open(dirMask + name1+"_Drop.tif");
			rename("MaskDrop");
			
			selectWindow("Image");
			run("Split Channels");
			getDimensions(width, height, channels, slices, frames);			
			
			
			selectWindow("C"+Ch_acet+"-Image");
			rename("Acet_tub");
			
			
			selectWindow("C"+Ch_tub+"-Image");
			rename("Alpha_tub");


			// Get Mask of cell intersecting with alpha-tubulin
			selectWindow("MaskCell");
			run("Divide...", "value=255 stack");
			imageCalculator("Multiply create stack", "Alpha_tub","MaskCell");
			selectWindow("Result of Alpha_tub");
			rename("Alpha_tub_Mask");
			run("Z Project...", "projection=[Sum Slices]");
			run("Measure");
			getValue("RawIntDen");
			RawIntDen_alpha_Tub=getResult("RawIntDen",0);
			run("Clear Results");
			
			
			// Get Mask of cell intersecting with acet-tubulin
			selectWindow("MaskCell");
			imageCalculator("Multiply create stack", "Acet_tub","MaskCell");
			selectWindow("Result of Acet_tub");
			rename("Acet_tub_Mask");
			run("Z Project...", "projection=[Sum Slices]");
			run("Measure");
			getValue("RawIntDen");
			RawIntDen_acet_Tub=getResult("RawIntDen",0);
			run("Clear Results");
			
			
			

			Imagename1=newArray(1);
			AcetylTub_Sum1=newArray(1);
			AlphTub_Sum1=newArray(1);
			RatioSum_Acetyl_alpha1=newArray(1);
			
			
			
			AcetylTub_Sum1[0]=RawIntDen_acet_Tub;
			AlphTub_Sum1[0]=RawIntDen_alpha_Tub;
			RatioSum_Acetyl_alpha1[0]=RawIntDen_acet_Tub/RawIntDen_alpha_Tub;
			Imagename1[0]=name1;


			AcetylTub_Sum=Array.concat(AcetylTub_Sum,AcetylTub_Sum1);
			AlphTub_Sum=Array.concat(AlphTub_Sum,AlphTub_Sum1);
			RatioSum_Acetyl_alpha=Array.concat(RatioSum_Acetyl_alpha,RatioSum_Acetyl_alpha1);
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
	setResult("RawIntDen of AcetylTub",i,AcetylTub_Sum[i+1]);
	setResult("RawIntDen of Alpha-Tubulin",i,AlphTub_Sum[i+1]);
	setResult("Ratio of Acetyl/alpha Tubulin RawIntDen",i,RatioSum_Acetyl_alpha[i+1]);	
	
}
updateResults();
selectWindow("Results");
saveAs("Results",myDir+"WholeCell_AcetylTub_AlphaTub.xls");

