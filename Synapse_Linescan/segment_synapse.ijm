
mydir=File.directory; 
name=getTitle();
run("Split Channels");

// convert8 bit
selectWindow("C2-"+name);
rename("Syn");
getVoxelSize(width, height, depth, unit);
zBlur=6*width/depth;
run("Gaussian Blur 3D...", "x=6 y=6 z="+zBlur);
Stack.getStatistics(voxelCount, mean, min, max, stdDev);
setMinAndMax(min, max);
run("8-bit");
Stack.setXUnit("pixel");
Stack.setYUnit("pixel");
Stack.setZUnit("pixel");


// binarize and save
run("Auto Threshold", "method=MaxEntropy white stack use_stack_histogram");
// run("3D Objects Counter", "threshold=128 slice=1 min.=20 max.=13939002 exclude_objects_on_edges objects statistics summary");
run("3D Objects Counter", "threshold=128 slice=1 min.=1000 max.=13939002 objects statistics summary");

keep_biggest_obj("Objects map of Syn", nResults);
selectWindow("Objects map of Syn");
saveAs("Tiff", mydir+name+"_maskSyn.tif");
run("Close All");
run("Clear Results");

// feed with the objects windows where the largest is the one of interest
function keep_biggest_obj(nameObj, nObj){ 
	selectWindow(nameObj);
	if (nObj>1){
		sel=select_biggest(nObj);
		run("3D Manager");
		Ext.Manager3D_AddImage();
		Ext.Manager3D_Select(sel);
		Ext.Manager3D_Delete();
		Ext.Manager3D_SelectAll();
		Ext.Manager3D_Merge();
		Ext.Manager3D_FillStack(0, 0, 0);
		Ext.Manager3D_Erase();
		Ext.Manager3D_Close();
	}		
	run("Multiply...", "value=255 stack");
}

function select_biggest(nObj){
	v=newArray(nObj);
	for (i = 0; i < nObj; i++) {
			v[i]=getResult("Volume (pixel^3)", i);
	}
	Array.print(v);
	rankPosArr = Array.rankPositions(v);
	Array.print(rankPosArr);
	sel=rankPosArr[nObj-1];
	return sel;
}
