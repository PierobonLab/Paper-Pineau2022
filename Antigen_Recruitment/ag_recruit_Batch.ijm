myname=getTitle();
mydir=File.directory;
nframes=nSlices()/42;
run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices=21 frames="+nframes+" display=Color");
run("Duplicate...", "title=drop duplicate channels=1");
close(myname);

transdir=mydir+"Trans/";
transname=substring(myname, 0, lengthOf(myname)-9)+"Trans"+substring(myname, lengthOf(myname)-5,lengthOf(myname)-4)+".tif";
open(transdir+transname);
rename("trans");
run("script:/home/paolo/Documents/PROJECTS/Judith/Recruit_correct/ag_recruit_useTrans_thirdback.ijm");
print(myname);
