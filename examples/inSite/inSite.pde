// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

String name;
ColorLegendWithDropdownView _colorLegendView;
DropDownView _dropView;
RegionView _regionView;
BarHeightView _barView;
AlignmentView _alignView;

void setup() {
  //size(1400, 800,P3D);
  size(1400, 800);
  frameRate(10);
  //testRegion();
  //testDropDown();
  //testColorPickerLegend(50,50);
  //testColorLegendWithDropdown(50,50);
  testInsiteView(); // preferred way to create a full application
  //testInsite(); // switch versions of draw(), mouseMoved(), etc below to run this test
}

void testInsite() {
  name="InSite";
  _colorLegendView = new ColorLegendWithDropdownView(name+"Legend");
  _dropView = new DropDownView(name+"DropDown");
  _regionView = new RegionView(name+"Region");
  _barView = new BarHeightView(name+"BarHeight");
  _alignView = new AlignmentView(name+"Alignment");

  InSiteDataSet _dataIF = new InSiteDataSet("inSite");
  _dataIF.loadData();
  Delv _delv = new DelvImpl();
  _delv.addDataSet("inSite", _dataIF);
  _delv.addView(_dropView);
  _delv.addView(_regionView);
  _delv.addView(_alignView);
  _delv.addView(_barView);
  _delv.addView(_colorLegendView);

  RegionDataset aboveDataset = _regionView.createDataset("Regions");
  aboveDataset.regionTypeAttr("Species")
              .regionLengthAttr("totalLength")
              .barStartAttr("start")
              .barLengthAttr("length")
              .barTypeAttr("motif_type")
              .barHeightAttr("strength")
              .units("bp");
  _regionView.addDataset(aboveDataset, false);

  RegionDataset belowDataset = _regionView.createDataset("Annotations");
  belowDataset.regionTypeAttr("Species")
              .regionLengthAttr("totalLength")
              .barStartAttr("start")
              .barLengthAttr("length")
              .barTagAttr("description")
              .defaultBarType("Annotations");
  _regionView.addDataset(belowDataset, true);

  _dropView.dataSet("Regions");
  _dropView.catAttr("Species")
          .label("Species");

  _colorLegendView.dataSet("Regions");
  _colorLegendView.dataAttr("motif_type");

  _barView.dataSet("Regions");
  _barView.dim1Attr("strength");
  _barView.dim2Attr("motif_type");

  _colorLegendView.setup();
  _dropView.setup();
  _regionView.setup();
  _barView.setup();
  _alignView.setup();

  _dropView.onDataChanged("inSite.pde", "Regions");
  _regionView.onDataChanged("inSite.pde", "Regions");
  _alignView.onDataChanged("inSite.pde", "Regions");
  _barView.onDataChanged("inSite.pde", "Regions");
  _colorLegendView.onDataChanged("inSite.pde", "Regions");

  int w = width;
  int h = height;
  float border = 0.025;
  float x = border * w;
  float y = border * h;
  float view_w = 0.08 * w;
  float view_h = 0.95 * h;
  _dropView.setOrigin(int(x), int(y));
  _dropView.resize(int(view_w), int(view_h));

  x += view_w;
  view_w = 0.75 * w;
  _regionView.setOrigin(int(x), int(y));
  _regionView.resize(int(view_w), int(view_h));

  x += view_w;
  view_w = 0.12 * w;
  view_h = 45;
  _alignView.setOrigin(int(x), int(y));
  _alignView.resize(int(view_w), int(view_h));

  y += view_h;
  view_h = 85;
  _barView.setOrigin(int(x), int(y));
  _barView.resize(int(view_w), int(view_h));

  y += view_h;
  view_h = h - 2 * border * h - 45 - 85;
  view_h = max(view_h, 65);
  _colorLegendView.setOrigin(int(x), int(y));
  _colorLegendView.resize(int(view_w), int(view_h));

  draw();
}

public class InSiteView extends DelvCompositeView {
  ColorLegendWithDropdownView _legendView;
  DropDownView _dropView;
  RegionView _regionView;
  BarHeightView _barView;
  AlignmentView _alignView;

  public InSiteView() {
    this("InSite");
  }
  public InSiteView(String name) {
    super(name);
    _legendView = new ColorLegendWithDropdownView(name+"Legend");
    _dropView = new DropDownView(name+"DropDown");
    _regionView = new RegionView(name+"Region");
    _barView = new BarHeightView(name+"BarHeight");
    _alignView = new AlignmentView(name+"Alignment");
    addView(_legendView);
    addView(_dropView);
    addView(_regionView);
    addView(_barView);
    addView(_alignView);
  }

  public void onDataChanged(String invoker, String dataset) {
    RegionDataset aboveDataset = _regionView.createDataset("Regions");
    aboveDataset.regionTypeAttr("Species")
                .regionLengthAttr("totalLength")
                .barStartAttr("start")
                .barLengthAttr("length")
                .barTypeAttr("motif_type")
                .barHeightAttr("strength")
                .units("bp");
    _regionView.addDataset(aboveDataset, false);

    RegionDataset belowDataset = _regionView.createDataset("Annotations");
    belowDataset.regionTypeAttr("Species")
                .regionLengthAttr("totalLength")
                .barStartAttr("start")
                .barLengthAttr("length")
                .barTagAttr("description")
                .defaultBarType("Annotations");
    _regionView.addDataset(belowDataset, true);

    _dropView.dataSet("Regions");
    _dropView.catAttr("Species")
            .label("Species");

    _legendView.dataSet("Regions");
    _legendView.dataAttr("motif_type");
    _legendView.label("TF");

    _barView.dataSet("Regions");
    _barView.dim1Attr("strength");
    _barView.dim2Attr("motif_type");

    _regionView.onDataChanged(invoker, "Regions");
    _dropView.onDataChanged(invoker, "Regions");
    _legendView.onDataChanged(invoker, "Regions");
    _barView.onDataChanged(invoker, "Regions");
    _alignView.onDataChanged(invoker, "Regions");

  }

  public void resize(int w, int h) {
    super.resize(w, h);
    float border = 0.025;
    float x = border * w;
    float y = border * h;
    float view_w = 0.08 * w;
    float view_h = 0.95 * h;
    println("Setting dropdown origin to " + int(x) + ", " + int(y));
    println("Resizing dropdown to " + int(view_w) + ", " + int(view_h));
    _dropView.setOrigin(int(x), int(y));
    _dropView.resize(int(view_w), int(view_h));

    x += view_w;
    view_w = 0.75 * w;
    println("Setting region origin to " + int(x) + ", " + int(y));
    println("Resizing region to " + int(view_w) + ", " + int(view_h));
    _regionView.setOrigin(int(x), int(y));
    _regionView.resize(int(view_w), int(view_h));

    x += view_w;
    view_w = 0.12 * w;
    view_h = 45;
    println("Setting align origin to " + int(x) + ", " + int(y));
    println("Resizing align to " + int(view_w) + ", " + int(view_h));
    _alignView.setOrigin(int(x), int(y));
    _alignView.resize(int(view_w), int(view_h));

    y += view_h;
    view_h = 105;
    println("Setting bar origin to " + int(x) + ", " + int(y));
    println("Resizing bar to " + int(view_w) + ", " + int(view_h));
    _barView.setOrigin(int(x), int(y));
    _barView.resize(int(view_w), int(view_h));

    y += view_h;
    view_h = h - 2 * border * h - 45 - 85;
    view_h = max(view_h, 65);
    println("Setting legend origin to " + int(x) + ", " + int(y));
    println("Resizing legend to " + int(view_w) + ", " + int(view_h));
    _legendView.setOrigin(int(x), int(y));
    _legendView.resize(int(view_w), int(view_h));

    draw();
  }

  // TODO document difference between composite views where each view is drawn in an independent portion of screen
  // and composite views where the views overlap (and thus have to be careful about calling background())
  public void draw(){
    super.draw();
    for (DelvBasicView view: _views) {
      view.draw();
    }
  }

} // end class InSiteView


// for testInSite, use these versions of draw, mouseDragged, mouseMoved,...,mouseReleased
// void draw() {
//   noStroke();

//   fill( BACKGROUND_COLOR );
//   rect(0, 0, width, height);
//   noFill();

//   _dropView.draw();
//   _regionView.draw();
//   _alignView.draw();
//   _barView.draw();
//   _colorLegendView.draw();
// }
// void mouseDragged() {
//   _dropView.mouseDragged();
//   _regionView.mouseDragged();
//   _alignView.mouseDragged();
//   _barView.mouseDragged();
//   _colorLegendView.mouseDragged();
//   draw();
// }
// void mouseMoved() {
//   _dropView.mouseMoved();
//   _regionView.mouseMoved();
//   _alignView.mouseMoved();
//   _barView.mouseMoved();
//   _colorLegendView.mouseMoved();
//   draw();
// }
// void mouseClicked() {
//   println("mouseClicked: " + mouseX + ", " + mouseY );
//   _dropView.mouseClicked();
//   _regionView.mouseClicked();
//   _alignView.mouseClicked();
//   _barView.mouseClicked();
//   _colorLegendView.mouseClicked();
//   draw();
// }
// void mousePressed() {
//   _dropView.mousePressed();
//   _regionView.mousePressed();
//   _alignView.mousePressed();
//   _barView.mousePressed();
//   _colorLegendView.mousePressed();
//   draw();
// }
// void mouseReleased() {
//   _dropView.mouseReleased();
//   _regionView.mouseReleased();
//   _alignView.mouseReleased();
//   _barView.mouseReleased();
//   _colorLegendView.mouseReleased();
//   draw();
// }

// for all other tests, use these versions of draw, mouseClicked, etc
void redraw() {
  _view.draw();
}
 void draw() {
   _view.draw();
 }
 void mouseDragged() {
   _view.mouseDragged();
//   draw();
 }
 void mouseMoved() {
   _view.mouseMoved();
//   draw();
 }
 void mouseClicked() {
   println("mouseClicked: " + mouseX + ", " + mouseY );
   _view.mouseClicked();
//   draw();
 }
 void mousePressed() {
   _view.mousePressed();
   //  draw();
 }
 void mouseReleased() {
   _view.mouseReleased();
   //  draw();
 }

void testInsiteView() {
  InSiteView insite_view = new InSiteView("TestInsiteView");
  _view = insite_view;
  InSiteDataSet _dataIF = new InSiteDataSet("inSite");
  _dataIF.loadData();
  DelvImpl _delv = new DelvImpl();
  _delv.addDataSet("inSite", _dataIF);
  _delv.addView(insite_view);
  insite_view.setup();
  insite_view.onDataChanged("inSite.pde", "inSite");
  insite_view.resize(1400, 800);
}

void testRegion() {
  testRegion(100, 100, 1200, 200);
}
void testRegion(int x_origin, int y_origin,
                int w, int h) {
  RegionView view = new RegionView();
  _view = view;
  view.setOrigin(x_origin, y_origin);
  InSiteDataSet _dataIF = new InSiteDataSet("inSite");
  _dataIF.loadData();
  Delv _delv = new DelvImpl();
  _delv.addDataSet("inSite", _dataIF);
  view.bindDelv(_delv);
  view.setup();
  RegionDataset aboveDataset = view.createDataset("Regions");
  aboveDataset.regionTypeAttr("Species")
    .regionLengthAttr("totalLength")
    .barStartAttr("start")
    .barLengthAttr("length")
    .barTypeAttr("motif_type")
    .barHeightAttr("strength")
    .units("bp");
  view.addDataset(aboveDataset, false);

  RegionDataset belowDataset = view.createDataset("Annotations");
  belowDataset.regionTypeAttr("Species")
    .regionLengthAttr("totalLength")
    .barStartAttr("start")
    .barLengthAttr("length")
    .barTagAttr("description")
    .defaultBarType("Annotations");
  view.addDataset(belowDataset, true);

  view.onDataChanged("inSite.pde", "Regions");
  // to capture the size of the monitor
  int _w = 1400;
  int _h = 700;
  // Processing 1.5.1
//   _w = screen.width;
//   _h = screen.height-40;
  // Processing 2.0+
//   _w = displayWidth;
//   _h = displayHeight-40;

  // but lets just hardcode this for now
  _w = min( _w, 1200);
  _h = min( _h, 200);
  // min width and height
  int _min_w = 350;
  int _min_h = 400;
  _w = max( _w, _min_w );
  _h = max( _h, _min_h );

  view.resize(_w, _h);
}

void testDropDown() {
  testDropDown(100, 100, 128, 40);
}
void testDropDown(int x_origin, int y_origin,
                int w, int h) {
  DropDownView view = new DropDownView();
  _view = view;
  ((DelvBasicView)_view).setOrigin(x_origin, y_origin);
  view.setBackgroundColor(205);
  InSiteDataSet _dataIF = new InSiteDataSet("inSite");
  _dataIF.loadData();
  Delv _delv = new DelvImpl();
  _delv.addDataSet("inSite", _dataIF);
  _delv.addView(view);
  view.dataSet("Regions");
  view.catAttr("Species")
      .label("Species");
  view.setup();
  view.onDataChanged("inSite.pde", "Regions");

  //view.resize(w, h);
  //view.onCategoryVisibilityChanged("someone", "Regions", "Species");
}

void testColorPickerLegend() {
  testColorPickerLegend(0, 0);
}
void testColorPickerLegend(int x_origin, int y_origin) {
  ColorPickerLegendView view = new ColorPickerLegendView();
  _view = view;
  view.setOrigin(x_origin, y_origin);
  InSiteDataSet _dataIF = new InSiteDataSet("inSite");
  _dataIF.loadData();
  Delv _delv = new DelvImpl();
  _delv.addDataSet("inSite", _dataIF);
  _delv.addView(view);
  view.dataSet("Regions");
  view.dataAttr("motif_type");
  view.setup();
  view.onDataChanged("inSite.pde", "Regions");
  view.resize(200,300);
}
void testColorLegendWithDropdown() {
  testColorLegendWithDropdown(0, 0);
}
void testColorLegendWithDropdown(int x_origin, int y_origin) {
  ColorLegendWithDropdownView view = new ColorLegendWithDropdownView();
  _view = view;
  view.setOrigin(x_origin, y_origin);
  InSiteDataSet _dataIF = new InSiteDataSet("inSite");
  _dataIF.loadData();
  Delv _delv = new DelvImpl();
  _delv.addDataSet("inSite", _dataIF);
  _delv.addView(view);
  view.dataSet("Regions");
  view.dataAttr("motif_type");
  view.label("motif");
  view.setup();
  view.onDataChanged("inSite.pde", "Regions");
  view.resize(200,300);
}

