//choose parameters for data analysis
#@ Integer(label="nuber of pos") posnumber
#@ String(label="file name (YFP/GFP/cheery/else)") top
#@ Integer(label="YFP first image") startYFP
#@ Integer(label="jump") jump
#@ Integer(label="nuber of frames") Number
#@ Integer(label="min partical size ") Size
#@ String(label="trashold method") trash
#@ String(label="trashold",choices={"Default", "IsoData","Yen","Minimum"},style="list") trash
#@ Boolean(label="exclude on edges") exclude
#@ Boolean(label="hard to trash hold?") hard
#@ Boolean(label="fill") fil
start=startYFP
//manually choose positions and a directory for results
setOption("ExpandableArrays", true); 
poslist=newArray();
for (i = 0; i <=posnumber-1; i++) {
	idir=getDirectory("Choose pos"+i+1);
	ifile=getFileList(idir);
	poslist[i]=idir+ifile[10];
}
path=getDirectory("results directory");
run("Set Measurements...", "area mean min center median kurtosis area_fraction stack display redirect=None decimal=3");
for (pos = 0; pos <=posnumber-1; pos++) {
	red=newArray(); green=newArray(); blue=newArray();
	myFile=poslist[pos];
	//open Image Sequence  for Phase (change starting and increment if needed)
	run("Image Sequence...", "open=myFile number=Number starting=start increment=jump file=YFP convert  sort");
	//mask making + saving
	run("Auto Threshold", "method="+trash+" white stack");
	if (hard) {
		run("Convert to Mask", "method=Default background=Default calculate");
		run("Watershed", "stack");
		}
	run("Analyze Particles...", "size="+"Size"+"-Infinity display clear include summarize add stack");
	saveAs("Tiff", myFile+"mask");
	//YFP opener
	run("Image Sequence...", "open=myFile number=Number starting=start increment=jump file="+top+" "+ " sort");
	photo = getTitle();
	run("Subtract Background...", "rolling=50 stack");
	//analyze
	selectWindow("Results"); 
	run("Close" );
	//measure YFP by roi
	selectWindow(photo);
	roiManager("Measure");
	//trace
	particlenumber=0; Size=50;
	for (particle = 0; particle <= nResults-1; particle++) {
		slicenum=0;
		minD=Size*0.1;
		red[particle] = random*255; blue[particle] = random*255; green[particle] = random*255;
		if(getResult("Slice", particle)== 1) {
			//setting the first partical
	   		particlenumber=particle+1;
	   		meanNo="mean"+particlenumber;
	   		areaNo="area"+particlenumber;
	   		xNo="x"+particlenumber;
	   		yNo="y"+particlenumber;
	   		color=random*255;
	   		firstx= getResult('XM', particle);
	    	firsty= getResult('YM', particle);
	   		for (current = 0;  current< nResults; current++) {
	   			if((getResult("Slice", current)==slicenum+1)) {
	   				x= getResult('XM', current);
	 			   	y= getResult('YM', current);
	 			   	currentD=sqrt((abs(firstx-x))^2+abs(firsty-y)^2);
	   				if (currentD<=minD) {
	   					roiManager("Select",current );
	   					Roi.setStrokeColor(red[particle],green[particle],blue[particle]);
	   					setResult(meanNo, slicenum,getResult("Mean", current) );
	   					setResult(areaNo, slicenum,getResult("Area", current) );
	   					setResult(xNo, slicenum,getResult("XM", current) );
	   					setResult(yNo, slicenum,getResult("YM", current) );
	   					minD=sqrt(	(abs(firstx-x))^2+abs(firsty-y)^2);
	   					x2=x;
	   					y2=y;
	   				}
	   				if (current+1<nResults) {
	   					if(getResult("Slice", current+1)==slicenum+2){
	  	 					firsx=x2;
	   						firsty=y2;
	   						slicenum=slicenum+1;
	   						minD=Size*0.1;	
	   					}
	   				}	
	   			}
	   		}
		}
	}
	IJ.deleteRows(nSlices,nResults-1)
	saveAs("Results",path+photo+".csv");
	//saving the mean and area of bg
	selectWindow("Results");
	run("Close");
	startbg=nResults+1;
	run("ROI Manager...");
	run("Select All");
	roiManager("Delete");
	makeRectangle(69, 46, 257, 170);
	roiManager("Add");
	roiManager("Select", 0);
	roiManager("Rename", "bg");
	roiManager("multi-measure measure_all append");
	for (i = startbg; i < nResults; i++) {
    setResult("bgmean", i-startbg,getResult("Mean", i) );
    setResult("bgarea", i-startbg,getResult("Area", i) );
    IJ.deleteRows(nSlices,nResults-1)
	saveAs("Results",path+photo+"bg"+".csv");
	//roiManager("Save", path+photo+".zip");
	//making ram free
	//run("Close All");
}
