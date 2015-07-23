var vgWrapperNS = vgWrapperNS || {};

vgWrapperNS.bar_chart_view = function (elem, vgSpec) {
  var newObj = new delv.vegaView(elem, vgSpec);
  newObj._dataset = "";
  newObj._xAttr = "";
  newObj._yAttr = "";
  newObj._title = "";
  newObj._xDomain = [];
  newObj._xIsDate = false;

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
    this.updateSignal("title", this._title, doParse);
    return this;
  };
  newObj.getXDomain = function() {
    return this._xDomain;
  }
  newObj.setXDomain = function(domain, doParse) {
    this._xDomain = domain;
    if (typeof(this._xDomain[0]) === typeof("")) {
      this.updateSignal("xLowClamp", {"init":{"expr": this._xDomain[0]}}, false);
      this.updateSignal("xHighClamp", {"init":{"expr": this._xDomain[1]}}, false);
      this.updateSignal("xStart", {"init":{"expr": this._xDomain[0]}}, false);
      this.updateSignal("xEnd", {"init":{"expr": this._xDomain[1]}}, false);
      this.updateScaleType("x", "time", false);
      this.updateDomain("x", {"data": "table", "field": "x"}, doParse);
    } else {
      this.updateSignal("xLowClamp", this._xDomain[0], false);
      this.updateSignal("xHighClamp", this._xDomain[1], false);
      this.updateDomain("x", this._xDomain, doParse);
    }
    return this;
  };
  
  newObj.xIsDate = function (isDate) {
    this._xIsDate = isDate;
    return this;
  };

  newObj.reloadData = function( source ) {
    this.idAll = this._dataIF.getAllIds(this._dataset, this._xAttr);
    this.xAll = this._dataIF.getAllItems(this._dataset, this._xAttr);
    this.yAll = this._dataIF.getAllItemsAsFloat(this._dataset, this._yAttr);
    var vals = [];
    for (var ii=0; ii < this.idAll.length; ii++) {
      vals[ii] = { "x": this.xAll[ii], "y": this.yAll[ii] };
    }
    this.spec["data"][0]["values"] = vals;
    if (this._xIsDate) {
      this.spec["data"][0]["format"] = { "type": "json",
                                         "parse": {"x": "date"} };
    }
    this.parseSpec();
  };

  newObj.addListeners = function() {
    var view = this;
    try {
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

  newObj.xListener = function(view, sig, val) {
    if (sig === "minX") {
      // update min range
      view._dataIF.setVisibleMin(view._dataset, view._xAttr, val);
    } else if (sig === "maxX") {
      // update max range
      view._dataIF.setVisibleMax(view._dataset, view._xAttr, val);
    }
  };
  
  return newObj;
}
