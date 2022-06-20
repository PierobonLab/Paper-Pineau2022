myDir = getDirectory("Choose a Directory ");

list = getFileList(myDir);

for (k=0; k<list.length; k++) {
	print(list[k]);
  if (!(endsWith(list[k], "/")) & (endsWith(list[k], ".tif"))){
			name=list[k];
			path=substring(name,0,lengthOf(name)-4);
			print(path);
			open(myDir+list[k]);
			setBatchMode("hide");
			runMacro("~/AnalysisDropCellMTOCnuc.ijm");
			setBatchMode("show");
  }
}
