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
  size(1560, 1540);
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

  InSiteData _dataIF = new InSiteData("inSite");
  _dataIF.loadData();
  Delv _delv = new DelvImpl(_dataIF);
  _dataIF.setDelvIF(_delv);

  _dropView.bindDelv(_delv);
  _dropView.dataIF("inSite");
  _regionView.bindDelv(_delv);
  _regionView.dataIF("inSite");
  _alignView.bindDelv(_delv);
  _alignView.dataIF("inSite");
  _barView.bindDelv(_delv);
  _barView.dataIF("inSite");
  _colorLegendView.bindDelv(_delv);
  _colorLegendView.dataIF("inSite");

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

  _dropView.datasetName("Regions");
  _dropView.cat1Attr("Species")
          .label("Species");

  _colorLegendView.datasetName("Regions");
  _colorLegendView.dataAttr("motif_type");

  _barView.datasetName("Regions");
  _barView.dim1Attr("strength");
  _barView.dim2Attr("motif_type");

  _colorLegendView.setup();
  _dropView.setup();
  _regionView.setup();
  _barView.setup();
  _alignView.setup();

  _dropView.connectSignals();
  _regionView.connectSignals();
  _alignView.connectSignals();
  _barView.connectSignals();
  _colorLegendView.connectSignals();

  _dropView.reloadData("Processing.pde");
  _regionView.reloadData("Processing.pde");
  _alignView.reloadData("Processing.pde");
  _barView.reloadData("Processing.pde");
  _colorLegendView.reloadData("Processing.pde");

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

class InSiteView extends DelvCompositeView {
  ColorLegendWithDropdownView _legendView;
  DropDownView _dropView;
  RegionView _regionView;
  BarHeightView _barView;
  AlignmentView _alignView;

  InSiteView() {
    this("InSite");
  }
  InSiteView(String name) {
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

  void reloadData(String source) {
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

    _dropView.datasetName("Regions");
    _dropView.cat1Attr("Species")
            .label("Species");

    _legendView.datasetName("Regions");
    _legendView.dataAttr("motif_type");

    _barView.datasetName("Regions");
    _barView.dim1Attr("strength");
    _barView.dim2Attr("motif_type");

    _regionView.reloadData(source);
    _dropView.reloadData(source);
    _legendView.reloadData(source);
    _barView.reloadData(source);
    _alignView.reloadData(source);

  }

  void resize(int w, int h) {
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
    view_h = 85;
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
  void draw(){
    super.draw();
    for (DelvBasicView view: _views) {
      view.draw();
    }
  }

  void render() {}

} // end class InSiteView


// for testInSite, use these versions of draw, mouseDragged, mouseMoved,...,mouseReleased
// // void draw() {
// //   noStroke();

// //   fill( BACKGROUND_COLOR );
// //   rect(0, 0, width, height);
// //   noFill();

// //   _dropView.draw();
// //   _regionView.draw();
// //   _alignView.draw();
// //   _barView.draw();
// //   _colorLegendView.draw();
// // }
// // void mouseDragged() {
// //   _dropView.mouseDragged();
// //   _regionView.mouseDragged();
// //   _alignView.mouseDragged();
// //   _barView.mouseDragged();
// //   _colorLegendView.mouseDragged();
// //   draw();
// // }
// // void mouseMoved() {
// //   _dropView.mouseMoved();
// //   _regionView.mouseMoved();
// //   _alignView.mouseMoved();
// //   _barView.mouseMoved();
// //   _colorLegendView.mouseMoved();
// //   draw();
// // }
// // void mouseClicked() {
// //   println("mouseClicked: " + mouseX + ", " + mouseY );
// //   _dropView.mouseClicked();
// //   _regionView.mouseClicked();
// //   _alignView.mouseClicked();
// //   _barView.mouseClicked();
// //   _colorLegendView.mouseClicked();
// //   draw();
// // }
// // void mousePressed() {
// //   _dropView.mousePressed();
// //   _regionView.mousePressed();
// //   _alignView.mousePressed();
// //   _barView.mousePressed();
// //   _colorLegendView.mousePressed();
// //   draw();
// // }
// // void mouseReleased() {
// //   _dropView.mouseReleased();
// //   _regionView.mouseReleased();
// //   _alignView.mouseReleased();
// //   _barView.mouseReleased();
// //   _colorLegendView.mouseReleased();
// //   draw();
// // }

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
  InSiteView insite_view = new InSiteView();
  _view = insite_view;
  InSiteData _dataIF = new InSiteData("inSite");
  _dataIF.loadData();
  DelvImpl _delv = new DelvImpl(_dataIF);
  _dataIF.setDelvIF(_delv);
  insite_view.bindDelv(_delv);
  insite_view.dataIF("inSite");
  insite_view.setup();
  insite_view.connectSignals();
  insite_view.reloadData("Processing.pde");
  insite_view.resize(1600, 1400);
}

void testRegion() {
  testRegion(100, 100, 1200, 200);
}
void testRegion(int x_origin, int y_origin,
                int w, int h) {
  RegionView view = new RegionView();
  _view = view;
  view.setOrigin(x_origin, y_origin);
  InSiteData _dataIF = new InSiteData("inSite");
  _dataIF.loadData();
  Delv _delv = new DelvImpl(_dataIF);
  _dataIF.setDelvIF(_delv);
  view.bindDelv(_delv);
  view.dataIF("inSite");
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

  view.reloadData("Processing.pde");
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
  InSiteData _dataIF = new InSiteData("inSite");
  _dataIF.loadData();
  Delv _delv = new DelvImpl(_dataIF);
  _dataIF.setDelvIF(_delv);
  view.bindDelv(_delv);
  view.dataIF("inSite");
  view.datasetName("Regions");
  view.cat1Attr("Species")
      .label("Species");
  view.setup();
  view.reloadData("Processing.pde");

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
  InSiteData _dataIF = new InSiteData("inSite");
  _dataIF.loadData();
  Delv _delv = new DelvImpl(_dataIF);
  _dataIF.setDelvIF(_delv);
  view.bindDelv(_delv);
  view.dataIF("inSite");
  view.datasetName("Regions");
  view.dataAttr("motif_type");
  view.setup();
  view.reloadData("Processing.pde");
  view.resize(200,300);
}
void testColorLegendWithDropdown() {
  testColorLegendWithDropdown(0, 0);
}
void testColorLegendWithDropdown(int x_origin, int y_origin) {
  ColorLegendWithDropdownView view = new ColorLegendWithDropdownView();
  _view = view;
  view.setOrigin(x_origin, y_origin);
  InSiteData _dataIF = new InSiteData("inSite");
  _dataIF.loadData();
  Delv _delv = new DelvImpl(_dataIF);
  _dataIF.setDelvIF(_delv);
  view.bindDelv(_delv);
  view.dataIF("inSite");
  view.datasetName("Regions");
  view.dataAttr("motif_type");
  view.label("motif");
  view.setup();
  view.reloadData("Processing.pde");
  view.resize(200,300);
}

