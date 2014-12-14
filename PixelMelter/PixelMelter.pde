/*
Given an area of pixels and a length to extend
 Take image and request isolated area to stretch
 Divide that area into its pixel length
 Distance/pixel height = length of pixel boogie
 current pixel section = first
 
 create new graphic
 for (still pixels to place)
 {
 for (placed < next section checkpoint)
 {
 if first -> place straight, according to last displace
 if after -> Displace to +/- tolerance of previous
 }
 move current to next pixel section
 }
 if acceptable, save with incrementing filename and remake,
 else discard and remake
 */

PImage src;
PGraphics out;

int iX = 0, iY = 0; //Initial coords for selection draw
int fX = 0, fY = 0; //Final coords for selection draw
boolean selecting = false;
boolean drawing = false;

void setup()
{
  src = loadImage("Smelleph.png");
  src.loadPixels();



  int sw = src.width;
  int sh = 838; //Should change with mode

  out = createGraphics(sw, sh);

  size(sw, sh);

  rectMode(CORNERS);
}

//Start region: 0,180
//End region: 538,263

void draw()
{
  background(100);
  image (src, 0, 0);
  /*if (selecting && !drawing)
   {
   fX = mouseX;
   fY = mouseY;
   noFill();
   stroke(255,0,0);
   rect(iX, iY, fX, fY);
   }*/
  noFill();
  stroke(255, 0, 0);
  //THIS IS HARD CODED AND UGLY vvv
  int t = 180;
  int b = 538;
  rect(0, 180, 538, 263);

  float meltedRegion = (height-263);
  int divisions = floor(meltedRegion / (263-180));  
  println(divisions);
  //THIS IS HARD CODED AND UGLY ^^^

  int currentRegion = t;
  out.beginDraw();
  color[] c = new color[src.width];
  int row = 0;
  int index = 0;
  int yPlace = 0;
  while (row < src.height && yPlace < height)
  {
    //Runs always if out of the section to melt
    //Runs in the section iff entering a new pixel division
    println("yPlace: " + yPlace + ", currentRegion: " + currentRegion + ", " + row);
    if (row < t || row >= b) 
    {
      while (index < src.width)
      {
        c[index] = src.pixels[index+(row*src.width)];
        index++;
      }
      row++;
      if (row > b)
      {
       println("I'm finishing."); 
      }
    }
    else if(yPlace == currentRegion && currentRegion < b)
    {
      println("THIS IS HAPPENING *******************");
      while (index < src.width)
      {
        c[index] = src.pixels[index+(row*src.width)];
        index++;
      }
      currentRegion += divisions;
      row++;
    }
    index = 0;
    while (index < src.width)
    {
      out.set(index, yPlace+src.height, c[index]);
      //println("Placing " + red(c[index]) + ", " + green(c[index]) + ", " + blue(c[index]) + " at " + index + ", " + (row+src.height)); 
      index++;
    }
    yPlace++;
    
    index = 0;    
    println("Running " + millis() + ": " + yPlace);
  }
  out.endDraw();
  image(out, 0, -src.height);
  noLoop();
}

void mouseClicked()
{
  if (!selecting)
  {
    drawing = false;
    iX = mouseX;
    iY = mouseY;
    selecting = true;
  } else
  {
    fX = mouseX;
    fY = mouseY;
    selecting = false;
    drawing = true;
    println("(" + iX + ", " + iY + ") (" + fX + ", " + fY + ")");
  }
}

