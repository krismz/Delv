

class Bspline {

  int _degree, _detail;
  float _tightness, _dt;
  ArrayList _cp_x, _cp_y;
  float[] _knots;

  Bspline() {   
    _degree = 3;
    _tightness = 1.0;
    _detail = 20;

    _dt = 1.0 / ((float)( _detail-1 ) + 1.0E-6);

    _cp_x = new ArrayList();
    _cp_y = new ArrayList();
  }

  void addCP( float x, float y ) {
    _cp_x.add( x );
    _cp_y.add( y );
  }

  void degree( int d ) {
    _degree = d;
  }

  void tightness( float t ) {
    _tightness = t;
  }

  void detail( int d ) {
    _detail = max( d+1, 1 );
    _dt = 1.0 / ((float)( _detail-1 )+1.0E-6);
  }

  void clearCP() {    
    _cp_x.clear();
    _cp_y.clear();
  }

  void render() {
    if ( _cp_x.size() <= _degree ) {
      //println( "Bspline Error: " + _cp_x.size() + " is not enough control points for a degree " + _degree + " bspline curve" );
      return;
    }

    createKnotVector();
    straightenControlPoints();

    noFill();
    beginShape();

    float[] pos = new float[2];
    int num_intervals = (_knots.length-1) - 2*_degree;
    int interval;
    for ( interval = 0; interval < num_intervals; interval++ ) {
      for ( float t = _knots[_degree+interval]; t < _knots[_degree+interval+1]; t += _dt ) {
        pos = evaluateCurve( t, _degree+interval );
        vertex( pos[0], pos[1] );
      }
    }

    vertex( (Float)_cp_x.get(_cp_x.size()-1), (Float)_cp_y.get(_cp_y.size()-1) );

    endShape();
  }

  void createKnotVector() {
    int num_middle = _cp_x.size() - (_degree+1);
    _knots = new float[_degree + _cp_x.size() + 1 ];

    for ( int i = 0; i <= _degree; i++ ) {
      _knots[i] = 0.0;
    }

    for ( int i = (_degree+1); i < (_degree+1+num_middle); i++ ) {
      _knots[i] = _knots[i-1]+1;
    }

    for ( int i = (_degree+1+num_middle); i <= (2*_degree+1+num_middle); i++ ) {
      _knots[i] = _knots[_degree+num_middle]+1;
    }
  }

  float[] evaluateCurve( float t, int i )
  {
    float px, py, alpha_x=0.0, alpha_y=0.0;
    float beta;
    float[] pos = new float[2];
    for ( int m = i-_degree; m <= i; m++ )
    {
      px = (Float)_cp_x.get(m);
      py = (Float)_cp_y.get(m);

      beta = computeBeta( t, m, _degree );

      alpha_x += px * beta;
      alpha_y += py * beta;
    } 

    pos[0] = alpha_x;
    pos[1] = alpha_y;

    return pos;
  }
  
  void straightenControlPoints() {
    if ( _tightness == 1.0 ) {
      return;
    }
    
    float p0x = (Float)_cp_x.get(0);
    float pNx = (Float)_cp_x.get(_cp_x.size()-1);
    float p0y = (Float)_cp_y.get(0);
    float pNy = (Float)_cp_y.get(_cp_y.size()-1);
    for ( int i = 1; i < _cp_x.size()-1; i++ ) {
      _cp_x.set(i, _tightness*(Float)_cp_x.get(i) + (1.0 - _tightness)*(p0x + float(i)/float(_cp_x.size()-1) * (pNx - p0x)));
      _cp_y.set(i, _tightness*(Float)_cp_y.get(i) + (1.0 - _tightness)*(p0y + float(i)/float(_cp_y.size()-1) * (pNy - p0y)));
    }
  }

  float computeBeta( float t, int i, int k ) {
    if ( k == 0 ) {
      if ( (t >= _knots[i]) && (t < _knots[i+1]) ) {
        return 1.0;
      }
      return 0.0;
    }

    if ( t >= _knots[i+1+k] ) {
      return 0.0;
    }

    float left, rite;
    float beta = computeBeta( t, i, k-1 );
    if ( beta != 0.0 )
      left = ((t-_knots[i])/(_knots[i+k]-_knots[i])) * beta;
    else
      left = 0.0;

    beta = computeBeta( t, i+1, k-1 );
    if ( beta != 0.0 )
      rite = ((_knots[i+1+k]-t)/(_knots[i+1+k]-_knots[i+1])) * 
        beta;
    else
      rite = 0.0;

    return (left + rite);
  }
}

Bspline _global_bspline = new Bspline();

// assumes a cubic bspline curve with 4 control points, interpolating
//  the first and last points
void bspline( float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4 ) {
  beginBspline();

  bsplineVertex( x1, y1 );
  bsplineVertex( x2, y2 );
  bsplineVertex( x3, y3 );
  bsplineVertex( x4, y4 );

  endBspline();
}

void beginBspline() {
  _global_bspline.clearCP();
}

void endBspline() {
  _global_bspline.render();
}

void bsplineVertex( float x, float y ) {
  _global_bspline.addCP( x, y );
}

void bsplineDegree( int d ) {
  _global_bspline.degree( d );
}

void bsplineDetail( int d ) {
  _global_bspline.detail( d );
}

void bsplineTightness( float t ) {
  _global_bspline.tightness( t );
}






