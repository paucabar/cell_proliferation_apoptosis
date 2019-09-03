
#@ File(label="Select a directory (raw data):", style="directory") dir1
#@ File(label="Select a directory (outlines):", style="directory") dir2

list1=getFileList(dir1);
list2=getFileList(dir2);

Array.sort(list2);
tiffFiles=0;

//count the number of TIFF files in dir2
for (i=0; i<list2.length; i++) {
	if (endsWith(list2[i], "tiff")) {
		tiffFiles++;
	}
}

//check that  dir2 contains TIFF files
if (tiffFiles==0) {
	beep();
	exit("No TIFF files")
}

//create a an array containing only the names of the TIFF files in dir2
tiffArray=newArray(tiffFiles);
count=0;
for (i=0; i<list2.length; i++) {
	if (endsWith(list2[i], "tiff")) {
		tiffArray[count]=list2[i];
		count++;
	}
}

//Extraction of the ‘well’ and ‘field’ information from the images’ filenames
//calculate: number of wells, images per well, images per field and fields per well
nWells=1;
nFields=1;
well=newArray(tiffFiles);
field=newArray(tiffFiles);
well0=substring(tiffArray[0],0,6);
field0=substring(tiffArray[0],11,14);

for (i=0; i<tiffArray.length; i++) {
	well[i]=substring(tiffArray[i],0,6);
	field[i]=substring(tiffArray[i],11,14);
	well1=substring(tiffArray[i],0,6);
	field1=substring(tiffArray[i],11,14);
	if (field0!=field1 || well1!=well0) {
		nFields++;
		field0=substring(tiffArray[i],11,14);
	}
	if (well1!=well0) {
		nWells++;
		well0=substring(tiffArray[i],0,6);
	}
}

wellName=newArray(nWells);
imagesxwell = (tiffFiles / nWells);
fieldsxwell = nFields / nWells;
for (i=0; i<nWells; i++) {
	wellName[i]=well[i*imagesxwell];
}

Array.sort(list1);
tifFiles=0;

//count the number of TIF files in dir1
for (i=0; i<list1.length; i++) {
	if (endsWith(list1[i], "tif")) {
		tifFiles++;
	}
}

//check that  dir1 contains TIF files
if (tifFiles==0) {
	beep();
	exit("No TIF files")
}

//create a an array containing only the names of the TIF files in dir1
tifArray=newArray(tifFiles);
count=0;
for (i=0; i<list1.length; i++) {
	if (endsWith(list1[i], "tif")) {
		tifArray[count]=list1[i];
		count++;
	}
}

imagesxfield=0;
change=false;
field0=substring(tifArray[0],11,14);
while (!change) {
	imagesxfield++;
	field1=substring(tifArray[imagesxfield],11,14);
	if (field0!=field1) {
		change=true;
	}
}


//channels
channelsArray=newArray(imagesxfield);
for (i=0; i<imagesxfield; i++) {
	index1=indexOf(tifArray[i], "wv");
	index2=indexOf(tifArray[i], ".tif");
	channelsArray[i]=substring(tifArray[i], index1+3, index2);
}

//dialog
Dialog.create("Montage");
Dialog.addChoice("Well", wellName);
Dialog.addChoice("Channel", channelsArray);
Dialog.show();
selectWell=Dialog.getChoice();
selectChannel=Dialog.getChoice();

//start image
for (i=0; i<imagesxfield; i++) {
	if (selectChannel==channelsArray[i]) {
		startImage=i+1;
	}
}

//import
run("Image Sequence...", "open=["+dir1+"] file=["+selectWell+"] sort");
rename("raw_sequence_all");
Stack.getDimensions(width, height, channels, slices, frames);
run("Make Substack...", "delete slices="+startImage+"-"+slices+"-"+imagesxfield);
run("Enhance Contrast", "saturated=0.1 normalize");
run("RGB Color");
run("8-bit Color", "number=256");
rename("raw_sequence");
close("raw_sequence_all");
run("Image Sequence...", "open=["+dir2+"] file=["+selectWell+"] sort");
rename("outlines_sequence");
run("8-bit Color", "number=256");

//merge
run("Merge Channels...", "c1=raw_sequence c2=outlines_sequence create");
rename(selectWell);
run("Channels Tool...");