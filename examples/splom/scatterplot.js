var d3Views = d3Views || {};

d3Views.scatterplot_view = function(name, svgElemId) {
  var view = new delv.d3XYView(name, svgElemId);
  view._hoverX = [];
  view._hoverY = [];
  view._selectX = [];
  view._selectY = [];
  view._minX = 0;
  view._maxX = 0;
  view._minY = 0;
  view._maxY = 0;
  view._showXAxis = true;
  view._showYAxis = true;
  view._selectById = true;

  view.showXAxis = function() {
    view._showXAxis = true;
  };
  view.hideXAxis = function() {
    view._showXAxis = false;
  };
  view.showYAxis = function() {
    view._showYAxis = true;
  };
  view.hideYAxis = function() {
    view._showYAxis = false;
  };

  view.selectById = function() {
    view._selectById = true;
  }

  view.selectByRange = function() {
    view._selectById = false;
  }
  
  view.connectSignals = function() {
    this._delv.connectToSignal("hoverChanged", this._name, "onHoverChanged");
    this._delv.connectToSignal("selectChanged", this._name, "onSelectChanged");
  };

  view.hoverChanged = function( xRange, yRange ) {
    this._delv.hoverRange(this._name, this._datasetName, this._xAttr, xRange[0], xRange[1]);
    this._delv.hoverRange(this._name, this._datasetName, this._yAttr, yRange[0], yRange[1]);
  };

  view.onHoverChanged = function(signal, invoker, dataset, coordination, detail) {
    var xh;
    var yh;
    if (invoker !== this._name) {
      if (dataset === this._datasetName) {
        // ignore if sent by self
        xh = this._delv.getHoverRange(this._datasetName, this._xAttr);
        yh = this._delv.getHoverRange(this._datasetName, this._yAttr);
        hoverRange(xh, yh);
      }
    }
  };
  
  view.selectChanged = function( xRange, yRange ) {
    var attrs = [];
    var mins = [];
    var maxes = [];
    if (xRange.length > 0) {
      attrs[0] = this._xAttr;
      mins[0] = xRange[0];
      maxes[0] = xRange[1];
    }
    if (yRange.length > 0) {
      attrs[attrs.length] = this._yAttr;
      mins[mins.length] = yRange[0];
      maxes[maxes.length] = yRange[1];
    }
    this._delv.selectRanges(this._name, this._datasetName,
                            attrs, mins, maxes,
                            "PRIMARY");
  };

  view.onSelectChanged = function(signal, invoker, dataset, coordination, detail) {
    var ids;
    var xrange;
    var yrange;
    if (invoker !== this._name) {
      if (dataset === this._datasetName &&
         detail === "PRIMARY") {
        // ignore if sent by self
        clearBrush();
        if (this._selectById) {
          ids = this._delv.getSelectIds(this._datasetName, "PRIMARY");
          delv.log(this._name + " getting select ids: " + ids + " from dataset: " + this._datasetName + " sent by " + invoker);
          selectItems(ids);
        } else {
          xrange = this._delv.getSelectRanges(this._datasetName, this._xAttr, "PRIMARY");
          yrange = this._delv.getSelectRanges(this._datasetName, this._yAttr, "PRIMARY");
          delv.log(this._name + " getting select ranges: " + xrange + ", " + yrange + " sent by " + invoker);
          selectRanges(xrange.length > 0 ? xrange[0] : xrange, yrange.length > 0 ? yrange[0] : yrange);
        }
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

  view.minX = function(x) {
    // TODO move up to parent class
    if (x !== undefined) {
      this._minX = x;
      return this;
    } else {
      return this._minX;
    }
    //return this._delv.getMin(this._datasetName, this._xAttr);
  };
  view.maxX = function(x) {
    if (x !== undefined) {
      this._maxX = x;
      return this;
    } else {
      return this._maxX;
    }
    //return this._delv.getMax(this._datasetName, this._xAttr);
  };
  view.minY = function(y) {
    if (y !== undefined) {
      this._minY = y;
      return this;
    } else {
      return this._minY;
    }
    //return this._delv.getMin(this._datasetName, this._yAttr);
  };
  view.maxY = function(y) {
    if (y !== undefined) {
      this._maxY = y;
      return this;
    } else {
      return this._maxY;
    }
    //return this._delv.getMax(this._datasetName, this._yAttr);
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


  var size = 100,
      axispad = 0,
      padding = 25,
      n = 4;
  var cell;

  var self = view;
  var xScale = d3.scale.linear().range([padding / 2, size - (padding / 2) - axispad]);
  var yScale = d3.scale.linear().range([size - (padding / 2) - axispad, padding / 2]);

  var xAxis = d3.svg.axis()
      .scale(xScale).orient("bottom")
      .ticks(5)
      .tickSize(size);
  var yAxis = d3.svg.axis()
      .scale(yScale).orient("right")
      .ticks(5)
      .tickSize(size);
  var xFormat = xAxis.tickFormat();
  var yFormat = yAxis.tickFormat();

  var brush;

  setupAxes = function(data) {
    xAxis.tickFormat(self._showXAxis ? xFormat : "");
    yAxis.tickFormat(self._showYAxis ? yFormat : "");
  };

  setupScales = function(data) {
    xScale.domain([self.minX(), self.maxX()]);
    yScale.domain([self.minY(), self.maxY()]);
  };
  // TODO move these sorts of things to d3XYView since it's common across these types of views
  xValue = function(d) {
    return d.xVal;
  };
  yValue = function(d) {
    return d.yVal;
  };
  itemColor = function(d) {
    return d.color;
  };
  
  function bindData(data) {
    setupScales(data);
    setupAxes(data);

    svgElem.selectAll("g").remove();

    svgElem.attr("width", size+padding+axispad)
      .attr("height", size+padding+axispad)
      .append("g")
      .attr("class", "scatterplot_chart");
      //.attr("transform", "translate(359.5,69.5)");

    // X-axis.
    svgElem.selectAll("g.x.axis")
      .data(data)
      .enter().append("g")
      .attr("class", "x axis")
    // TODO figure out how to do layout for small multiples
    //.attr("transform", function(d, i) { return "translate(" + i * size + ",0)"; })
      .each(function(d) { d3.select(this).call(xAxis); });

    // Y-axis.
    svgElem.selectAll("g.y.axis")
      .data(data)
      .enter().append("g")
      .attr("class", "y axis")
    // TODO figure out how to do layout for small multiples
    //.attr("transform", function(d, i) { return "translate(0," + i * size + ")"; })
      .each(function(d) { d3.select(this).call(yAxis); });

    // Cell and plot.
    cell = svgElem.selectAll("g.cell")
      .data(data)
      .enter().append("g")
      .attr("class", "cell");

    cell.append("rect")
      .attr("class", "frame")
      .attr("x", padding / 2)
      .attr("y", padding / 2)
      .attr("width", size - padding - axispad)
      .attr("height", size - padding - axispad);

    // Plot dots.
    cell.selectAll("circle")
      .data(data[0].values)
      .enter().append("circle")
      .attr("fill", function(d) { return d.color; })
      .attr("cx", function(d) { return xScale(xValue(d)); })
      .attr("cy", function(d) { return yScale(yValue(d)); })
        .attr("r", 3);

    // Plot brush.
    cell.call(brush.x(xScale).y(yScale));

    // Titles for the diagonal.
    if (self._title !== "") {
      cell.append("svg:text")
        .attr("x", padding)
        .attr("y", padding)
        .attr("dy", ".71em")
        .text(function(d) { return self._title; });
    }
  } // end bindData
  
  // Clear the previously-active brush, if any.
  brushstart = function(p) {
    if (brush.data !== p) {
      cell.call(brush.clear());
      brush.x(xScale).y(yScale).data = p;
    }
  };

  // Highlight the selected circles.
  inbrush = function(p) {
    var e = brush.extent();
    var xr = [e[0][0], e[1][0]];
    var yr = [e[0][1], e[1][1]];
    if (xr[0] == xr[1]) {
      xr = [];
    }
    if (yr[0] == yr[1]) {
      yr = [];
    }
    //self.selectChanged([],[]);
    delv.log(self._name + " selecting ranges: " + xr + ", " + yr);
    selectRanges(xr, yr);
    self.selectChanged(xr, yr);
  };

  // If the brush is empty, select all circles.
  brushend = function() {
    //if (brush.empty()) {
    //  selectRanges([],[]);
    //  self.selectChanged([],[]);
    //}
  };

  brush = d3.svg.brush()
    //.clamp([true, true])
    .on("brushstart", brushstart)
    .on("brush", inbrush)
    .on("brushend", brushend);

  function clearBrush() {
    cell.call(brush.clear());
  }

  function selectItems(items) {
    svgElem.selectAll(".cell circle")
      .attr("fill", function (d) {
        var i;
        if (items.length == 0) { return d.color;}
        for (i = 0; i < items.length; i++) {
          if (d.name === items[i]) {return d.color;}
        } return "#ccc";
      });
  }
  
  function selectRanges(xrange, yrange) {
    if (!delv.arrayEquals(xrange, self._selectX) ||
        !delv.arrayEquals(yrange, self._selectY)) {
      self._selectX = xrange;
      self._selectY = yrange;
      //if (self._selectX.length > 0 && !delv.arrayEquals(self._selectX, ["",""]) ) {
      //  if (self._selectY.length > 0 && !delv.arrayEquals(self._selectY, ["",""])) {
      if (self._selectX.length > 0) {
        if (self._selectY.length > 0) {
          svgElem.selectAll(".cell circle").attr("fill", function(d) {
            return self._selectX[0] <= xValue(d) && xValue(d) <= self._selectX[1]
              && self._selectY[0] <= yValue(d) && yValue(d) <= self._selectY[1]
              ? d.color : "#ccc";
          });
        } else {
          svgElem.selectAll(".cell circle").attr("fill", function(d) {
            return self._selectX[0] <= xValue(d) && xValue(d) <= self._selectX[1]
                   ? d.color : "#ccc";
          });
        }
      } else {
        //if (self._selectY.length > 0 && !delv.arrayEquals(self._selectY, ["",""])) {
        if (self._selectY.length > 0) {
          svgElem.selectAll(".cell circle").attr("fill", function(d) {
            return self._selectY[0] <= yValue(d) && yValue(d) <= self._selectY[1]
              ? d.color : "#ccc";
          });
        } else {
          svgElem.selectAll(".cell circle").attr("fill", function(d) {
            return d.color;
          });
        }
      }
    }
  }
  
  // Legend.
  // var legend = svg.selectAll("g.legend")
  //     .data(["setosa", "versicolor", "virginica"])
  //   .enter().append("svg:g")
  //     .attr("class", "legend")
  //     .attr("transform", function(d, i) { return "translate(-179," + (i * 20 + 594) + ")"; });

  // legend.append("svg:circle")
  //     .attr("class", String)
  //     .attr("r", 3);

  // legend.append("svg:text")
  //     .attr("x", 12)
  //     .attr("dy", ".31em")
  //     .text(function(d) { return "Iris " + d; });

    return view;

};

