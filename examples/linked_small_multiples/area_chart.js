// ======================================================================
// Copyright (c) 2015, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

var d3Views = d3Views || {};

///////////////////////////////////
//              View             //
///////////////////////////////////
d3Views.area_chart_view = function( name, svgElemId ) {
  // Stuff for Delv compatibility
  var view = new delv.d3View(name, svgElemId);
  view._xAttr = "";
  view._yAttr = "";
  view._label = "";
  view._maxY = {};
  view._extentX = [];
  view._hoverCat = "";
  
  view.xAttr = function(attr) {
    if (attr !== undefined) {
      this._xAttr = attr;
      return this;
    } else {
      return this._xAttr;
    }
  };

  view.extentX = function(extentX) {
    if (extentX !== undefined) {
      this._extentX = extentX;
      return this;
    } else {
      return this._extentX;
    }
  };

  
  view.yAttr = function(attr) {
    if (attr !== undefined) {
      this._yAttr = attr;
      return this;
    } else {
      return this._yAttr;
    }
  };

  view.maxY = function(maxY) {
    if (maxY !== undefined) {
      this._maxY = maxY;
      return this;
    } else {
      return this._maxY;
    }
  };

  view.label = function(label) {
    if (label !== undefined) {
      this._label = label;
      return this;
    } else {
      return this._label;
    }
  };

  view.connectSignals = function() {
    this._delv.connectToSignal("hoverChanged", this._name, "onHoverChanged");
  };

  view.hoverChanged = function( cat ) {
    this._delv.hoverCat(this._name, this._datasetName, this._xAttr, ""+cat);
  };

  view.onHoverChanged = function(invoker, dataset, coordination, detail) {
    var cat;
    if (invoker !== this._name) {
      // ignore if sent by self
      cat = this._delv.getHoverCat(this._datasetName, this._xAttr);
      hoverCat(cat);
    }
  };

  view.onDataChanged = function() {
    var rawData = {};
    var data = [];
    var values = [];
    var d;
    rawData.xVals = this._delv.getAllItems(this._datasetName, this._xAttr);
    rawData.yVals = this._delv.getAllItems(this._datasetName, this._yAttr);
    rawData.label = this._label;
    for (d = 0; d < rawData.xVals.length; d++) {
      values[d] = {"xVals": rawData.xVals[d], "yVals": rawData.yVals[d]};
    }
    data[0] = { "values": values,
                "key": rawData.label };
    bindData(data);
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
  
  // TODO make this area chart more generic - not year-based
  // Stuff from original small_multiples.js file:
  // Changes:  year to xVal, n to yVal
  var area, bisect, caption, chart, circle, curXVal, data, format, height, line, margin, mousemove, mouseout, mouseover, setupScales, width, xScale, xValue, yAxis, yScale, yValue, self;
    self = view;
    width = 150;
    height = 120;
    margin = {
      top: 15,
      right: 10,
      bottom: 40,
      left: 35
    };
    data = [];
    circle = null;
    caption = null;
    curXVal = null;
    bisect = d3.bisector(function(d) {
      return d.xVals;
    }).left;
    format = d3.time.format("%Y");
  //xScale = d3.time.scale().range([0, width]);
  xScale = d3.scale.linear().nice().range([0, width]);
    yScale = d3.scale.linear().range([height, 0]);
    xValue = function(d) {
      return d.xVals;
    };
    yValue = function(d) {
      return d.yVals;
    };
    yAxis = d3.svg.axis().scale(yScale).orient("left").ticks(4).outerTickSize(0).tickSubdivide(1).tickSize(-width);
    area = d3.svg.area().x(function(d) {
      return xScale(xValue(d));
    }).y0(height).y1(function(d) {
      return yScale(yValue(d));
    });
    line = d3.svg.line().x(function(d) {
      return xScale(xValue(d));
    }).y(function(d) {
      return yScale(yValue(d));
    });
    setupScales = function(data) {
      var mxY;
      mxY = self.maxY() + (self.maxY() * 1 / 4);
      yScale.domain([0, mxY]);
      return xScale.domain(self.extentX());
    };

  function bindData(data) {
    var div, g, lines;
    setupScales(data);
    // TODO better way to handle streaming data?
    g = svgElem.selectAll(".area_chart").remove();
    g = svgElem.selectAll(".area_chart").data(data);
    g.enter().append("g").attr("class", "area_chart");
    svgElem.attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom);
    g = svgElem.select("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    g.append("rect").attr("class", "background").style("pointer-events", "all").attr("width", width + margin.right).attr("height", height).on("mouseover", mouseover).on("mousemove", mousemove).on("mouseout", mouseout);
    lines = g.append("g");
    lines.append("path").attr("class", "area").style("pointer-events", "none").attr("d", function(c) {
      return area(c.values);
    });
    lines.append("path").attr("class", "line").style("pointer-events", "none").attr("d", function(c) {
      return line(c.values);
    });
    lines.append("text").attr("class", "title").attr("text-anchor", "middle").attr("y", height).attr("dy", margin.bottom / 2 + 5).attr("x", width / 2).text(function(c) {
      return c.key;
    });
    lines.append("text").attr("class", "static_x").attr("text-anchor", "start").style("pointer-events", "none").attr("dy", 13).attr("y", height).attr("x", 0).text(function(c) {
      return xValue(c.values[0]);
    });
    lines.append("text").attr("class", "static_x").attr("text-anchor", "end").style("pointer-events", "none").attr("dy", 13).attr("y", height).attr("x", width).text(function(c) {
      return xValue(c.values[c.values.length - 1]);
    });
    circle = lines.append("circle").attr("r", 2.2).attr("opacity", 0).style("pointer-events", "none");
    caption = lines.append("text").attr("class", "caption").attr("text-anchor", "middle").style("pointer-events", "none").attr("dy", -8);
    curXVal = lines.append("text").attr("class", "year").attr("text-anchor", "middle").style("pointer-events", "none").attr("dy", 13).attr("y", height);
    g.append("g").attr("class", "y axis").call(yAxis);
  }
  
  mouseover = function() {
    return "";
  };
  mousemove = function(d) {
    var val, index, cat;
    val = xScale.invert(d3.mouse(this)[0]);
    index = bisect(d.values, val, 0, d.values.length-1);
    cat = xValue(d.values[index]);
    hoverCat(cat);
    self.hoverChanged(cat);
  };

  function hoverCat(cat) {
    var d;
    var index;
    if (cat !== self._hoverCat) {
      self._hoverCat = cat;
      if (cat != "") {
        circle.attr("opacity", 1.0);
        svgElem.selectAll(".static_x").classed("hidden", true);
        d = svgElem.select("g").data()[0];
        // TODO, this bisect operator assumes cat is really a number.  Handle more generally? Ordinal type?
        index = bisect(d.values, +cat, 0, d.values.length-1);
        circle.attr("cx", function(c) {
          return xScale(xValue(c.values[index]));
        }).attr("cy", function(c) {
          return yScale(yValue(c.values[index]));
        });
        caption.attr("x", function(c) {
          return xScale(xValue(c.values[index]));
        }).attr("y", function(c) {
          return yScale(yValue(c.values[index]));
        }).text(function(c) {
          return yValue(c.values[index]);
        });
        return curXVal.attr("x", function(c) {
          return xScale(xValue(c.values[index]));
        }).text(function(c) {
          return xValue(c.values[index]);
        });
      } else {
        d3.selectAll(".static_x").classed("hidden", false);
        circle.attr("opacity", 0);
        caption.text("");
        return curXVal.text("");
      }
    }
  }

  
  mouseout = function() {
    hoverCat("");
    self.hoverChanged("");
  };

  // don't think we need this
  // TODO why?
  // x = function(_) {
  //   if (!arguments.length) {
  //     return xValue;
  //   }
  //   xValue = _;
  //   return this;
  // };

  // y = function(_) {
  //   if (!arguments.length) {
  //     return yValue;
  //   }
  //   yValue = _;
  //   return this;
  // };

// don't need data transformation
// TODO explain why
  // transformData = function(rawData) {
  //   var format, nest;
  //   format = d3.time.format("%Y");
  //   rawData.forEach(function(d) {
  //     d.date = format.parse(d.year);
  //     return d.n = +d.n;
  //   });
  //   nest = d3.nest().key(function(d) {
  //     return d.category;
  //   }).sortValues(function(a, b) {
  //     return d3.ascending(a.date, b.date);
  //   }).entries(rawData);
  //   return nest;
  // };

// don't need this plot function
// TODO explain why
  // plotData = function(selector, data, plot) {
  //   return d3.select(selector).datum(data).call(plot);
  // };

  return view;
};
