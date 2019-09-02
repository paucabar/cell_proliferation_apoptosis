
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
imagesxfield = (tiffFiles / nFields);
fieldsxwell = nFields / nWells;
for (i=0; i<nWells; i++) {
	wellName[i]=well[i*imagesxwell];
}