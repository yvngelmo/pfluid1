float[][] cellVelX = new float[50][50];
float[][] cellVelY = new float[50][50];
float[][] cellVelXNext = new float[50][50];
float[][] cellVelYNext = new float[50][50];

float[][] cellDens = new float[50][50];
float[][] cellDensNext = new float[50][50];

int lineSegmentPosX,lineSegmentPosY;
float sumNeighborX, sumNeighborY;
int fluidSourceX, fluidSourceY;

float fluidDecay = 0.99;

void setup()                          
{
  size(500,500);
  pixelDensity(1);
  noStroke();
  noSmooth();

  densInit();
}
void draw()
{
  scale(10);
  
  mouse2Vel();

  velClearNext();
  velDiffusion();
  velNext2Vel();
  
  velClearNext();
  velAdvection();
  velNext2Vel();
  
  velClearNext();
  velDecay();
  velNext2Vel();
  
  densClearNext();
  densAdvection();
  densNext2Dens();
  
  if(key=='1')
  {
  drawVel();
  }
  if(key=='2')
  {
  drawDens();
  }
}

void densInit()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
      cellDens[w][h]=random(100,200);
    }
  }
}

void mouse2Vel()
{
  for (int i = 0; i<=dist(pmouseX,pmouseY,mouseX,mouseY); i++)
  {
    //ersten frame skippen
    if (pmouseX == 0 && pmouseY == 0) 
    {
      return;
    }
    //loopen für jeden punkt zwischen pmouse & mouse
    lineSegmentPosX= round(lerp(pmouseX, mouseX, i/dist(mouseX,mouseY,pmouseX,pmouseY)))/10;
    lineSegmentPosY= round(lerp(pmouseY, mouseY, i/dist(mouseX,mouseY,pmouseX,pmouseY)))/10;
    
    //einsetzen
    cellVelX[lineSegmentPosX][lineSegmentPosY] = cellVelX[lineSegmentPosX][lineSegmentPosY]+(mouseX - pmouseX)*0.1;
    cellVelY[lineSegmentPosX][lineSegmentPosY] = cellVelY[lineSegmentPosX][lineSegmentPosY]+(mouseY - pmouseY)*0.1;
    
    //gerundete werte printen auf debug digga
    println("velXY: "+round(cellVelX[mouseX/10][mouseY/10])+","+round(cellVelY[mouseX/10][mouseY/10]));
  }
}

void velNext2Vel()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
      cellVelX[w][h]=cellVelXNext[w][h];
      cellVelY[w][h]=cellVelYNext[w][h];
    }
  }
}

void densNext2Dens()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
      cellDens[w][h]=cellDensNext[w][h];
    }
  }
}

void velClearNext()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
      cellVelXNext[w][h]=0;
      cellVelYNext[w][h]=0;
    }
  }
}

void densClearNext()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
      cellDensNext[w][h]=0;
    }
  }
}

void velDiffusion()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
        //über 3x3 loopen für jede cell
        sumNeighborX=0;
        sumNeighborY=0;
        for (int ch=h-1;ch<h+2;ch++)
        {
          for (int cw=w-1;cw<w+2;cw++)
          {
            //alle values im 3x3 addieren
            sumNeighborX=(sumNeighborX+cellVelX[constrain(cw,0,49)][constrain(ch,0,49)]);
            sumNeighborY=(sumNeighborY+cellVelY[constrain(cw,0,49)][constrain(ch,0,49)]);
          }
        }
        
        //diffusion, weight auf ursprungsvalue für erhaltung
        cellVelXNext[w][h]=(0.5*cellVelX[w][h]+0.5*sumNeighborX/9);
        cellVelYNext[w][h]=(0.5*cellVelY[w][h]+0.5*sumNeighborY/9);
    }
  }
}

void velAdvection()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
        //wo kommt der fluid her?
        fluidSourceX= constrain(round((w-cellVelX[w][h])),0,49);
        fluidSourceY= constrain(round((h-cellVelY[w][h])),0,49);

        //advection (geh dahin zurück wo du hergekommen bist)
        cellVelXNext[w][h]=cellVelX[fluidSourceX][fluidSourceY];
        cellVelYNext[w][h]=cellVelY[fluidSourceX][fluidSourceY];
    }
  }
}

void densAdvection()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
        //wo kommt der fluid her?
        fluidSourceX= constrain(round((w-cellVelX[w][h])),0,49);
        fluidSourceY= constrain(round((h-cellVelY[w][h])),0,49);

        //advection (geh dahin zurück wo du hergekommen bist)
        cellDensNext[w][h]=cellDens[fluidSourceX][fluidSourceY];
    }
  }
}

void velDecay()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
        cellVelXNext[w][h]=cellVelX[w][h]*fluidDecay;
        cellVelYNext[w][h]=cellVelY[w][h]*fluidDecay;
    }
  }
}

void drawVel()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
      fill(cellVelX[w][h]*10+127.5,cellVelY[w][h]*10+127.5,255);
      rect(w,h,1,1);
    }
  }
}

void drawDens()
{
  for (int h=0;h<50;h++)
  {
    for (int w=0;w<50;w++)
    {
      fill(cellDens[w][h]);
      rect(w,h,1,1);
    }
  }
}
