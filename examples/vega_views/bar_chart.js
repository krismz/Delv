var vgWrapperNS = vgWrapperNS || {};

vgWrapperNS.bar_chart_view = function (elem, vgSpec) {
  var newObj = new delv.vegaView(elem, vgSpec);
  newObj._dataset = "";
  newObj._xAttr = "";
  newObj._yAttr = "";
  newObj._title = "";
  newObj._xDomain = [];
  newObj._xIsDate = false;
  newObj.xStart;
  newObj.xEnd;

  newObj.getDatasetName = function() {
    return this._dataset;
  };
  newObj.setDatasetName = function(name) {
    this._dataset = name;
    return this;
  };
  newObj.getXAttr = function() {
    return this._xAttr;
  };
  newObj.setXAttr = function(attr) {
    this._xAttr = attr;
    return this;
  };
  newObj.getYAttr = function() {
    return this._yAttr;
  };
  newObj.setYAttr = function(attr) {
    this._yAttr = attr;
    return this;
  };
  newObj.getTitle = function() {
    return this._title;
  }
  newObj.setTitle = function(title, doParse) {
    this._title = title;
    this.updateSignal("title", {"init":this._title}, doParse);
    return this;
  };
  newObj.updateStartEnd = function(val, doParse) {
    if (typeof(this.xStart) === "undefined") {
      this.updateSignal("xStart", {"init":{"expr": val}}, doParse);
    } else {
      this.updateSignal("xStart", {"init":{"expr": "datetime('"+this.xStart+"')"}}, doParse);
    }
    if (typeof(this.xEnd) === "undefined") {
      this.updateSignal("xEnd", {"init":{"expr": val}}, doParse);
    } else {
      this.updateSignal("xEnd", {"init":{"expr":  "datetime('"+this.xEnd+"')"}}, doParse);
    }
  };
  newObj.getXDomain = function() {
    return this._xDomain;
  }
  newObj.setXDomain = function(domain, doParse) {
    this._xDomain = domain;
    this.mixinSpec();
    if (doParse) {
      this.parseSpec();
    }
    return this;
  };
  
  newObj.xIsDate = function (isDate) {
    this._xIsDate = isDate;
    return this;
  };

  newObj.mixinSpec = function() {
    this.updateSignal("title", {"init":this._title}, false);

    if (typeof(this._xDomain[0]) === typeof("")) {
      this.updateSignal("xLowClamp", {"init":{"expr": this._xDomain[0]}}, false);
      this.updateSignal("xHighClamp", {"init":{"expr": this._xDomain[1]}}, false);
      this.updateStartEnd(this._xDomain[0], false);
      this.updateScale("x", "type", "time", false);
      this.updateScale("x", "nice", "month", false);
      this.updateDomain("x", {"data": "table", "field": "x"}, false);
    } else {
      this.updateSignal("xLowClamp", {"init":this._xDomain[0]}, false);
      this.updateSignal("xHighClamp", {"init":this._xDomain[1]}, false);
      this.updateSignal("xStart", {"init": this.xStart}, false);
      this.updateSignal("xEnd", {"init": this.xEnd}, false);
      this.updateDomain("x", this._xDomain, false);
    }

  };

  newObj.reloadData = function( source ) {
    this.idAll = this._dataIF.getAllIds(this._dataset, this._xAttr);
    this.xAll = this._dataIF.getAllItems(this._dataset, this._xAttr);
    this.yAll = this._dataIF.getAllItemsAsFloat(this._dataset, this._yAttr);
    var vals = [];
    for (var ii=0; ii < this.idAll.length; ii++) {
      vals[ii] = { "x": this.xAll[ii], "y": this.yAll[ii] };
    }

    if (this._xIsDate) {
      this.spec["data"][0]["format"] = { "type": "json",
                                         "parse": {"x": "date"} };
      // TODO undo this hack, was getting the following errors for empty date tables:
      // TypeError: Cannot read property 'getFullYear' of undefined
      if (vals.length == 0) {
        vals[0] = { "x": "1/1/2001", "y": 0 };
      }
    }
    this.spec["data"][0]["values"] = vals;
    this.mixinSpec();
    this.parseSpec();
  };

  newObj.xListener = function(view, sig, val) {
    if (sig === "minX") {
      // update min range
      view._dataIF.updateVisibleMin(view._name, view._dataset, view._xAttr, val);
    } else if (sig === "maxX") {
      // update max range
      view._dataIF.updateVisibleMax(view._name, view._dataset, view._xAttr, val);
    }
  };

  newObj.addListeners = function() {
    var view = this;
    try {
      this.chart.onSignal("xStart", function(sig, val) {
        view.xStart = view.chart.signal(sig);
      });
      this.chart.onSignal("xEnd", function(sig, val) {
        view.xEnd = view.chart.signal(sig);
      });
      this.chart.onSignal("minX", function(sig, val) {
        view.xListener(view, sig, val);
      });

      this.chart.onSignal("maxX", function(sig, val) {
        view.xListener(view, sig, val);
        });
    } catch (e) {
      delv.log("Caught exception (" + e + ") while adding signal listeners to " + this.elem);
    }
  };
  
  return newObj;
}
