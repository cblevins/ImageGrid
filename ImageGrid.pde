/*
DESCRIPTION:
A program for visually analyzing images using a grid interface. The user divides a single image into different categories by selecting cells within a grid. The program then outputs data on how many cells in the grid were assigned to different categories.

PROGRAMMER CHOICES: 
- Width and height of window (scrolling takes place)
- Number of columns in the grid; either the number of rows will be determined automatically in order to make
the pixel size of cells as square as possible (default) or the programmer can manually specify the number of rows
- Color of grid lines
- Primary Category:
  - Name of each primary category
  - Color of each primary category
  - Keypress to select each primary category
- Secondary Category:
  - Name of each secondary category
  - Character symbol of each secondary category to be overlaid onto the cell
  - Keypress to select each secondary category
  - Keypress to deselect/toggle off all currently selected secondary categories
  - Color for character symbols to be overlaid
- Possible file types for incoming images files (ex. JPG, PNG, TIFF, etc.)
- Name of output text file: name of image file + user-selected suffix

CREDITS:
ImageGrid was created by Bridget Baird and Cameron Blevins and released in July 2012 under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
For more information see http://www.cameronblevins.org/imagegrid/ 
*/

/****************************PROGRAMMER CHOICES*********************************************/

int width=1000;        //size of window
int height=900; 

int col=15;        //number of columns in grid
int row=-1;  //number of rows in grid; if set to -1 the number of rows will be 
              //determined so that cells are roughly square

color gridColor=color(255,0,0);    //color of grid lines

//primary categories - first category is the default category
String[] primCat = new String [] {"Prim0", "Prim1", "Prim2", "Prim3", "Prim4", "Prim5", "Prim6"};  
int alph=50;    //transparency factor for coloring

//first color will be transparent: default with no coloring
color[] primCatColors=new color[] {color(0, 0, 0, 1), color(0, 0, 255, alph), color(150, 150, 0, alph), 
    color(0, 255, 0, alph), color(255, 140, 0, alph), color(255, 0, 0, alph), color(0, 150, 150, alph)};
char[] primCatKeys = new char[] {'0', '1', '2', '3', '4', '5', '6'}; //the keypresses for primary categories
int primCatDefaultIndx=0;  //Select which category will be the default the user begins with for each image

//secondary categories
String[] secCategories=new String[] { "SecA", "SecB", "SecC", "SecD", "SecE"}; 
char[] secSymbols = new char[] {'A', 'B', 'C', 'D', 'E'};    //symbols that will appear for secondary categories
char[] secKeys = new char[] {'a', 'b', 'c', 'd', 'e'};   //keypresses for secondary categories
char clearKey='.';          //keypress that will clear secondary categories
color secColor=color(255, 0, 0);  //color for secondary categories
int secDefaultIndx=-1;      //begin with no secondary category selected - change 0,1,2,etc. to re-assign default

String[] imSuffix= new String[] {".jpg",".jpeg",".png"};    //possible suffixes for image files
String suffixCells="_cells.txt";    //suffix for output file for all cells, file will be comma-delimited
String suffixSummary="_summary.txt";  //suffix for output file for summary stats, file will be comma-delimited

/********************************************************************/

int[][] grid;      //array to keep track of primary category of each cell
int numSec=secKeys.length;                //total number of secondary categories
int[][][] sec;      //array for secondary categories are present in a particular cell
int [] currentSec=new int[numSec];     //array keeps track of which secondary categories are currently in effect

PImage currentIm;            //current image

PrintWriter output;      //output file for information
String folderPath;    //folder path for images, chosen by user
String [] fileNames;  //array of file names in the folder
int currIndx;      //current index in array fileNames

PFont font, font1, font1Bold;

    //amount image is shifted horizontally or vertically
int hShift=0;      
int vShift=0; 
int scrollFactor=50;      

int imwidth;    //size of image- will be set when an image is read in
int imheight;  
float incC;        //size of cells in pixels
float incR;

int currentPrimCatIndx=primCatDefaultIndx;
int numPrimCat=primCat.length;         //total number of primary categories
int [][] count=new int[numPrimCat][numSec+1];  //count totals
int [] totSec = new int[numSec];


float mouseStartX, mouseStartY;    //start of mouse dragging
boolean  locked=false;            //mouse not currently dragging
boolean imageDisplay=true;    //toggle to move from image display to text display

void setup() {
  println ("Beginning...");
  size(width, height);
  rectMode(CORNERS);    //call rect with x1,y1 and x2,y2 as parameters
  
  font1=createFont("Garamond",18);  
  font1Bold=createFont("Garamond-Bold",18);

        //addMouseWheel
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }} ); //addMouseWheelListener
    
              //get the files in the directory
  folderPath=selectFolder();
  File file = new File(folderPath);
  if (file.isDirectory()) {
    fileNames = file.list(); 
  }
  else println("Didn't select a proper folder");
  print("Selected folder is ");
  println(folderPath);  
  folderPath=folderPath+"/";  
  
  currIndx=0;
  currIndx=findNextImageFile(fileNames, currIndx);
  if (currIndx!=-1)  newImage(fileNames[currIndx]);
}          //end setup

//draw function called repeatedly
void draw() {
  if (currIndx==-1) { //done- exit 
    println("Done...");   
    exit();
    return;
  }
  fill (255);        //set up background white rectangle
  rect(0, 0, width, height);
  if (!imageDisplay)  {
    summaryText();
    return;
  }
  image(currentIm, -hShift, -vShift);  //draw current image
      //set up grid lines
  stroke (gridColor);
  for (int i=0;i<=col;i++)
    line(-hShift+incC*i, -vShift, -hShift+incC*i, -vShift+imheight);
  for (int i=0;i<=row;i++)
    line(-hShift, -vShift+incR*i, -hShift+imwidth, -vShift+incR*i);
      //put semi-transparent colors on cells according to numbers in grid array
  for (int i=0;i<row;i++)
    for (int j=0;j<col;j++) {
      fill(primCatColors[grid[i][j]]);
      rect(-hShift+incC*j, -vShift+incR*i, -hShift+incC*(j+1), -vShift+incR*(i+1));
      writeText(i, j, -hShift+incC*j, -vShift+incR*i);
    }
}

//if in the current image, get the starting mouse position, lock until mouse is released
void mousePressed() {
  if ((locked==false) && inImage()) {  
        //get coordinates of starting click if within image
    mouseStartX=mouseX;
    mouseStartY=mouseY;
    locked=true;
  }
}

//if started and ended in the image, fill in the categories in the proper boxes
void mouseReleased() {
  if ((locked==true) &&inImage()) {
        //find rectangles from starting mousepress to mouse release- put them in the grid array
    float startX=min(mouseX, mouseStartX)+hShift;
    float endX=max(mouseX, mouseStartX)+hShift;
    float startY=min(mouseY, mouseStartY)+vShift;
    float endY=max(mouseY, mouseStartY)+vShift;
    int numX1=int(startX/incC);  
    int numY1=int(startY/incR);
    int numX2=int(endX/incC);
    int numY2=int(endY/incR);

    for (int i=numY1; i<=numY2; i++)
      for (int j=numX1;j<=numX2;j++) {
        grid[i][j]=currentPrimCatIndx;
        for (int k=0;k<numSec;k++)
          sec[i][j][k]=currentSec[k];
      }
  }
  locked=false;
}

//process the key presses
void keyPressed() {
      //if ending an image then put stats in the file      
  if ((key==RETURN) || (key==ENTER)) { 
    if (imageDisplay)  {    
      writeFiles();      //write stats to a file and summary stats to the screen
      imageDisplay=false;
      return;
    }
    else  {
          //increment index and get the next image, if there is one
      currIndx++;    
      currIndx=findNextImageFile(fileNames, currIndx);
      if (currIndx!=-1)  newImage(fileNames[currIndx]);
      imageDisplay=true;
      return;
    }
  }  
      //check for arrow keys
  if (key==CODED) {
    if (keyCode==RIGHT)
      hShift+=scrollFactor;
    else if (keyCode==LEFT)
      hShift-=scrollFactor;
    else if (keyCode==UP)
      vShift-=scrollFactor;
    else if (keyCode==DOWN)
      vShift+=scrollFactor;
  }            //arrow keys
      //check for primary category keys and if so set current category index
  for (int i=0;i<numPrimCat; i++)
    if (key==primCatKeys[i]) 
      currentPrimCatIndx=i;
      //check for secondary categories and if so enter in secondary category
  for (int i=0; i<numSec; i++) 
    if (key==secKeys[i])   
      currentSec[i]=1;

  if (key==clearKey)  //turn off all secondary categories
    for (int k=0;k<numSec;k++)
      currentSec[k]=0;
}      //end keyPressed

//check if mouse coords within image
boolean inImage() {
  if ((mouseX>=-hShift)&&(mouseX<=(imwidth-hShift))
    &&(mouseY>=-vShift) && (mouseY<=imheight-vShift)) 
    return true;
  else return false;
} 

//if mousewheel used set the vertical shift
void mouseWheel(int delta) {
  vShift+=scrollFactor*delta;
}

//takes an index into the array of files and finds the next image file
//returns the index number if found and -1 if no other ones
int findNextImageFile(String[] names, int indx)  {
  int imIndx;
  int len=names.length;
  boolean found=false;
  while (!found)  {      //look for an image file
    if (indx==-1 || indx>=len) return -1;
    for (int i=0;i<imSuffix.length; i++)  {
      imIndx=names[indx].lastIndexOf(imSuffix[i]);
      if (imIndx!=-1) found=true;
    }
    if (!found) indx++;    //look at next file
  }
   return indx;
}
    
//set up for new image: load, set up width, height, grid lines, categories
//if a stats file already exists for the image then load that information
void newImage(String name) {
  currentIm=loadImage(folderPath+name);    //load current image
  imwidth= currentIm.width;        //use image to set width and height
  imheight=currentIm.height;
  vShift=0;
  hShift=0;
  incC=float(imwidth)/col;        //size of cells - column width in pixels 
        //calculate number of rows
  if (row<=0)                //calculate rows so grids are approximately square
    row=int(float(imheight)/incC);
  incR=float(imheight)/row;      // size of cells - row height in pixels
                      //determine text size for letters in secondary categories
  if (incC*incR>2500 )
    font=createFont("Garamond",12);  //can change the font or the size
  else font=createFont("Garamond",6);  //make font size smaller
            //initialize
  grid = new int[row][col];
  sec= new int[row][col][numSec];  
  for (int i=0;i<row;i++)  
    for (int j=0;j<col;j++)  {
      grid[i][j]=primCatDefaultIndx;
      for (int k=0;k<numSec;k++)  
        sec[i][j][k]=0;
    }
  for (int k=0;k<numSec; k++)      //no secondary categories currently chosen
    currentSec[k]=0;
  currentPrimCatIndx=primCatDefaultIndx;

  println("Starting "+name);
      //read in the stats file if it is there
  int indx=name.lastIndexOf(".");
  String shortName=name.substring(0,indx);    //remove ending
  boolean foundFile=false;
  for (int i=0;i<fileNames.length;i++)
    if (fileNames[i].equals(shortName+suffixCells)) foundFile=true;
  if (!foundFile) return;      //didn't find the stats file
  String[] fileLines;
  int rowNum, colNum, category;
  fileLines = loadStrings(folderPath+shortName+suffixCells);
  if (fileLines==null)   {    //didn't find the stats file so end the function
    println("no stats file");
    return;
  }
/* 
  //RE-ANALYZE
  //Re-analyze images using a different-sized grid and save previous analysis
  //if number of rows and columns don't match the data file give message, save in an archive file and don't read
  if ((row*col+1)!=(fileLines.length)) {
    println("problem with rows and columns in "+name);
    println("writing current file(s) to archive");
    saveStrings(folderPath+shortName+"_archive_"+suffixCells,fileLines);
    String[] summaryLines;
    summaryLines=loadStrings(folderPath+shortName+suffixSummary);
    if (summaryLines!=null)
      saveStrings(folderPath+shortName+"_archive_"+suffixSummary,summaryLines);
    return;
  }
*/
      //if data file is there read it in with designations
  String[] pieces;
  for (int i=1; i<fileLines.length;i++) {
    pieces=split(fileLines[i], ',');
        //make sure the right number of columns: row, col, pixels, primary and secondary categories
    if (pieces.length==(3+numSec)) {    
      rowNum=int(pieces[0]);
      colNum=int(pieces[1]);
      String catName=pieces[2];      //find primary category number
      category=-1;
      for (int j=0; j<numPrimCat;j++)
        if (primCat[j].equals(catName)) category=j;
      if (category==-1)
        println ("problem with primary category names in stats file");
      grid[rowNum][colNum]=category;
      for (int j=0; j<numSec;j++)      //find all the secondary categories
        sec[rowNum][colNum][j]=int(pieces[3+j]);
    }      //if a good line
    else {
      println ("problem with number of columns in stats file");
      break;
    }
  }
}  

//write secondary categories in the corners of the cell 
// i,j tells which cell; x1,y1 coordinates of upper left corner
void writeText(int i, int j, float x1, float y1) {
  fill(secColor); // change color of font for secondary categories
  textFont(font);
  for (int k=0;k<numSec;k++)
    if (sec[i][j][k]==1) {
      char ch=secSymbols[k];
      text(ch, x1+((k+.5)*(incC/numSec)), y1+((k+1)*incR/numSec)); //positions the text within the grid relative to upper left-hand corner
    }
}

//called when done with one image
//writes one file with all the cell info and another with summary info
//write summary stats to screen
void writeFiles() {
      //create a text file with all the grid info
  PrintWriter pageOutput;
  int indx=fileNames[currIndx].lastIndexOf(".");
  String shortName=fileNames[currIndx].substring(0,indx);
  pageOutput = createWriter(folderPath+shortName+suffixCells);  //create output file for writing
  pageOutput.print("row"+","+"col"+","+"Primary"+",");
  for (int k=0;k<numSec-1;k++)
    pageOutput.print(secCategories[k]+",");
  pageOutput.println(secCategories[numSec-1]);
        //initialize counts
  for (int u=0;u<numPrimCat; u++)
    for (int v=0;v<numSec+1;v++)
      count[u][v]=0;
  for (int i=0;i<row; i++)
    for (int j=0;j<col;j++) {
      pageOutput.print(str(i)+","+str(j)+","+primCat[grid[i][j]]+",");
          //increment total for that primary category and place at end
      count[grid[i][j]][numSec]+=1;
      for (int k=0;k<numSec;k++)  {  
        pageOutput.print(str(sec[i][j][k]));  //write secondary categories 
        if (k!=numSec-1)  
          pageOutput.print(",");
        else pageOutput.println();
        if (sec[i][j][k]==1)
          count[grid[i][j]][k]+=1;
       }      
    }   
  pageOutput.flush();
  pageOutput.close();
      //write summary stats to file and to the screen
  int totCells=row*col;
  pageOutput = createWriter(folderPath+shortName+suffixSummary);  //create output file for writing
  pageOutput.print("PrimCat"+","+"totalCells"+",");
  for (int k=0;k<numSec;k++)  {
    pageOutput.print(secCategories[k]);
    if (k!=numSec-1)
      pageOutput.print(",");
    else pageOutput.println();
  }
  for (int u=0;u<numPrimCat; u++)  {
    pageOutput.print (primCat[u]+","+ count[u][numSec]+",");
    for (int k=0;k<numSec;k++)  {
      pageOutput.print(count[u][k]);      
      if (k!=numSec-1)
        pageOutput.print(",");
      else pageOutput.println();
    }
  }
                //write out totals by adding up
  pageOutput.print("Totals,"+str(totCells)+",");
  for (int k=0;k<numSec; k++)  {
    totSec[k]=0;
    for (int u=0;u<numPrimCat; u++)  
      totSec[k]+=count[u][k];
    pageOutput.print(str(totSec[k]));
    if (k!=numSec-1)
       pageOutput.print(",");
    else pageOutput.println();    
 }
  pageOutput.flush();
  pageOutput.close();        
}

//draw summary stats on screen
void summaryText()  {
  fill(0);
  textFont(font1Bold);
  text("Number of cells (percentages) for each category:",50,50);
  for (int u=0;u<numPrimCat;u++)  {
    textFont(font1); 
    text(primCat[u]+": ",50,100+25*u);
    textFont(font1Bold);
    text(str(count[u][numSec])+" ("+str(int(count[u][numSec]/float(row*col)*1000)/10.0)+"%)",250,100+25*u);
  }
  for (int k=0;k<numSec;k++)  {
    textFont(font1); 
    text(secCategories[k]+": ",50,130+25*numPrimCat+25*k);
    textFont(font1Bold);
    text(str(totSec[k])+" ("+str(int(totSec[k]/float(row*col)*1000)/10.0)+"%)",250,130+25*numPrimCat+25*k);
  }
  textFont(font1);
  text("Press ENTER or RETURN to continue",100,150+numPrimCat*25+numSec*25);
}
