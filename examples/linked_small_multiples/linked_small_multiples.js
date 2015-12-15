function init() {
  console.log("entering init");
  dataLoaded = false;

  dataSet = new delv.tsvData("askmefi", "test_data/askmefi_category_year.tsv");
  dataSet.load_data(finishLoadingData);

  smView = new areaSmallMultiples("areaSM", "vis", "d3Views.area_chart_view", "./area_chart.js");
  smView.dataSet(dataSet.name());
  smView.xAttr("year")
    .yAttr("n")
    .splitAttr("category");
  delv.addView(smView);

}

function areaSmallMultiples(name, elemId, constructor, source) {
  var view = new delv.d3SmallMultiples(name, elemId, constructor, source);

  view.configured = function() {
     return (this._datasetName !== "" &&
             (this._splitAttr.length > 0 &&
              (this._xAttr.length > 0 &&
               this._yAttr.length > 0)));
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
  
  view.afterDataUpdated = function() {
    this.setupIsotope();
    this.sortBy("count");
  };
  
  view.setupIsotope = function() {
    $("#" + this._elemId).isotope({
      itemSelector: '.d3Chart',
      layoutMode: 'fitRows',
      getSortData: {
        count: function(e) {
          var d, g, sum;
          g = d3.select(e).select("g");
          if (!g.empty()) {
            d = g.datum();
            if (typeof(d) !== "undefined") {
              sum = d3.sum(d.values, function(d) {
                return +d.yVal;
              });
              return sum * -1;
            } else {
              return 0;
            }
          } else {
            return 0;
          }
        },
        name: function(e) {
          var d, g;
          g = d3.select(e).select("g");
          if (!g.empty()) {
            d = g.datum();
            return typeof(d) !== "undefined" ? d.key : "";
          } else {
            return "";
          }
        }
      }
    });
  };
  
  view.sortBy = function(id) {
    $("#"+this._elemId).isotope({
      sortBy: id
    });
  };
  
  return view;
}

function finishLoadingData() {
  console.log("finishLoadingData");
  dataLoaded = true;
  // todo anything dependent on data being loaded
  // alternatively, can just connect to the "dataChanged" signal
 }

d3.select("#button-wrap").selectAll("div").on("click", function() {
  var id;
  id = d3.select(this).attr("id");
  d3.select("#button-wrap").selectAll("div").classed("active", false);
  d3.select("#" + id).classed("active", true);
  smView.sortBy(id);
});

