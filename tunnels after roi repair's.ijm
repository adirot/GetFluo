//choose parameters for data analysis
#@ Integer(label="nuber of pos") posnumber
#@ String(label="file name (YFP/GFP/cheery/else)") top
#@ Integer(label="first image") startYFP
#@ Integer(label="jump") jump
#@ Integer(label="nuber of frames") Number
#@ Integer(label="min partical size ") Size
start=startYFP;
#@ File(style="roi") myroi
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
	//mesured photos opener
	run("Image Sequence...", "open=myFile number=Number starting=start increment=jump file="+top+" "+ " sort");
	photo = getTitle();
	run("Subtract Background...", "rolling=50 stack");
	//analyze
	open(myroi);
	//measure YFP by roi
	selectWindow(photo);
	roiManager("Measure");
	//trace
	j=0; Size=50;
	for (i = 0; i <= nResults-1; i++) {
		n=0;
		d=1.5*Size;
		m=getResult("Slice", i);
		if(m == 1) {
			//setting the first partical
	   		j=i+1;
	   		ex="mean"+j;
	   		dx="area"+j;
	   		color=random*255;
	   		x1= getResult('XM', i);
	    	y1= getResult('YM', i);
	    	//tracking
	   		for (k = 0; k <= nResults-1; k++) {
	   			if((getResult("Slice", k)==n+1)) {
	   				x= getResult('XM', k);
	 			   	y= getResult('YM', k);
	 			   	D=sqrt((abs(x1-x))^2+abs(y1-y)^2);
	 			   	
	   				if (D<=d) {
	   					roiManager("Select", k);
	   					Roi.setStrokeColor(color);
	   					setResult(ex, n,getResult("Mean", k) );
	   					setResult(dx, n,getResult("Area", k) );
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
	//saving the mean and area
	//IJ.deleteRows(nSlices,nResults-1)
	saveAs("Results",path+photo+".csv");
	roiManager("Save", path+photo+".zip");
	//making ram free
	//run("Close All");
}