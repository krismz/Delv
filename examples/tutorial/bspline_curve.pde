ArrayList control_points = new ArrayList();
boolean point_rolled_over;
int rolled_over_point;

void setup()
{
  size( 400, 400 );

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

      control_points.add(pt);

      println(pt[0] + "  " + pt[1]);
    }
  }
}


void draw()
{
  background( color(255) );
  smooth();

  // draw the control points
  

  int[] pt = new int[2];
  int[] previous_pt = new int[2];
  if ( control_points.size() != 0 )
  {
    if ( point_rolled_over && rolled_over_point==0)
    {
      stroke( color(100) );
      fill( color(100) );
      strokeWeight( 3 );
    }
    else
    {
      stroke( color(200) );
      fill( color(200) );
      strokeWeight( 1 );
    }

    pt = (int[])control_points.get(0);
    ellipse( pt[0], pt[1], 4, 4 );
  }

  for ( int i = 1; i < control_points.size(); i++ )
  {
    if ( point_rolled_over && rolled_over_point==i)
    {
      stroke( color(100) );
      fill( color(100) );
      strokeWeight( 3 );
    }
    else
    {
      stroke( color(200) );
      fill( color(200) );
      strokeWeight( 1 );
    }
    pt = (int[])control_points.get(i);
    ellipse( pt[0], pt[1], 4, 4 );

    stroke( color(200) );
    fill( color(200) );
    strokeWeight( 1 );
    previous_pt = (int[])control_points.get(i-1);
    line( previous_pt[0], previous_pt[1], pt[0], pt[1] );
  }

  // draw the bspline curve
  stroke( color(55, 126, 184) );
  bsplineDegree( 2 ); // change the degree of the curve
  bsplineTightness( 1.0 ); // change the tightness of the control mesh ( [0.0, 1.0] )
  beginBspline();
  for ( int i = 0; i < control_points.size(); i++ )
  {
    pt = (int[])control_points.get(i);
    bsplineVertex( pt[0], pt[1] );
  }
  endBspline();
}

void keyPressed()
{
  if (key == 's')
  {
    save("bspline_curve.png");
  }
}


void mousePressed()
{
  if ( keyPressed && (keyCode == CONTROL) )
  {
    int[] pt = new int[2];
    pt[0] = mouseX;
    pt[1] = mouseY;

    control_points.add(pt);
  }
}

void mouseMoved()
{
  int[] pt = new int[2];
  int delta = 4;
  
  point_rolled_over = false;
  
  for ( int i = 0; i < control_points.size(); i++ )
  {
    pt = (int[])control_points.get(i);
    if ( (mouseX >= pt[0]-delta) && (mouseX <= pt[0]+delta) &&
      (mouseY >= pt[1]-delta) && (mouseY <= pt[1]+delta) )
    {
      point_rolled_over = true;
      rolled_over_point = i;
      return;
    }
  }
}

