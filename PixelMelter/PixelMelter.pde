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
int maxIters = 1;

int prevFY = 0;
int prevIY = 0;
String srcBase = "Frelephs";

boolean colorDisp = false;
int colorDispOdds = 30;
int colorDelta = 50;
int rRandy = 0;
int gRandy = 0;
int bRandy = 0;

boolean distDisp = true;
int distDispOdds = 70;
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

  int time = millis();

  while (drawing && (iY + fY) != 0)
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
    float divisions = ((meltedRegion-(t)) /(b-t));

    //THIS IS HARD CODED AND UGLY ^^^

    int currentRegion = t;
    out.beginDraw();
    pure.beginDraw();
    color[] c = new color[src.width];
    int row = 0;
    int index = 0;
    int yPlace = 0;

    int melteds = 0;

    while (row < src.height && yPlace < height)
    {
      //      println("Still running, will change pixel  "+ yPlace + " and " + row + " < " + src.height + " and (" + t + " < " + row + " < " + b + ")");
      //      println("yPlace: " + yPlace + " < " + height);
      //      println("yPlace: " + yPlace + ", currentRegion: " + currentRegion + ", " + row);
      if (row < t || row >= b) 
      {
        rRandy = 0;
        gRandy = 0;
        bRandy = 0;

        while (index < src.width)
        {
          c[index] = src.pixels[index+(row*src.width)];
          index++;
        }
        row++;
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

        if (colorDisp && (random(100) < colorDispOdds))
        {
          generateColorDisplacement();
        }
      }

      index = 0;
      int distRandy = 0;
      float chance = random(100);

      if (distDisp)
      {
        if (chance < distDispOdds)
        {
          distRandy = floor(-1*random(cos(yPlace/period)*random(threshold), cos(yPlace/period)*random(threshold)));
        }
      }
      if (colorDisp && (row < t || row >= b))
      {
        if (chance < (colorDispOdds)/2)
        {
          generateColorDisplacement();
        }
      } 

      while (index < src.width)
      {

        //PURE VERSION:
        color displacedColor = color(red(c[index])+rRandy, green(c[index])+gRandy, blue(c[index])+bRandy);

        if (row > t && row < b)
        {
          out.set(index+distRandy, yPlace, displacedColor);
        } else
        {
          out.set(index, yPlace, displacedColor);
        }

        pure.set(index, yPlace, displacedColor);

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
    if (iterations < maxIters)
    {
      iY = prevIY;
      fY = prevFY;
      selecting = false;
      drawing = true;
      println("Iteration " + iterations);
    } else
    {
      println("Time taken: " + (millis() - time)/1000.0 + " seconds");
    }
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

void keyPressed()
{
  iY = prevIY;
  fY = prevFY;
  selecting = false;
  drawing = true;
}

void generateColorDisplacement()
{
  if (random(100) < colorDispOdds)
  {
    rRandy = floor(random(-1*colorDelta, colorDelta));
  } else if (random(100) < colorDispOdds)
  {
    gRandy = floor(random(-1*colorDelta, colorDelta));
  } else if (random(100) < colorDispOdds)
  {
    bRandy = floor(random(-1*colorDelta, colorDelta));
  }
}

