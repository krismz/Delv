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
  var view = new delv.d3XYView(name, svgElemId);
  view._hoverCat = "";
  
  view.connectSignals = function() {
    this._delv.connectToSignal("hoverChanged", this._name, "onHoverChanged");
  };

  view.hoverChanged = function( cat ) {
    this._delv.hoverCat(this._name, this._datasetName, this._xAttr, ""+cat);
  };

  view.onHoverChanged = function(signal, invoker, dataset, coordination, detail) {
    var cat;
    if (invoker !== this._name) {
      if (dataset === this._datasetName) {
        // ignore if sent by self
        cat = this._delv.getHoverCat(this._datasetName, this._xAttr);
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
      return d.xVal;
    }).left;
    format = d3.time.format("%Y");
    xScale = d3.scale.linear().nice().range([0, width]);
    yScale = d3.scale.linear().range([height, 0]);
    xValue = function(d) {
      return d.xVal;
    };
    yValue = function(d) {
      return d.yVal;
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
      yScale.domain([self.minY(), mxY]);
      return xScale.domain([self.minX(), self.maxX()]);
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

  return view;
};
