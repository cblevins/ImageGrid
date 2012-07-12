DESCRIPTION
ImageGrid is a Processing program for visually analyzing images using a grid interface. The user divides a single image into different categories by selecting cells within a grid. The program then outputs data on how many cells in the grid were assigned to different categories.

QUICK START GUIDE

Before you begin:
- Create a folder containing the image(s) you wish to analyze
- Set optional preferences under Programmer Choices - window size, number of columns and rows, number of categories, etc.

Interface:
- Run the program and select the folder containing the image(s) you wish to analyze
- Choose a primary and secondary category using keypresses: 
  - Only one primary category will be in effect at a time
  - Multiple secondary categories can be in effect at a time
- Select cells by clicking, holding, and dragging the mouse inside of cells
- Selecting a cell will: 
  - COLOR the cell according to the chosen primary category 
  - Overlay one or more CHARACTER SYMBOLS in the cell according to the secondary category or categories
- Use the Arrow keys or Scroll wheel to move through the image if it doesn't fit in the window
- When finished with the image file, hit "RETURN"/"ENTER"

Output:
- Each time the user hits "RETURN"/"ENTER," the program creates two text files:

1. Summary file (filename_summary.txt):
- A summary file with the number of cells and percentages for each primary and secondary category.

2. Cell file (filename_cells.txt)
- The text file consists of a comma-separated table with each row corresponding to one cell in the grid for that image.
- The columns are:
  - Row: Row number of the cell in the grid (sequence starts at 0)
  - Col: Column number of the cell in the grid (sequence starts at 0)
  - Pixels: Number of pixels in the cell 
  - Primary: Name of the primary category
  - Secondary01: "1" if the cell was assigned the first secondary category, "0" if the cell was not
  - Secondary02: "1" if the cell was assigned the second secondary category, "0" if the cell was not
  - ... as many secondary categories as the user has specified 

Notes:
- If a user wishes to modify a previously-analyzed image, they can simply re-run the program. The program will use the existing output text file for an image to load its saved information into the grid, allowing the user to tweak the cell categorizations without starting over.

Advanced options:
- A section of code titled "RE-ANALYZE" allows the user to re-analyze images using a different sized grid. Un-comment this section of code to archive the most recent analysis as a separate text file (filename_cells_archive.txt) before creating new output text files. This creates a back-up using the previous grid dimensions. 
 
CREDITS
ImageGrid was created by Bridget Baird and Cameron Blevins and released in July 2012 under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 

For more information see http://www.cameronblevins.org/imagegrid/ 