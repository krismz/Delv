function init() {
  console.log("entering init");
  dataLoaded = false;
  delv.doSignalDebounce(75);

  dataSet = new delv.csvData("iris", "test_data/iris.csv");
  dataSet.load_data(finishLoadingData);

  smView = new scatterSmallMultiples("SPLOM", "splom", "d3Views.scatterplot_view", "./scatterplot.js");
  smView.dataSet(dataSet.name());
  var attrs = ["sepal length", "sepal width", "petal length", "petal width"];
  smView.xAttr(attrs)
    .yAttr(attrs)
    .splitAttr("species")
    .colorAttr("species");
  delv.addView(smView);

  legend = new delv.d3Chart("legend", "legend", "./legend.js", "d3Views.legend_view",
                            function(view, elemId) {
                              view.dataSet(dataSet.name())
                                .title("Iris Species")
                                .catAttr("species");
                            });
}

function scatterSmallMultiples(name, elemId, constructor, source) {
  var view = new delv.d3SmallMultiples(name, elemId, constructor, source);

  // TODO find a better way than overriding here if possible
  view.configured = function() {
     return (this._datasetName !== "" &&
             (this._splitAttr.length > 0 ||
              (this._xAttr.length > 0 &&
               this._yAttr.length > 0)));
  };

  view.configureView = function(smallView, xidx, yidx) {
    if (xidx == yidx) {
      // diagonal
      smallView.title(this._xAttr[xidx]);
    } else {
      smallView.title("");
    }
    if (xidx == this._xAttr.length - 1) {
      // end, show axis
      smallView.showYAxis();
    } else {
      smallView.hideYAxis();
    }
    if (yidx == this._yAttr.length - 1) {
      // end, show axis
      smallView.showXAxis();
    } else {
      smallView.hideXAxis();
    }
  };
    
  view.dataDependentConfig = function(smallView) {
    var maxY;
    var minX;
    var maxX;
    maxY = delv.getMax(this._datasetName, this._yAttr);
    minX = delv.getMin(this._datasetName, this._xAttr);
    maxX = delv.getMax(this._datasetName, this._xAttr);
    //delv.navRange(this._name, this._datasetName, this._yAttr, "0", maxY);
    //delv.navVal(this._name, this._datasetName, this._xAttr, "2004", "2014");
    //smallView.maxY(maxY);
    // TODO undo this hard-coded, data-dependent hack
    // the problem is that xAttr is a categorical variable, so min/max are meaningless
    //smallView.extentX([minX, maxX]);
    //smallView.extentX([2004, 2014]);
  };
  
  return view;
}

function finishLoadingData() {
  console.log("finishLoadingData");
  dataLoaded = true;
  delv.colorCat("splom", "iris", "species", "virginica", "#008");
  delv.colorCat("splom", "iris", "species", "setosa", "#800");
  delv.colorCat("splom", "iris", "species", "versicolor", "#080");
  // todo anything dependent on data being loaded
  // alternatively, can just connect to the "dataChanged" signal
 }

