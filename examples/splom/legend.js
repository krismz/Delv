var d3Views = d3Views || {};

d3Views.legend_view = function(name, svgElemId) {
  var view = new delv.d3CatView(name, svgElemId);

  view.connectSignals = function() {
    this._delv.connectToSignal("hoverChanged", this._name, "onHoverChanged");
    // TODO find more elegant way to update colors
    this._delv.connectToSignal("colorChanged", this._name, "onDataChanged");
  };

  view.hoverChanged = function(cat) {
    this._delv.hoverCat(this._name, this._datasetName, this._catAttr, cat);
  };

  view.onHoverChanged = function(signal, invoker, dataset, coordination, detail) {
    var cat;
    if (invoker !== this._name) {
      if (dataset === this._datasetName) {
        // ignore if sent by self
        cat = this._delv.getHoverCat(this._datasetName, this._catAttr);
        hoverCat(cat);
      }
    }
  };

  view.onDataChanged = function(signal, invoker, dataset) {
    var data;
    if ((dataset === this._datasetName) && this.configured()) {
      data = this.convertToArrayOfObjects();
      if (data.length > 0) {
        bindData(data);
      }
    }
  };

  var svgElem;
  function createSvgElem() {
    if (svgElemId) {
      svgElem = d3.select("#"+svgElemId);
    } else {
      svgElem = d3.select("body").append("svg");
    }
  }
  createSvgElem();

  function bindData(data) {
    var legend;
    var title;
    var padding = 5;
    svgElem.selectAll("g").remove();

    title = svgElem.selectAll("g.title")
      .data(data)
      .enter().append("g")
      .attr("class", "title")
      .attr("transform", function (d) { return "translate(0, 5)"; })
      .append("svg:text")
      .attr("x", 0)
      .attr("dy", ".62em")
      .text(function(d) { return d.key; });
    
    legend = svgElem.selectAll("g.legend")
      .data(data[0].values)
      .enter().append("g")
      .attr("class", "legend")
      .attr("transform", function(d, i) { return "translate("+padding+"," + (padding+(i+1)*(padding+20)) + ")"; });

    legend.append("circle")
      .attr("r", 3)
      .attr("fill", function(d) { return d.color; });

    legend.append("svg:text")
      .attr("x", 12)
      .attr("dy", ".31em")
      .text(function(d) { return d.cat; });
  }

  return view;
};
