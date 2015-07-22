var vgWrapperNS = vgWrapperNS || {};

vgWrapperNS.bar_chart_view = function (elem, vgSpec) {
  var newObj = new delv.vegaView(elem, vgSpec);
  newObj._dataset = "";
  newObj._xAttr = "";
  newObj._yAttr = "";
  newObj._title = "";
  newObj._xDomain = [];

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
      var expr = {"expr": this._xDomain[0]};
      this.updateSignal("xLowClamp", expr, false);
      expr["expr"] = this._xDomain[1];
      this.updateSignal("xHighClamp", expr, false);
    } else {
      this.updateSignal("xLowClamp", this._xDomain[0], false);
      this.updateSignal("xHighClamp", this._xDomain[1], false);
    }
    this.updateDomain("x", this._xDomain, doParse);
    return this;
  };

  newObj.reloadData = function( source ) {
    this.idAll = this._dataIF.getAllIds(this._dataset, this._xAttr);
    this.xAll = this._dataIF.getAllItems(this._dataset, this._xAttr);
    this.yAll = this._dataIF.getAllItems(this._dataset, this._yAttr);
    var vals = [];
    for (var ii=0; ii < this.idAll.length; ii++) {
      vals[ii] = { "x": this.xAll[ii], "y": this.yAll[ii] };
    }
    this.spec["data"][0]["values"] = vals;
    this.parseSpec();
  };

  newObj.addListeners = function() {
    try {
      this.chart.onSignal("minX", this.xListener);
      this.chart.onSignal("maxX", this.xListener);
    } catch (e) {
      delv.log("Caught exception (" + e + ") while adding signal listeners to " + this.elem);
    }
  };

  newObj.xListener = function(sig, val) {
    if (sig === "minX") {
      // update min range
      this._dataIF.setVisibleMin(this._dataset, this._xAttr, val);
    } else if (sig === "maxX") {
      // update max range
      this._dataIF.setVisibleMax(this._dataset, this._xAttr, val);
    }
  };
  
  return newObj;
}
