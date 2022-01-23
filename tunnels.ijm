//choose parameters for data analysis
#@ Integer(label="nuber of pos") posnumber
#@ File (label="Select Background", style="file") BG
#@ String(label="file name (YFP/GFP/cheery/else)") top
#@ Integer(label="YFP first image") startYFP
#@ Integer(label="jump") jump
#@ Integer(label="nuber of frames") Number
#@ Integer(label="min partical size ") Size
//#@ String(label="trashold method") trash
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
	myFile=poslist[pos];
	//open Image Sequence  for Phase (change starting and increment if needed)
	run("Image Sequence...", "open=myFile number=Number starting=start increment=jump file=YFP convert  sort");
	//mask making + saving
	/*run("Set Measurements...", "mean redirect=None decimal=3");
		 for (i = 1; i <= nSlices; i++) {
		setSlice(i);
		run("Measure");
		x=parseInt(getResult("Mean",i-1));
   		run("Subtract Background...", "rolling=30 light slice");
		if (hard) {
		run("Auto Local Threshold", "method=Bernsen radius=15 parameter_1=0 parameter_2=0");
		run("Auto Threshold", "method=Minimum");
		}else {
				run("Auto Threshold", "method=Minimum");
				}
		if (fil==true){
		run("Fill Holes", "slice"); }
	   }
		 run("Make Binary", "method=Default background=Dark calculate black");	
	saveAs("Tiff", path+"mask");selectWindow("mask.tif");
	//roi making
	run("Set Measurements...", "area mean min center median kurtosis area_fraction stack display redirect=None decimal=3");
	if (exclude==true) {
		run("Analyze Particles...", "size=Size-Infinity display exclude clear summarize add stack");
	} else {
		run("Analyze Particles...", "size=Size-Infinity display clear summarize add stack");
	}
	*/
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
	//run("Duplicate...", "title=background duplicate");
	//analyze
	selectWindow("Results"); 
	run("Close" );
	//selectWindow("Summary of" +photo +" .tif"); 
	//run("Close" );
	//measure YFP by roi
	selectWindow(photo);
	roiManager("Measure");
	//trace
	j=0; Size=25;
	for (i = 0; i <= nResults-1; i++) {
		n=0;
		d=1.5*Size;
		m=getResult("Slice", i);
		if(m == 1) {
	   		j=i+1;
	   		ex="mean"+j;
	   		dx="area"+j;
	   		x1= getResult('XM', i);
	    	y1= getResult('YM', i);
	   		for (k = 0; k <= nResults-1; k++) {
	   			if((getResult("Slice", k)==n+1)) {
	   				x= getResult('XM', k);
	 			   	y= getResult('YM', k);
	 			   	D=sqrt((abs(x1-x))^2+abs(y1-y)^2);
	 			   	
	   				if (D<=d) {
	   					
	   					roiManager("Select", k);
	   					color=random;
	   					Roi.setStrokeColor(random*255,random*255,random*255);
	   					setResult(ex, n,getResult("Mean", k) );
	   					//setResult(pathi, n,getResult("Lable", k) );
	   					d=sqrt(	(abs(x1-x))^2+abs(y1-y)^2);
	   					x2=x;
	   					y2=y;
	   				}
	   				if (k+1<nResults) {
	   					if(getResult("Slice", k+1)==n+2){
	  	 					x1=x2;
	   						y1=y2;
	   						n=n+1;
	   						d=Size;	
	   					}
	   				}	
	   			}
	   		}
		}
	}
	j=0; Size=15;
	for (i = 0; i <= nResults-1; i++) {
		n=0;
		d=1.5*Size;
		m=getResult("Slice", i);
		if(m == 1) {
	   		j=i+1;
	   		ex="mean"+j;
	   		dx="area"+j;
	   		x1= getResult('XM', i);
	    	y1= getResult('YM', i);
	   		for (k = 0; k <= nResults-1; k++) {
	   			if((getResult("Slice", k)==n+1)) {
	   				x= getResult('XM', k);
	 			   	y= getResult('YM', k);
	 			   	D=sqrt((abs(x1-x))^2+abs(y1-y)^2);
	   				if (D<=d) {
	   					setResult(dx, n,getResult("Area", k) );
	   					//setResult(pathi, n,getResult("Lable", k) );
	   					d=sqrt(	(abs(x1-x))^2+abs(y1-y)^2);
	   					x2=x;
	   					y2=y;
	   				}
	   				if (k+1<nResults) {
	   					if(getResult("Slice", k+1)==n+2){
	  	 					x1=x2;
	   						y1=y2;
	   						n=n+1;
	   						d=Size;	
	   					}
	   				}	
	   			}
	   		}
		}
	}
	/*startbg=nResults+1;
	run("ROI Manager...");
	run("Select All");
	roiManager("Delete");
	makeRectangle(69, 46, 257, 170);
	roiManager("Add");
	roiManager("Select", 0);
	55
	roiManager("Rename", "bg");
	roiManager("multi-measure measure_all append");
	for (i = startbg; i <= nResults; i++) {
    setResult(bgarea, i-startbg,getResult("Area", i) );
   	setResult(bgarea, i-startbg,getResult("Mean", i) );
	}*/
	//saving the mean and area
	IJ.deleteRows(nSlices,nResults-1)
	saveAs("Results",path+photo+".csv");
	roiManager("Save", path+photo+".zip");
	//making ram free
	//run("Close All");
}