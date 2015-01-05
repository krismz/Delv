class ScatterplotView extends Delv2DView {
ArrayList points = new ArrayList();
int offset = 20;
int w, h;
boolean point_rolled_over;
int rolled_over_point;

void setup()
{
  w = 400;
  h = 400;
  size( w, h );
  
  point_rolled_over = false;
  rolled_over_point = 0;

  readPoints("points.txt");
}

void readPoints(String filename)
{
  String[] rows = loadStrings( filename );

  int counter = 0;
  String[] cols;
  int[] pt;

  while ( counter < rows.length )
  {
    cols = splitTokens( rows[counter++] ); 

    if ( cols.length == 0 )
      continue;

    else if (cols.length == 2 )
    {
      pt = new int[2];
      pt[0] = parseInt(cols[0]);
      pt[1] = parseInt(cols[1]);

      points.add(pt);

      println(pt[0] + "  " + pt[1]);
    }
  }
}


void draw()
{
  background( color(255) );
  smooth();

  pushMatrix();
  translate( offset, offset );

  // draw the axes
  stroke( color(200) );
  strokeWeight( 1 );
  line( 0, 0, w-2*offset, 0 );
  line( 0, 0, 0, h-2*offset );

  // draw the control points
  

  int[] pt = new int[2];
  int[] previous_pt = new int[2];

  for ( int i = 0; i < points.size(); i++ )
  {
    if ( point_rolled_over && rolled_over_point==i)
    {
      stroke( color(180, 10, 10) );
      fill( color(180, 10, 10) );
      strokeWeight( 3 );
    }
    else
    {
      stroke( color(100) );
      fill( color(100) );
      strokeWeight( 1 );
    }
    
    pt = (int[])points.get(i);
    ellipse( pt[0], pt[1], 4, 4 );
  }

  popMatrix();
}

void mousePressed()
{
  if ( keyPressed && (keyCode == CONTROL) )
  {
    if ( (mouseX >= offset) && (mouseX <= w-offset) && (mouseY >= offset) && (mouseY <=h-offset) )
    {
      int[] pt = new int[2];
      pt[0] = mouseX-offset;
      pt[1] = mouseY-offset;

      points.add(pt);
    }
  }
}

void keyPressed()
{
  if (key == 's')
  {
    save("scatterplot.png");
  }
}

void mouseMoved()
{
  int[] pt = new int[2];
  int delta = 4;
  
  point_rolled_over = false;
  
  for ( int i = 0; i < points.size(); i++ )
  {
    pt = (int[])points.get(i);
    if ( (mouseX-offset >= pt[0]-delta) && (mouseX-offset <= pt[0]+delta) &&
      (mouseY-offset >= pt[1]-delta) && (mouseY-offset <= pt[1]+delta) )
    {
      point_rolled_over = true;
      rolled_over_point = i;
      return;
    }
  }
}
}

