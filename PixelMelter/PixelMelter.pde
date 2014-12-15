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
PGraphics out, pure;

int iX = 0, iY = 0; //Initial coords for selection draw
int fX = 0, fY = 0; //Final coords for selection draw
boolean selecting = false;
boolean drawing = false;
int meltedRegion = 0;

int iterations = 0;

int prevFY = 0;
int prevIY = 0;
String srcBase = "AWW";

int threshold = 15;
float period = 50;
void setup()
{
  src = loadImage(srcBase + ".jpg");
  src.loadPixels();

  int sw = src.width;
  int sh = floor((17.0*src.width)/11.0); //Should change with mode

  out = createGraphics(sw, sh);
  pure = createGraphics(sw, sh);

  size(src.width, sh);

  rectMode(CORNERS);
}

//Start region: 0,180
//End region: 538,263

void draw()
{
  background(100);
  image (src, 0, 0);

  line(0, prevIY, width, prevIY);  
  rect(0, prevFY, width, meltedRegion); 

  if (selecting && !drawing)
  {
    image (src, 0, 0);
    fX = mouseX;
    fY = mouseY;
    noFill();
    stroke(255, 0, 0);
    rect(iX, iY, fX, fY);
  }
  noFill();
  stroke(255, 0, 0);
  //THIS IS HARD CODED AND UGLY vvv
  if (drawing)
  {
    int t = iY;
    int b = fY;
    if (iY > fY)
    {
      t = fY;
      b = iY;
    }
    //    rect(0, 180, 538, 263);

    //    meltedRegion = height-t-(b-t);

    meltedRegion = height-(src.height-b);
    println("meltedRegion: " + meltedRegion + ", " + b);
    float divisions = ((meltedRegion-(t)) /(b-t));

    println((divisions * (b-t)) + " should be " + meltedRegion);  
    println(divisions);
    //THIS IS HARD CODED AND UGLY ^^^

    int currentRegion = t;
    out.beginDraw();
    pure.beginDraw();
    color[] c = new color[src.width];
    int row = 0;
    int index = 0;
    int yPlace = 0;

    //
    int melteds = 0;
    //
    //    while (row < src.height && yPlace < height)
    while (row < src.height && yPlace < height)
    {
//      println("Still running, will change pixel  "+ yPlace + " and " + row + " < " + src.height + " and (" + t + " < " + row + " < " + b + ")");
      //      println("yPlace: " + yPlace + " < " + height);
      //println("yPlace: " + yPlace + ", currentRegion: " + currentRegion + ", " + row);
      if (row < t || row >= b) 
      {
        while (index < src.width)
        {
          c[index] = src.pixels[index+(row*src.width)];
          index++;
        }
        row++;
        //        if (row > b)
        //        {
        //          println("I'm finishing.");
        //        }
      } else if (yPlace == currentRegion && yPlace <= meltedRegion+t)
      {
//        println("************************************** THIS IS HAPPENING  " + melteds);
//        println(yPlace +" == " + currentRegion + " && " + yPlace +" < " + meltedRegion + " moving to " + currentRegion);
        melteds++;
        while (index < src.width)
        {
          c[index] = src.pixels[index+(row*src.width)];
          index++;
        }
        currentRegion += divisions;
        row++;
      }
      index = 0;
      int randy = 0;
      if (random(100) < 101)
      {
        randy = floor(-1*random(cos(yPlace/period)*random(threshold),cos(yPlace/period)*random(threshold)));
      } else
      {
        randy = 0;
      }
      while (index < src.width)
      {

        //PURE VERSION:

        if (row > t && row < b)
        {
          out.set(index+randy, yPlace, c[index]);
        } else
        {
          out.set(index, yPlace, c[index]);
        }

        pure.set(index, yPlace, c[index]);

        //println("Placing at (" + index + ", " + (row+src.height) + ")"); 
        index++;
      }
      yPlace++;

      index = 0;    
      //println("Running " + millis() + ": " + yPlace);
    }
    out.endDraw();
    pure.endDraw();
    pure.save(srcBase + "Out" + iterations + "pure.png");
    out.save(srcBase + "out" + iterations + ".png");
    //noLoop();
    iterations++;
    //image(out, 0, 0);
    drawing = false;
    //    selecting = true;
    iX = 0; 
    prevIY = iY;
    iY = 0; 
    fX = 0; 
    prevFY = fY;
    fY = 0;
  }
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
    out.clear();
    //println("(" + iX + ", " + iY + ") (" + fX + ", " + fY + ")");
  }
}

