// jslint directives
/*jslint browser: true, unparam: true, evil: true */
/*globals delv, Processing, $, d3, vg, undefined */

// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

// Assumes that processing has already been loaded
// TODO this hack is for apps that don't need processing or vega
var Processing = Processing || {};
var vg = vg || {};

// using the Self-Executing Anonymous Function pattern as described at:
// http://enterprisejquery.com/2010/10/how-good-c-habits-can-encourage-bad-javascript-habits-part-1/
(function( delv, Processing, $, vg, undefined ) {

  // private TODO is this available to extensions of delv in other files? Does it need to be?
  var data = {};
  var views = {};
  var p5s = {};
  var _hoverColor = [];
  var _selectColor = {};
  var _filterColor = [];
  var _likeColor = [];
  var _hoverColorSet = false;
  var _selectColorSet = {"PRIMARY": false, "SECONDARY": false, "TERTIARY": false};
  var _filterColorSet = false;
  var _likeColorSet = false;
  
  // public
  delv.signalHandlers = {};

  // turn obj into a delv view
  delv.view = function() {
    this._name = "";
    this._delv = {};
    this._datasetName = "";
    this.bindDelv(dlv) {
      this._delv = dlv;
      return this;
    };
    this.dataSet(dataSetName) {
      this._datasetName = dataSetName;
    }
    this.getName = function() {
      return this._name;
    };
    this.setName = function(name) {
      this._name = name;
      return this;
    };
    this.resize = function(w, h) {};
    this.connectSignals = function() {};
    this.onDataChanged = function(source) {};
  }; // end delv.view

  // turn obj into a d3 view
  delv.d3View = function(svgElem) {
    var newObj = new delv.view();
    newObj.svgElem = svgElem;
    return newObj;
  }; // end delv.d3View

  // A view that can join attributes across 2 datasets
  // if a signal comes in for one attribute, it gets resent
  // for the corresponding attribute in the other dataset
  delv.joinView = function(name) {
    var newObj = new delv.view();
    newObj._name = name;
    newObj._dataset1Name = "";
    newObj._dataset2Name = "";
    newObj._dataset1Attr = "";
    newObj._dataset2Attr = "";

    newObj.getDataset1Name = function() {
      return this._dataset1Name;
    };
    newObj.setDataset1Name = function(name) {
      this._dataset1Name = name;
      return this;
    };
    newObj.getDataset1Attr = function() {
      return this._dataset1Attr;
    };
    newObj.setDataset1Attr = function(attr) {
      this._dataset1Attr = attr;
      return this;
    };
    newObj.getDataset2Name = function() {
      return this._dataset2Name;
    };
    newObj.setDataset2Name = function(name) {
      this._dataset2Name = name;
      return this;
    };
    newObj.getDataset2Attr = function() {
      return this._dataset2Attr;
    };
    newObj.setDataset2Attr = function(attr) {
      this._dataset2Attr = attr;
      return this;
    };
    newObj.connectSignals = function() {
      // TODO figure out how to handle joining id selection.  Can we assume that the ids match up, or do we need to follow a join relation for them first?
      // delv.connectToSignal("selectChanged", this._name, "onSelectChanged");
      this._delv.connectToSignal("colorChanged", this._name, "onColorChanged");
      // TODO add other signals here.

    };
    newObj.onColorChanged = function(invoker, dataset, attribute) {
      if (invoker !== this._name) {
        if (dataset === this._dataset1Name &&
          attribute === this._dataset1Attr) {
          this.transferColors(this._dataset1Name, this._dataset1Attr, this._dataset2Name, this._dataset2Attr);
        } else if (dataset === this._dataset2Name &&
                   attribute === this._dataset2Attr) {
          this.transferColors(this._dataset2Name, this._dataset2Attr, this._dataset1Name, this._dataset1Attr);
        }
      }
    };
    newObj.transferColors = function(fromDS, fromAttr, toDS, toAttr) {
      var cats = this._delv.getAllCats(fromDS, fromAttr);
      var colors = this._delv.getCatColors(fromDS, fromAttr);
      var ii;
      for (ii = 0; ii < cats.length; ii++) {
        this._delv.colorCat(this._name, toDS, toAttr, cats[ii], colors[ii]);
      }
    };
        
          
    return newObj;
  }; // end delv.joinView

  // turn obj into a d3 hierarchy view
  delv.d3HierarchyView = function(svgElem) {
    var newObj = new delv.d3View(svgElem);
    newObj._nodeSizeAttr = "";
    newObj._nodeNameAttr = "";
    newObj._linkStartAttr = "";
    newObj._linkEndAttr = "";
    newObj._nodeDataset = "";
    newObj._linkDataset = "";

    newObj.getNodeDatasetName = function() {
      return this._nodeDataset;
    };
    newObj.setNodeDatasetName = function(name) {
      this._nodeDataset = name;
      return this;
    };
    newObj.getLinkDatasetName = function() {
      return this._linkDataset;
	  };
	  newObj.setLinkDatasetName = function(name) {
		  this._linkDataset = name;
		  return this;
	  };
    newObj.getNodeSizeAttr = function() {
      return this._nodeSizeAttr;
    };
    newObj.setNodeSizeAttr = function(attr) {
      this._nodeSizeAttr = attr;
      return this;
    };
    newObj.getNodeNameAttr = function() {
      return this._nodeNameAttr;
    };
    newObj.setNodeNameAttr = function(attr) {
      this._nodeNameAttr = attr;
      return this;
    };
    newObj.getLinkStartAttr = function() {
      return this._linkStartAttr;
    };
    newObj.setLinkStartAttr = function(attr) {
      this._linkStartAttr = attr;
      return this;
    };
    newObj.getLinkEndAttr = function() {
      return this._linkEndAttr;
    };
    newObj.setLinkEndAttr = function(attr) {
      this._linkEndAttr = attr;
      return this;
    };

    newObj.convertToHierarchy = function() {
      var node_ids = this._delv.getAllIds(this._nodeDataset, this._nodeNameAttr);
      var node_names = this._delv.getAllItems(this._nodeDataset, this._nodeNameAttr);
      var node_sizes = this._delv.getAllItems(this._nodeDataset, this._nodeSizeAttr);

      var link_start = this._delv.getAllItems(this._linkDataset, this._linkStartAttr);
      var link_end = this._delv.getAllItems(this._linkDataset, this._linkEndAttr);

      var nodes = {};
      var root_node = "";
      var i;
      var node = {};
      var numchildren;
      var j;
      var node_hierarchy = {};

      if (node_ids.length === 0) {
        return node_hierarchy;
      }

      for (i = 0; i < node_names.length; i++) {
        node = {};
        // here is where we translate from data IF representation (names, ids)
        // to view-specific representation (names, tags)
        node.tag = node_names[i];
        node.name = node_ids[i];
        node.children = [];
        node.parent = "";
        numchildren = 0;
        node.size = parseInt(node_sizes[i], 10);
        for (j = 0; j < link_start.length; j++) {
	        if (link_start[j] === node.name) {
	          // current node is a parent, append the child
	          node.children[numchildren] = link_end[j];
	          numchildren++;
	        }
	        else if (link_end[j] === node.name) {
	          // current node is a child (assuming data set is such that each node only has one parent)
	          node.parent = link_start[j];
	        }
        }
        if (node.parent === "") {
	        // currently assuming data set has exactly one root node
	        root_node = node.name;
        }
        nodes[node.name] = node;
      }

      // now to hierarchy
      node_hierarchy = getNode(root_node, nodes);
      return node_hierarchy;
    };

    function getNode(name, nodes) {
      var node = {};
      var children = [];
      var i;

      if (!nodes.hasOwnProperty(name)) {
        return node;
      }
      node.name = name;
      node.tag = nodes[name].tag;
      for (i = 0; i < nodes[name].children.length; i++) {
        children[i] = getNode(nodes[name].children[i], nodes);
      }
      if (children.length > 0) {
        node.children = children;
      }
      else {
        node.size = nodes[name].size;
      }
      return node;
    }

    return newObj;
  }; // end delv.d3HierarchyView

  // turn obj into a vega view
  delv.vegaView = function(elem, vgSpec) {
    var newObj = new delv.view();
    newObj._name = elem;
    newObj.elem = elem;
    newObj.spec = vgSpec;
    newObj.chart;
    newObj._renderer = "canvas";
    newObj._h;
    newObj._w;

    finishSpecLoad = function(chart, view) {
      view.chart = chart({el:"#"+view.elem});
      try {
        view.addListeners();
        view.chart.renderer(view._renderer).update();
        view.updateChartSize();
      } catch (e) {
        delv.log("Caught error (" + e + ") while loading vega spec for " + view._name + " view");
      }
    }

    newObj.parseSpec = function() {
      var view = this;
      vg.parse.spec(this.spec, function (chart) {
        finishSpecLoad(chart, view);
      });
    }

    newObj.renderSVG = function() {
      this._renderer = "svg";
      return this;
    }

    newObj.renderCanvas = function() {
      this._renderer = "canvas";
      return this;
    }

    newObj.resize = function(w, h) {
      this._w = w;
      this._h = h;
      this.updateChartSize();
    }

    newObj.updateChartSize = function() {
      if ((typeof(this._w) !== "undefined") && (typeof(this._h) !== "undefined") &&
          (typeof(this.chart) !== "undefined")) {
        this.chart.width(this._w).height(this._h).update();
      }
    };
    
    newObj.updateSignal = function(signal, val, doParse) {
      if (typeof(val) === typeof({})) {
        var sigs = this.spec["signals"];
        for (var ii = 0; ii < sigs.length; ii++) {
          if (sigs[ii]["name"] === signal) {
            for (var k in val) {
              sigs[ii][k] = val[k];
            }
          }
        }
        if (doParse) {
          this.parseSpec();
        }
        
      } else {
        var sigs = this.spec["signals"];
        for (var ii = 0; ii < sigs.length; ii++) {
          if (sigs[ii]["name"] === signal) {
            sigs[ii]["init"] = val;
          }
        }
        if (doParse) {
          this.parseSpec();
        }
      }
    }

    newObj.updateScale = function(scale, key, value, doParse) {
      // TODO updates top-level scales only.  For more specific use, probably need to override on case-by-case basis
      var scales = this.spec["marks"][0]["scales"];
      for (var ii = 0; ii < scales.length; ii++) {
        if (scales[ii]["name"] === scale) {
          scales[ii][key] = value;
        }
      }
      if (doParse) {
        this.parseSpec();
      }
    }
    
    newObj.updateDomain = function(scale, domain, doParse) {
      // TODO updates top-level scales only.  For more specific use, probably need to override on case-by-case basis
      var scales = this.spec["marks"][0]["scales"];
      for (var ii = 0; ii < scales.length; ii++) {
        if (scales[ii]["name"] === scale) {
          scales[ii]["domain"] = domain;
        }
      }
      if (doParse) {
        this.parseSpec();
      }
    }

    newObj.updateRange = function(scale, range, doParse) {
      // TODO updates top-level scales only.  For more specific use, probably need to override on case-by-case basis
      var scales = this.spec["marks"][0]["scales"];
      for (var ii = 0; ii < scales.length; ii++) {
        if (scales[ii]["name"] === scale) {
          scales[ii]["range"] = range;
        }
      }
      if (doParse) {
        this.parseSpec();
      }
    }

    newObj.addListeners = function() {}

    return newObj;
  }; // end delv.vegaView

  delv.d3Chart = function (elementId, script, viewConstructor, loadCompleteCallback) {
    var elemId = elementId;
    var chartLoaded = false;

    function initChart(script, viewConstructor, loadCompleteCallback) {
      chartLoaded = false;
      $.getScript(script, finishChartInit);
    }
    initChart(script, viewConstructor, loadCompleteCallback);

    function finishChartInit(d3_script, textStatus, jqxhr) {
      delv.log("d3 script loaded!  elemId: " + elemId + ", textStatus: " + textStatus + ", jqxhr: " + jqxhr);
      var view;
      var callConstructor = "view = new " + viewConstructor + "(elemId)";
	    try {
	      eval(callConstructor);
	    } catch (e) {
	      delv.log("initializing d3 chart for " + elemId + " failed while trying to call\n" + callConstructor + "\n.  Try again later");
	      chartLoaded = false;
	    }
	    if (typeof(view) !== "undefined") {
	      chartLoaded = true;
	    }
	    if (chartLoaded) {
	      delv.addView(view, elemId);
	      view.connectSignals();
	      loadCompleteCallback(view, elemId);
	    }
    }

  };

  delv.vegaChart = function (elementId, viewsrc, script, constructor, loadCompleteCallback) {
    var elemId = elementId;
    var chartLoaded = false;
    function initChart(elemId, viewsrc, script, constructor, loadCompleteCallback) {
      chartLoaded = false;
      $.getScript(viewsrc, loadSpec);
    }
    initChart(elemId, viewsrc, script, constructor, loadCompleteCallback);

    function loadSpec(vg_src, textStatus, jqxhr) {
      // TODO use different json reader than D3's?
      d3.json(script, function(error, json) {
        delv.log("read in json, error: " + error);
        finishChartInit(json, constructor);
      });
    }
      
    function finishChartInit(json, constructor) {
      // TODO call chart update here or in loadCompleteCallback or elsewhere?
      chartLoaded = true;
      // Now wrap the chart into a Delv view
      var view;
      var callConstructor = "view = new " + constructor + "(elemId, json)";
      try {
        eval(callConstructor);
      } catch (e) {
        delv.log("initializing vega chart for " + elemId + " failed while trying to call\n" + callConstructor + "\n.  Error: " + e);
        chartLoaded = false;
      }
      if (typeof(view) === "undefined") {
        chartLoaded = false;
      }
      if (chartLoaded) {
        delv.addView(view, elemId);
        view.connectSignals();
        loadCompleteCallback(view, elemId);
      }
    }
  };
  
  delv.processingSketch = function ( canvas, sketchList, viewConstructor, loadCompleteCallback ) {
    var canvasId;
    var sketchLoaded;
    var p; // processing instance
    
    // public functions
    this.resize = function ( w, h ) {
      p.resize(w, h, true);
    };

    // internal functions
    function initSketch(canvas, sketchList, viewConstructor, loadCompleteCallback) {
      sketchLoaded = false;
      Processing.loadSketchFromSources(canvas, sketchList);
      canvasId = canvas.getAttribute("id");
      // TODO poll to figure out when sketches have loaded.
      // A version of processing will come out soon that will allow passing callbacks
      // for onload, onexit, etc.
      // follow this ticket for more information:
      // https://processing-js.lighthouseapp.com/projects/41284/tickets/1887-make-it-easier-to-add-sketch-event-callbacks#ticket-1887-4
      setTimeout(finishSketchInit, 250);
    }

    initSketch(canvas, sketchList, viewConstructor, loadCompleteCallback);

    function finishSketchInit() {
      if (!sketchLoaded) {
	      p = Processing.getInstanceById(canvasId);
	      var callConstructor = "p._view = new p." + viewConstructor + "()";
	      try {
	        eval(callConstructor);
          delv.log("constructed processing sketch view for " + canvasId + " with call: " + callConstructor);
	      } catch (e) {
	        delv.log("initializing processing instance " + canvasId + " failed (" + e + ").  Try again later");
	        sketchLoaded = false;
	      }
	      if ((typeof(p) !== "undefined") &&
            (typeof(p._view) !== "undefined")) {
          delv.log(canvasId + " sketch loaded");
	        sketchLoaded = true;
	      }
        else {
          if (typeof(p) !== "undefined" && typeof(p._view) === "undefined") {
            delv.log("p defined, but view is not!");
          }
        }
	      if (sketchLoaded) {
	        p.bindJavascript = p._view.bindDelv;
	        p.resize = p._view.resize;
	        p.setup = p._view.setup;
	        p.draw = p._view.draw;
          p.redraw=p._view.redraw;
	        p.mouseMoved = p._view.mouseMoved;
	        p.mouseOut = p._view.mouseOut;
	        p.mouseDragged = p._view.mouseDragged;
	        p.mousePressed = p._view.mousePressed;
	        p.mouseReleased = p._view.mouseReleased;
	        p.mouseClicked = p._view.mouseClicked;
	        p.mouseScrolled = p._view.mouseScrolled;
          p.movieEvent = p._view.movieEvent;
	        p._view._p = p;
	        // TODO where should p be bound in delv?
	        p.bindJavascript(delv);
	        p.bound = true;
          p._view.name(canvasId);
	        delv.addView(p._view, canvasId);
	        p._view.connectSignals();
          delv.addP5Instance(p, canvasId);
	        loadCompleteCallback(p._view, canvasId);
	      }
	      else {
	        setTimeout(finishSketchInit, 250);
	      }
      }
    }
  }; // end processingSketch declaration

  function init() {
    // Add event handlers
    try {
      // browsers with native SVG support, use the browsers resize event
      window.addEventListener("resize",delv.resizeAll,false);
    }
    catch(er) {
      //SVG UAs, like Batik and ASV/Iex
      document.documentElement.addEventListener("SVGResize",delv.resizeAll,false);
    }
  }
  init();

  // from http://davidwalsh.name/javascript-debounce-function
  delv.debounce = function (func, wait, immediate) {
	  var timeout;
	  return function() {
		  var context = this, args = arguments;
		  var later = function() {
			  timeout = null;
			  if (!immediate) func.apply(context, args);
		  };
		  var callNow = immediate && !timeout;
		  clearTimeout(timeout);
		  timeout = setTimeout(later, wait);
		  if (callNow) func.apply(context, args);
	  };
  };

  var debounced_resize =  delv.debounce(function() { do_resize();}, 75, false);

  delv.resizeAll = function() {
    debounced_resize();
  };

  function do_resize() {
    var view;
    var parent;
    var width;
    var height;
    delv.log("entering resizeAll");
    for (view in views) {
      if (views.hasOwnProperty(view)) {
        delv.log("resizing " + view);
        parent = $("#" + view).parent();
        width = parent.width();
        height = parent.height();
        views[view].resize(width, height);
      }
    }
  }

  delv.reloadData = function() {
    var view;
    var p5;
    for (view in views) {
      if (views.hasOwnProperty(view)) {
        views[view].reloadData("delv.js");
      }
    }
    for (p5 in p5s) {
      if (p5s.hasOwnProperty(p5)) {
        p5s[p5].draw();
      }
    }
  };


  delv.addView = function (view, id) {
    delv.log("Adding view for " + id);
    delv.log("typeof view: " + typeof(view));
    view.bindDelv(delv);
    views[id] = view;
    return delv;
  };

  delv.getView = function(name) {
    if (views.hasOwnProperty(name)) {
      return views[name];
    } else {
      return {};
    }
  };

  delv.addP5Instance = function(p, id) {
    p5s[id] = p;
    return delv;
  };
  
  // a hacky function to deal with asychronicity between data load and view load
  // delv.giveDataIFToViews = function (dataIFName) {
  //   var view;
  //   for (view in views) {
  //     if (views.hasOwnProperty(view)) {
  //       views[view].dataIF(dataIFName);
  //     }
  //   }
  // };	

  // TODO redo this Qt connection with new signals and delv
  // delv.connectToQt = function() {
  //   // Use QtWebKit to connect.  This method should be called from the Qt side of the QtWebKit bridge
  //   var dataIF;
  //   for (dataIF in dataSources) {
  //     if (dataSources.hasOwnProperty(dataIF)) {
  //       dataSources[dataIF].categoryVisibilityChanged.connect(delv, delv.handleSignal);
  //       dataSources[dataIF].categoryColorsChanged.connect(delv, delv.handleSignal);
  //       dataSources[dataIF].hoveredCategoryChanged.connect(delv, delv.handleSignal);
  //       dataSources[dataIF].highlightedCategoryChanged.connect(delv, delv.handleSignal);

  //       dataSources[dataIF].selectedIdsChanged.connect(delv, delv.handleSignal);
  //       dataSources[dataIF].highlightedIdChanged.connect(delv, delv.handleSignal);
  //       dataSources[dataIF].hoveredIdChanged.connect(delv, delv.handleSignal);
  //     }
  //   }
  // };

  delv.emitEvent = function(name, detail) {
    $( document ).trigger(name, [name, detail]);
  };

  delv.log = function(msg) {
    console.log(msg);
  };

  delv.connectToSignal = function (signal, name, method) {
    delv.log("ConnectToSignal(" + signal + ", " + name + ", " + method + ")");
    if (delv.signalHandlers.hasOwnProperty(signal)) {
      delv.signalHandlers[signal][name] = method;
    }
    else {
      delv.signalHandlers[signal] = {};
      delv.signalHandlers[signal][name] = method;
    }
  };

  delv.disconnectFromSignal = function (signal, name) {
    if (delv.signalHandlers.hasOwnProperty(signal)) {
      delete delv.signalHandlers[signal][name];
    }
    else {
      delv.log("Cannot disconnect unrecognized signal: " + signal);
    }
  };

  delv.handleSignal = function(signal, invoker, dataset, attribute, detail) {
    var key;
    var view;
    var method;
    var fullcall;
    delv.log("handleSignal(" + signal + ", " + invoker + ", " + dataset + ", " + attribute + ", " + detail + ")");
    delv.log("typeof invoker: " + typeof(invoker));
    delv.log("typeof dataset: " + typeof(dataset));
    delv.log("typeof attribute: " + typeof(attribute));
    delv.log("typeof detail: " + typeof(detail));
    try {
      for (key in delv.signalHandlers[signal]) {
        if (delv.signalHandlers[signal].hasOwnProperty(key)) {
          try {
            view = views[key];
            delv.log("key: " + key);
            delv.log("typeof view: " + typeof(view));
            method = delv.signalHandlers[signal][key];
            if (typeof(attribute) !== "undefined") {
              if (typeof(detail) !== "undefined") {
                fullcall = "view." + method + "(invoker, dataset, attribute, detail)";
              } else {
                fullcall = "view." + method + "(invoker, dataset, attribute)";
              }
            } else {
              fullcall = "view." + method + "(invoker, dataset)";
            }
            delv.log("calling eval(" + fullcall + ")");
            // TODO using eval to get around Java not being able to pass methods around
            eval(fullcall);
            //     method(invoker, attribute);
          } catch (e) {
            delv.log("error evaluating " + fullcall + " for " + key + ": " + e);
          }
        }
      }
    } catch (e) {
      delv.log("unrecognized signal " + signal + ": " + e);
    }
  };

  delv.debouncedHandleSignal = delv.debounce( delv.handleSignal, 200, false);

  delv.emitSignal = function(signal, invoker, dataset, coordination, detail) {
    // TODO, debounce here is not ideal, really want to think about more appropriate location
    //delv.handleSignal(signal, invoker, dataset, coordination, detail);
    delv.debouncedHandleSignal(signal, invoker, dataset, coordination, detail);
  };

  delv.exception = function(message) {

    delv.exception.prototype.toString = function() {
      var name = this.name || 'unknown';
      var message = this.message || 'no description';
      return '[' + name + '] ' + message;
    };
  };

  delv.dataSetException = function(message) {
    this.name = 'dataSetException';
    this.message = message;
  };

  delv.dataSetException.prototype = new delv.exception();

  delv.pair = function(frst, scnd) {
    var first = frst;
    var second = scnd;

    this.set = function(frst, scnd) {
      first = frst;
      second = scnd;
    }

    this.equals = function(other) {
      return (first === other.first && second === other.second);
    };
  };
  
  // a basic implementation of the delv data interface
  delv.addDataSet = function(name, dataset) {
    dataset.bindDelv(this);
    data[name] = dataset;
    return;
  };
  delv.getDataSet = function(name) {
    if (data.hasOwnProperty(name)) {
      return data[name];
    } else {
      return {};
    }
  };
  delv.hasDataSet = function(name) {
    return data.hasOwnProperty(name);
  };
  delv.removeDataSet = function(name) {
    if (data.hasOwnProperty(name)) {
      delete data[name];
    }
  };
  
  delv.addAttr = function(dataset, attr) {
    try {
      data[dataset].addAttr(attr);
    } catch (e) {
      return;
    }
  };
  delv.hasAttr = function(dataset, attr) {
    try {
      return data[dataset].hasAttr(attr);
    } catch (e) {
      return false;
    }
  };
  delv.getAttrs = function(dataset) {
    try {
      return data[dataset].getAttrs();
    } catch (e) {
      return [];
    }
  };

  delv.getAllCats = function(dataset, attr) {
    // return unique set of values from categorical data
    try {
      return data[dataset].getAllCats(attr);
    } catch (e) {
      delv.log("getAllCats received exception: " + e);
      return [];
    }
  };
  delv.getCatColor = function(dataset, attr, cat) {
    // return color for one category of categorical data
    try {
      return data[dataset].getCatColor(attr, cat);
    } catch (e) {
      delv.log("getCatColor received exception: " + e);
      return {};
    }
  };
  delv.getCatColors = function(dataset, attr) {
    // return unique set of values from categorical data
    try {
      return data[dataset].getCatColors(attr);
    } catch (e) {
      delv.log("getCatColors received exception: " + e);
      return [];
    }
  };

  delv.getFilterCatColors = function(dataset, attr) {
    try {
      return data[dataset].getFilterCatColors(attr);
    } catch (e) {
      delv.log("getFilterCatColors received exception: " + e);
      return [];
    }
  };

  delv.getCatEncoding = function(dataset, attr, cat) {
    // return encoding for one category of categorical data
    try {
      return data[dataset].getCatEncoding(attr, cat);
    } catch (e) {
      delv.log("getCatEncoding received exception: " + e);
      return {};
    }
  };
  delv.getCatEncodings = function(dataset, attr) {
    // return unique set of values from categorical data
    try {
      return data[dataset].getCatEncodings(attr);
    } catch (e) {
      delv.log("getCatEncodings received exception: " + e);
      return [];
    }
  };

  delv.clearItems = function(dataset) {
    if (data.hasOwnProperty(dataset)) {
      data[dataset].clearItems();
    }
  };
  delv.setItem = function(dataset, attr, id, item) {
    if (data.hasOwnProperty(dataset)) {
      data[dataset].setItem(attr, id, item);
    }
  };

  delv.getItem = function(dataset, attr, id) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getItem(attr, id);
    } else {
      return "";
    }
  };

  delv.getItemAsFloat = function(dataset, attr, id) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getItemAsFloat(attr, id);
    } else {
      return null;
    }
  };

  // TODO add get/set FloatArray / StringArray methods
  
  delv.getAllItems = function(dataset, attr) {
    try {
      return data[dataset].getAllItems(attr);
    } catch (e) {
      delv.log("getAllItems(" + dataset + ", " + attr + ") caught exception: " + e);
      return [];
    }
  };

  delv.getAllItemsAsFloat = function(dataset, attr) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getAllItemsAsFloat(attr);
    } else {
      return [];
    }
  };

  delv.getHoverItems = function(dataset, attr) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getHoverItems(attr);
    } else {
      return [];
    }
  };

  delv.getSelectItems = function(dataset, attr, selectType) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getSelectItems(attr, selectType);
    } else {
      return [];
    }
  };

  delv.getFilterItems = function(dataset, attr) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getFilterItems(attr);
    } else {
      return [];
    }
  };

  delv.getNavItems = function(dataset, attr) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getNavItems(attr);
    } else {
      return [];
    }
  };

  // get color of item or items, applying precedence rules (highest to lowest precedence):
  // hover color, select color, like color, filter color, attribute color
  delv.getItemColor = function(dataset, attr, id) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getItemColor(attr, id);
    } else {
      return [];
    }
  };

  delv.getItemColors = function(dataset, attr) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getItemColors(attr);
    } else {
      return [];
    }
  };

  delv.getItemEncoding = function(dataset, attr, id) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getItemEncoding(attr, id);
    } else {
      return [];
    }
  };

  delv.getItemEncodings = function(dataset, attr) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getItemEncodings(attr);
    } else {
      return [];
    }
  };

  // get color of item or items based on attribute color map, ignoring any selection-based coloring
  delv.getItemAttrColor = function(dataset, attr, id) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getItemAttrColor(attr, id);
    } else {
      return [];
    }
  };

  delv.getItemAttrColors = function(dataset, attr) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getItemAttrColors(attr);
    } else {
      return [];
    }
  };

  delv.getItemAttrEncoding = function(dataset, attr, id) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getItemAttrEncoding(attr, id);
    } else {
      return [];
    }
  };

  delv.getItemAttrEncodings = function(dataset, attr) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getItemAttrEncodings(attr);
    } else {
      return [];
    }
  };

  delv.getAllIds = function(dataset, attr) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getAllIds(attr);
    } else {
      return [];
    }
  };
  delv.getAllCoords = function(dataset, attr) {
    if (data.hasOwnProperty(dataset)) {
      return data[dataset].getAllCoords(attr);
    } else {
      return [];
    }
  };
  delv.hasId = function(dataset, id) {
    return data[dataset].hasId(id);
  };
  delv.hasCoord = function(dataset, coord) {
    return data[dataset].hasCoord(coord);
  };


  // TODO sort API

  // TODO transform API

  // TODO aggregate API

  delv.hoverItem = function(invoker, dataset, id) {
    try {
      data[dataset].hoverItem(id);
      delv.emitSignal('hoverChanged', invoker, dataset, "ITEM");
    } catch (e) {
      return;
    }
  };

  delv.hoverCat = function(invoker, dataset, attr, cat) {
    try {
      data[dataset].hoverCat(attr, cat);
      delv.emitSignal('hoverChanged', invoker, dataset, "CAT");
    } catch (e) {
      return;
    }
  };
  delv.hoverRange = function(invoker, dataset, attr, minVal, maxVal) {
    try {
      data[dataset].hoverRange(attr, minVal, maxVal);
      delv.emitSignal('hoverChanged', invoker, dataset, "RANGE");
    } catch (e) {
      return;
    }
  };
  delv.hoverLike = function(invoker, dataset, id, relationship) {
    try {
      data[dataset].hoverLike(id, relationship);
      delv.emitSignal('hoverChanged', invoker, dataset, "LIKE");
    } catch (e) {
      return;
    }
  };

  delv.validateSelectType = function(selectType) {
    // for now though, allow any select type, if empty, default to primary
    if (selectType === "") {
      return "PRIMARY";
    } else {
      return selectType.toUpperCase();
    }
  };

  // TODO implement deselection
  
  delv.selectItems = function(invoker, dataset, ids, selectType) {
    try {
      data[dataset].selectItems(ids, selectType);
      delv.emitSignal('selectChanged', invoker, dataset, "ITEM", selectType);
    } catch (e) {
      return;
    }
  };
  delv.selectCats = function(invoker, dataset, attrs, cats, selectType) {
    try {
      data[dataset].selectCats(attrs, cats, selectType);
      delv.emitSignal('selectChanged', invoker, dataset, "CAT", selectType);
    } catch (e) {
      return;
    }
  };
  delv.selectRanges = function(invoker, dataset, attrs, mins, maxes, selectType) {
    try {
      data[dataset].selectRanges(attrs, mins, maxes, selectType);
      
    }
  };
  delv.selectCats = function(invoker, dataset, attrs, cats, selectType) {
    try {
      data[dataset].selectCats(attrs, cats, selectType);
      delv.emitSignal('selectChanged', invoker, dataset, "CAT", selectType);
    } catch (e) {
      return;
    }
  };
  delv.selectRanges = function(invoker, dataset, attrs, mins, maxes, selectType) {
    try {
      data[dataset].selectRanges(attrs, mins, maxes, selectType);
      
    }
  };
  delv.selectCats = function(invoker, dataset, attrs, cats, selectType) {
    try {
      data[dataset].selectCats(attrs, cats, selectType);
      delv.emitSignal('selectChanged', invoker, dataset, "CAT", selectType);
    } catch (e) {
      return;
    }
  };
  delv.selectRanges = function(invoker, dataset, attrs, mins, maxes, selectType) {
    try {
      data[dataset].selectRanges(attrs, mins, maxes, selectType);
      delv.emitSignal('selectChanged', invoker, dataset, "RANGE", selectType);
    } catch (e) {
      return;
    }
  };
  delv.selectLike = function(invoker, dataset, ids, relationships, selectType) {
    try {
      data[dataset].selectLike(ids, relationships, selectType);
      delv.emitSignal('selectChanged', invoker, dataset, "LIKE", selectType);
    } catch (e) {
      return;
    }
  };

  delv.clearSelect = function(invoker, dataset, selectType) {
    try {
      data[dataset].clearSelect(selectType);
      delv.emitSignal('selectChanged', invoker, dataset, "CLEAR", selectType);
    } catch (e) {
      return;
    }
  };

  delv.filterCats = function(invoker, dataset, attr, cats) {
    try {
      data[dataset].filterCats(attr, cats);
      delv.emitSignal('filterChanged', invoker, dataset, "CAT");
    } catch (e) {
      return;
    }
  };
  delv.toggleCatFilter = function(invoker, dataset, attr, cat) {
    try {
      data[dataset].toggleCatFilter(attr, cat);
      delv.emitSignal('filterChanged', invoker, dataset, "CAT");
    } catch (e) {
      return;
    }
  };
  delv.filterRanges = function(invoker, dataset, attr, mins, maxes) {
    try {
      data[dataset].filterRanges(attr, mins maxes);
      delv.emitSignal('filterChanged', invoker, dataset, "RANGE");
    } catch (e) {
      return;
    }
  };
  delv.filterLike = function(invoker, dataset, ids, relationships) {
    try {
      data[dataset].filterLike(ids, relationships);
      delv.emitSignal('filterChanged', invoker, dataset, "LIKE");
    } catch (e) {
      return;
    }
  };
  delv.clearFilter = function(invoker, dataset) {
    try {
      data[dataset].clearFilter();
      delv.emitSignal('filterChanged', invoker, dataset, "CLEAR");
    } catch (e) {
      return;
    }
  };

  delv.colorCat = function(invoker, dataset, attr, cat, rgbaColor) {
    try {
      if (rgbaColor) {
        data[dataset].colorCat(attr, cat, rgbaColor);
        delv.emitSignal('colorChanged', invoker, dataset, attr);
      }
    } catch (e) {
      return;
    }
  };
  delv.encodeCat = function(invoker, dataset, attr, cat, encoding) {
    try {
      if (encoding) {
        data[dataset].encodeCat(attr, cat, encoding);
        delv.emitSignal('encodingChanged', invoker, dataset, attr);
      }
    } catch (e) {
      return;
    }
  };

  // TODO navItem, navVal, navCat, navRange, navLike, clearNav
  // TODO panItem, panVal, panCat, panRange, panLike
  // TODO zoomItem, zoomVal, zoomCat, zoomRange, zoomLike
  // TODO setLOD

  delv.getHoverIds = function(dataset) {
    try {
      return data[dataset].getHoverIds();
    } catch (e) {
      return;
    }
  };
  delv.getHoverCoords = function(dataset) {
    try {
      return data[dataset].getHoverCoords();
    } catch (e) {
      return;
    }
  };
  delv.getHoverCat = function(dataset, attr) {
    try {
      return data[dataset].getHoverCat(attr);
    } catch (e) {
      return;
    }
  };
  delv.getHoverRange = function(dataset, attr) {
    try {
      return data[dataset].getHoverRange(attr);
    } catch (e) {
      return;
    }
  };
  delv.getHoverLike = function(dataset) {
    try {
      return data[dataset].getHoverLike();
    } catch (e) {
      return;
    }
  };
  delv.getSelectIds = function(dataset, selectType) {
    try {
      return data[dataset].getSelectIds(selectType);
    } catch (e) {
      return;
    }
  };
  delv.getSelectCoords = function(dataset, selectType) {
    try {
      return data[dataset].getSelectCoords(selectType);
    } catch (e) {
      return;
    }
  };
  delv.getSelectCats = function(dataset, attr, selectType) {
    try {
      return data[dataset].getSelectCats(attr, selectType);
    } catch (e) {
      return;
    }
  };
  delv.getSelectRanges = function(dataset, attr, selectType) {
    try {
      return data[dataset].getSelectRanges(attr, selectType);
    } catch (e) {
      return;
    }
  };
  delv.getSelectLike = function(dataset, selectType) {
    try {
      return data[dataset].getSelectLike();
    } catch (e) {
      return;
    }
  };
  delv.getSelectCriteria = function(dataset, selectType) {
    try {
      return data[dataset].getSelectCriteria();
    } catch (e) {
      return;
    }
  };
  delv.getFilterIds = function(dataset) {
    try {
      return data[dataset].getFilterIds();
    } catch (e) {
      return;
    }
  };
  delv.getFilterCoords = function(dataset) {
    try {
      return data[dataset].getFilterCoords();
    } catch (e) {
      return;
    }
  };
  delv.getFilterCats = function(dataset, attr) {
    try {
      return data[dataset].getFilterCats(attr);
    } catch (e) {
      return;
    }
  };
  delv.getFilterRanges = function(dataset, attr) {
    try {
      return data[dataset].getFilterRanges(attr);
    } catch (e) {
      return;
    }
  };
  delv.getFilterLike = function(dataset) {
    try {
      return data[dataset].getFilterLike();
    } catch (e) {
      return;
    }
  };
  delv.getFilterCriteria = function(dataset) {
    try {
      return data[dataset].getFilterCriteria();
    } catch (e) {
      return;
    }
  };

  // TODO getNav info
  // TODO getLOD
   
   


  delv.getAllCatColorMaps = function(dataset, attr) {
    // return unique set of values from categorical data
    try {
      return data[dataset].getAllCatColorMaps(attr);
    } catch (e) {
      delv.log("getAllCatColorMaps received exception: " + e);
      return [];
    }
  };

  delv.getMin = function(dataset, attr) {
    try {
      return data[dataset].getMin(attr);
    } catch (e) {
      delv.log("getMin received exception: " + e);
      return {};
    }
  };
  delv.getMax = function(dataset, attr) {
    try {
      return data[dataset].getMax(attr);
    } catch (e) {
      delv.log("getMax received exception: " + e);
      return {};
    }
  };


  delv.hoverColor = function(invoker, dataset, rgbaColor) {
    if (delv.hasDataSet(dataset)) {
      data[dataset].hoverColor(rgbaColor);
      delv.emitSignal('hoverColorChanged', invoker, dataset);
    } else {
      _hoverColor = rgbaColor;
      _hoverColorSet = true;
      for (ds in data) {
        if (data.hasOwnProperty(ds)) {
          data[ds].hoverColor(rgbaColor);
          delv.emitSignal('hoverColorChanged', invoker, ds);
        }
      }
    }
  };
  delv.selectColor = function(invoker, dataset, rgbaColor, selectType) {
    if (delv.hasDataSet(dataset)) {
      data[dataset].selectColor(rgbaColor, selectType);
      delv.emitSignal('selectColorChanged', invoker, dataset, selectType);
    } else {
      _selectColor[selectType] = rgbaColor;
      _selectColorSet[selectType] = true;
      for (ds in data) {
        if (data.hasOwnProperty(ds)) {
          data[ds].selectColor(rgbaColor, selectType);
          delv.emitSignal('selectColorChanged', invoker, ds, selectType);
        }
      }
    }
  };
  delv.filterColor = function(invoker, dataset, rgbaColor) {
    if (delv.hasDataSet(dataset)) {
      data[dataset].filterColor(rgbaColor);
      delv.emitSignal('filterColorChanged', invoker, dataset);
    } else {
      _filterColor = rgbaColor;
      _filterColorSet = true;
      for (ds in data) {
        if (data.hasOwnProperty(ds)) {
          data[ds].filterColor(rgbaColor);
          delv.emitSignal('filterColorChanged', invoker, ds);
        }
      }
    }
  };
  delv.likeColor = function(invoker, dataset, rgbaColor) {
    if (delv.hasDataSet(dataset)) {
      data[dataset].likeColor(rgbaColor);
      delv.emitSignal('likeColorChanged', invoker, dataset);
    } else {
      _likeColor = rgbaColor;
      _likeColorSet = true;
      for (ds in data) {
        if (data.hasOwnProperty(ds)) {
          data[ds].likeColor(rgbaColor);
          delv.emitSignal('likeColorChanged', invoker, ds);
        }
      }
    }
  };
  delv.clearHoverColor = function(invoker, dataset) {
    if (delv.hasDataSet(dataset)) {
      data[dataset].clearHoverColor();
      delv.emitSignal('hoverColorChanged', invoker, dataset);
    } else {
      _hoverColorSet = false;
      for (ds in data) {
        if (data.hasOwnProperty(ds)) {
          data[ds].clearHoverColor();
          delv.emitSignal('hoverColorChanged', invoker, ds);
        }
      }
    }
  };
  delv.clearSelectColor = function(invoker, dataset, selectType) {
    if (delv.hasDataSet(dataset)) {
      data[dataset].clearSelectColor(selectType);
      delv.emitSignal('selectColorChanged', invoker, dataset, selectType);
    } else {
      _selectColorSet[selectType] = false;
      for (ds in data) {
        if (data.hasOwnProperty(ds)) {
          data[ds].clearSelectColor(selectType);
          delv.emitSignal('selectColorChanged', invoker, ds, selectType);
        }
      }
    }
  };
  delv.clearFilterColor = function(invoker, dataset) {
    if (delv.hasDataSet(dataset)) {
      data[dataset].clearFilterColor();
      delv.emitSignal('filterColorChanged', invoker, dataset);
    } else {
      _filterColorSet = false;
      for (ds in data) {
        if (data.hasOwnProperty(ds)) {
          data[ds].clearFilterColor();
          delv.emitSignal('filterColorChanged', invoker, ds);
        }
      }
    }
  };
  delv.clearLikeColor = function(invoker, dataset) {
    if (delv.hasDataSet(dataset)) {
      data[dataset].clearLikeColor();
      delv.emitSignal('likeColorChanged', invoker, dataset);
    } else {
      _likeColorSet = false;
      for (ds in data) {
        if (data.hasOwnProperty(ds)) {
          data[ds].clearLikeColor();
          delv.emitSignal('likeColorChanged', invoker, ds);
        }
      }
    }
  };

  delv.isHoverColorSet = function(dataset) {
    if (delv.hasDataSet(dataset)) {
      return data[dataset].isHoverColorSet();
    } else {
      return _hoverColorSet;
    }
  };
  delv.getHoverColor = function(dataset) {
    if (delv.hasDataSet(dataset)) {
      col = data[dataset].getHoverColor();
      if (col.length < 1) {
        return _hoverColor;
      } else {
        return col;
      }
    } else {
      return _hoverColor;
    }
  };
  delv.isSelectColorSet = function(dataset, selectType) {
    if (delv.hasDataSet(dataset)) {
      return data[dataset].isSelectColorSet(selectType);
    } else {
      return _selectColorSet[selectType];
    }
  };
  delv.getSelectColor = function(dataset, selectType) {
    if (delv.hasDataSet(dataset)) {
      col = data[dataset].getSelectColor(selectType);
      if (col.length < 1) {
        return _selectColor[selectType];
      } else {
        return col;
      }
    } else {
      return _selectColor[selectType];
    }
  };  
  delv.isFilterColorSet = function(dataset) {
    if (delv.hasDataSet(dataset)) {
      return data[dataset].isFilterColorSet();
    } else {
      return _filterColorSet;
    }
  };
  delv.getFilterColor = function(dataset) {
    if (delv.hasDataSet(dataset)) {
      col = data[dataset].getFilterColor();
      if (col.length < 1) {
        return _filterColor;
      } else {
        return col;
      }
    } else {
      return _filterColor;
    }
  };
  delv.isLikeColorSet = function(dataset) {
    if (delv.hasDataSet(dataset)) {
      return data[dataset].isLikeColorSet();
    } else {
      return _likeColorSet;
    }
  };
  delv.getLikeColor = function(dataset) {
    if (delv.hasDataSet(dataset)) {
      col = data[dataset].getLikeColor();
      if (col.length < 1) {
        return _likeColor;
      } else {
        return col;
      }
    } else {
      return _likeColor;
    }
  };

  delv.dataSet = function(name) {
    // TODO set colors via css
    var itemIds = [];
    var attributes = {};
    var _defaultEncoding = [];
    var _defaultColor = [];
    var _hoverColor = [];
    var _selectColor = {};
    var _filterColor = [];
    var _likeColor = [];
    var _defaultEncodingSet = false;
    var _hoverColorSet = false;
    var _selectColorSet = {"PRIMARY": false, "SECONDARY": false, "TERTIARY": false};
    var _filterColorSet = false;
    var _likeColorSet = false;
    var _hoverId = [];
    var _hoverRange = new delv.pair("",{});
    var _selectRanges = {"PRIMARY": [], "SECONDARY": [], "TERTIARY": []};
    var _filterRanges = {};

    this.name = name;

    // TODO sort API
    // TODO transform API
    // TODO aggregate API

    this.getIdx = function(id) {
      var i = -1;
      var val = delv.coordToId(id);
      for (i = 0; i < itemIds.length; i++) {
        if (itemIds[i].name === val) {
          return i;
        }
      }
      return i;
    };
    
    this.addId = function(id) {
      var newId = new delv.itemId(id);
      itemIds[itemIds.length] = newId;
    };
    this.hasId = function(id) {
      var i = getIdx(id);
      return (i > -1);
    };
    this.addCoord = function(coord) {
      var newCoord = new delv.itemId(coord);
      itemCoords[itemCoords.length] = newCoord;
    };
    this.hasCoord = function(coord) {
      var i = getIdx(id);
      return (i > -1);
    };

    this.getAllIds = function(attr) {
      // TODO depending on how missing values are handled, returned ids may need to be adjusted
      var ids = [];
      var i;
      for (i = 0; i < itemIds.length; i++) {
        ids[ids.length] = itemIds[i].name;
      }
      return ids;
    };

    this.getAllCoords = function(attr) {
      // TODO depending on how missing values are handled, returned ids may need to be adjusted
      var ids = [];
      var i;
      for (i = 0; i < itemIds.length; i++) {
        ids[ids.length] = delv.idToCoord(itemIds[i].name);
      }
      return ids;
    };

    this.getHoverIds = function() {
      var ids = [];
      var i;
      for (i = 0; i < itemIds.length; i++) {
        if (itemIds[i].hovered) {
          ids[ids.length] = itemIds[i].name;
        }
      }
      return ids;
    };
    this.getHoverCoords = function() {
      var coords = [];
      var i;
      for (i = 0; i < itemIds.length; i++) {
        if (itemIds[i].hovered) {
          coords[coords.length] = delv.idToCoord(itemIds[i].name);
        }
      }
      return ids;
    };

    this.getSelectIds = function(selectType) {
      var ids = [];
      switch (selectType) {
      case "PRIMARY":
        ids = this.getPrimaryIds();
        break;
      case "SECONDARY":
        ids = this.getSecondaryIds();
        break;
      case "TERTIARY":
        ids = this.getTertiaryIds();
        break;
      default:
        break;
      }
      return ids;
    };

    this.getPrimaryIds = function() {
      var ids = [];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.selectedPrimary) {
          ids[ids.length] = id.name;
        }
      }
      return ids;
    };
    this.getSecondaryIds = function() {
      var ids = [];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.selectedSecondary) {
          ids[ids.length] = id.name;
        }
      }
      return ids;
    };
    this.getTertiaryIds = function() {
      var ids = [];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.selectedTertiary) {
          ids[ids.length] = id.name;
        }
      }
      return ids;
    };

    this.getSelectCoords = function(selectType) {
      var coords = [];
      switch (selectType) {
      case "PRIMARY":
        coords = this.getPrimaryCoords();
        break;
      case "SECONDARY":
        coords = this.getSecondaryCoords();
        break;
      case "TERTIARY":
        coords = this.getTertiaryCoords();
        break;
      default:
        break;
      }
      return coords;
    };

    this.getPrimaryCoords = function() {
      var coords = [];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.selectedPrimary) {
          coords[coords.length] = delv.idToCoord(id.name);
        }
      }
      return coords;
    };
    this.getSecondaryCoords = function() {
      var coords = [];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.selectedSecondary) {
          coords[coords.length] = delv.idToCoord(id.name);
        }
      }
      return coords;
    };
    this.getTertiaryCoords = function() {
      var coords = [];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.selectedTertiary) {
          coords[coords.length] = delv.idToCoord(id.name);
        }
      }
      return coords;
    };

    this.getFilterIds = function() {
      var ids = [];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.filtered) {
          ids[ids.length] = id.name;
        }
      }
      return ids;
    };

    this.getFilterCoords = function() {
      var coords = [];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.filtered) {
          coords[coords.length] = delv.idToCoord(id.name);
        }
      }
      return coords;
    };

    // TODO implement get Nav info

    this.getNumIds = function() {
      return itemIds.length;
    };
    this.getNumCoords = function() {
      return itemIds.length;
    };


    this.removeId = function(id) {
      var i = getIdx(id);
      if (i > -1) {
        itemIds.splice(i, 1);
      }
    };

    this.removeCoord = function(coord) {
      var i = getIdx(coord);
      if (i > -1) {
        itemIds.splice(i, 1);
      }
    };

    this.clearItems = function() {
      for (attr in attributes) {
        if (attributes.hasOwnProperty(attr)) {
          attributes[attr].clear();
        }
      }
      itemIds = [];
    };

    this.setItem = function(attr, id, item) {
      var at = attributes[attr];
      if (at !== undefined) {
        if (!this.hasId(id)) {
          this.addId(id);
        }
        at.setItem(id, item);
      }
    };

    // TODO add setFloat, setFloatArray, setStringArray etc

    this.getItem = function(attr, id) {
      var at = attributes[attr];
      if (at !== undefined) {
        return at.getItem(id);
      } else {
        return "";
      }
    };

    this.getItemAsFloat = function(attr, id) {
      var at = attributes[attr];
      if (at !== undefined) {
        return at.getItemAsFloat(id);
      } else {
        return {};
      }
    };

    // TODO add getItemAsFloatArray asStringArray etc

    this.getAllItems = function(attr) {
      var items = [];
      var i;
      var at = attributes[attr];
      if (at !== undefined) {
        for (i = 0; i < itemIds.length; i++) {
          items[i] = at.getItem(itemIds[i].name);
        }
      }
      return items;
    };

    this.getAllItemsAsFloat = function(attr) {
      // TODO better to handle here, to keep order uniform based on ids?
      var items = [];
      var i;
      var at = attributes[attr];
      if (at !== undefined) {
        for (i = 0; i < itemIds.length; i++) {
          items[i] = at.getItemAsFloat(itemIds[i].name);
        }
      }
      return items;
    };

    this.getMin = function(attr) {
      var at = attributes[attr];
      if (at !== undefined) {
        return at.getMin();
      } else {
        return "";
      }
    };
    this.getMax = function(attr) {
      var at = attributes[attr];
      if (at !== undefined) {
        return at.getMax();
      } else {
        return "";
      }
    };


    this.getHoverItems = function(attr) {
      var hovered = [];
      var i;
      var at = attributes[attr];
      if (at !== undefined) {
        for (i = 0; i < itemIds.length; i++) {
          if (itemIds[i].hovered) {
            hovered[hovered.length] = at.getItem(itemIds[i].name);
          }
        }
      }
      return hovered;
    };

    this.getSelectItems = function(attr, selectType) {
      var ids = this.getSelectIds(selectType);
      var items = [];
      var i;
      var at = attributes[attr];
      if (at !== undefined) {
        for (i = 0; i < ids.length; i++) {
          items[i] = at.getItem(ids[i]);
        }
      }
      return items;
    };

    this.getFilterItems = function(attr) {
      var items = [];
      var i;
      var id;
      var at = attributes[attr];
      if (at !== undefined) {
        for (i = 0; i < itemIds.length; i++) {
          id = itemIds[i];
          if (id.filtered) {
            items[items.length] = at.getItem(id.name);
          }
        }
      }
      return items;
    };

    // TODO get nav items

    this.getItemColor = function(attr, id) {
      var idx = getIdx(id);
      var item;
      if (idx > -1) {
        return getItemColorByIdx(attr, idx);
      }
      // item not found
      return _defaultColor;
    };
    this.getItemColorByIdx = function(attr, idx) {
      var item;
      item = itemIds[idx];
      if (item.hovered && _hoverColorSet) {
        return _hoverColor;
      } else if (item.selectedPrimary && _selectColorSet["PRIMARY"]) {
        return _selectColors["PRIMARY"];
      } else if (item.selectedSecondary && _selectColorSet["SECONDARY"]) {
        return _selectColors["SECONDARY"];
      } else if (item.selectedTertiary && _selectColorSet["TERTIARY"]) {
        return _selectColors["TERTIARY"];
      } else if (item.filtered && _filterColorSet) {
        return _filterColor;
      } else if (item.navigated && _likeColorSet) {
        // TODO mismatch between navigation and like here!!! 
        return _likeColor;
      } else {
        return getItemAttrColor(attr, id);
      }
    };

    this.getItemColors = function(attr) {
      var idx;
      var cols = [];
      for (idx = 0; idx < itemIds.length; idx++) {
        cols[idx] = getItemColorByIdx(attr, idx);
      }
      return cols;
    };

    this.getItemAttrColor = function(attr, id) {
      var at = attributes[attr];
      if (at !== undefined) {
        return at.getItemAttrColor(id);
      } else {
        return _defaultColor;
      }
    };

    this.getItemAttrColors = function(attr) {
      var i;
      var colors = [];
      var at = attributes[attr];
      if (at !== undefined) {
        for (i = 0; i < itemIds.length; i++) {
          colors[i] = at.getItemAttrColor(itemIds[i].name);
        }
      }
      return colors;
    };

    this.hoverItem = function(id) {
      var idx = getIdx(id);
      clearHover();
      if (idx > -1) {
        itemIds[idx].hovered = true;
      }
      _hoverCoords = delv.idToCoord(id);
    };


    this.selectPrimaryItems = function(ids, doSelect) {
      var range = new delv.categoricalRange();
      var i;
      var idx;
      var selectMap = {};
      var ranges = selectRanges["PRIMARY"];
      for (i = 0; i < ids.length; i++) {
        idx = getIdx(ids[i]);
        if (idx > -1) {
          itemIds[idx].selectedPrimary = doSelect;
          range.addCategory(ids[i]);
        }
      }
      selectMap["__id__"] = range;
      _selectRanges["PRIMARY"][ranges.length] = selectMap;
    };
    this.selectSecondaryItems = function(ids, doSelect) {
      var range = new delv.categoricalRange();
      var i;
      var idx;
      var selectMap = {};
      var ranges = selectRanges["SECONDARY"];
      for (i = 0; i < ids.length; i++) {
        idx = getIdx(ids[i]);
        if (idx > -1) {
          itemIds[idx].selectedSecondary = doSelect;
          range.addCategory(ids[i]);
        }
      }
      selectMap["__id__"] = range;
      _selectRanges["SECONDARY"][ranges.length] = selectMap;
    };
    this.selectTertiaryItems = function(ids, doSelect) {
      var range = new delv.categoricalRange();
      var i;
      var idx;
      var selectMap = {};
      var ranges = selectRanges["TERTIARY"];
      for (i = 0; i < ids.length; i++) {
        idx = getIdx(ids[i]);
        if (idx > -1) {
          itemIds[idx].selectedTertiary = doSelect;
          range.addCategory(ids[i]);
        }
      }
      selectMap["__id__"] = range;
      _selectRanges["TERTIARY"][ranges.length] = selectMap;
    };

    this.selectItems = function(ids, selectType) {
      switch (selectType) {
      case "PRIMARY":
        this.selectPrimaryItems(ids, true);
        break;
      case "SECONDARY":
        this.selectSecondaryItems(ids, true);
        break;
      case "TERTIARY":
        this.selectTertiaryItems(ids, true);
        break;
      default:
        break;
      }
    };

    // TODO change clearAttributes to clearAttrs
    this.clearAttributes = function() {
      attributes={};
    };
      
    this.addAttr = function(attr) {
      attributes[attr.name] = attr;
    };

    this.hasAttr = function(attr) {
      return attributes.hasOwnProperty(attr);
    };

    this.getAttrs = function() {
      var keys = [];
      var attr;
      for (attr in attributes) {
        if (attributes.hasOwnProperty(attr)) {
          keys[keys.length] = attr;
        }
      }
      return keys;
    };

    // TODO establish consistency in checking whether an attribute exists
    this.getAllCats = function(attr) {
      var at = attributes[attr];
      if (at !== undefined) {
        return at.getAllCats();
      } else {
        return [];
      }
    };

    this.getCatColor = function(attr, cat) {
      var at = attributes[attr];
      if (at !== undefined) {
        return at.getCatColor(cat);
      } else {
        return [];
      }
    };

    this.getAllCatColors = function(attr) {
      var at = attributes[attr];
      if (at !== undefined) {
        return at.getAllCatColors();
      } else {
        return [];
      }
    };
    
    this.getFilterCatColors = function(attr) {
      var at = attributes[attr];
      var cats;
      var colors = [];
      var i;
      if (at !== undefined) {
        cats = getFilterCats(attr);
        for (i = 0; i < cats.length; cat++) {
          colors[i] = at.getCatColor(cats[i]);
        }
      }
      return colors;
    };

    this.hoverCat = function(attr, cat) {
      var at = attributes[attr];
      var range;
      clearHover();
      if (at !== undefined) {
        if (at.isCategorical()) {
          range = new delv.categoricalRange();
          range.addCategory(cat);
        } else {
          range = delv.continuousRange();
          range.update(parseFloat(cat));
        }
        _hoverRange.set(attr, range);
        determineHoveredItems();
      } else {
        range = new delv.continuousRange();
        _hoverRange.set("", range);
      }
    };

    this.hoverRange = function(attr, minVal, maxVal) {
      var at = attributes[attr];
      var range;
      clearHover();
      if (at !== undefined) {
        range = delv.continuousRange();
        range.setMin(parseFloat(minVal));
        range.setMax(parseFloat(maxVal));
        _hoverRange.set(attr, range);
        determineHoveredItems();
      } else {
        range = new delv.continuousRange();
        _hoverRange.set("", range);
      }
    };

    this.selectCats = function(attrs, cats, selectType) {
      var selectList = _selectRanges[selectType];
      var selectMap = {};
      var range = {};
      var i;
      var at;
      for (i = 0; i < attrs.length; i++) {
        at = attributes[attrs[i]];
        if (at !== undefined) {
          range = selectMap[attrs[i]];
          if (at.isCategorical()) {
            if (range !== undefined) {
              range = new delv.categoricalRange();
            }
            range.addCategory(cats[i]);
          } else {
            if (range !== undefined) {
              range = new delv.continuousRange();
            }
            range.update(parseFloat(cats[i]));
          }
          selectMap[attrs[i]] = range;
        }
      }
      selectList[selectList.length] = selectMap;
      determineSelectedItems(selectType);
    };

    this.selectRanges = function(attrs, mins, maxes, selectType) {
      var selectList = _selectRanges[selectType];
      var selectMap = {};
      var range = new delv.continuousRange();
      var i;
      var at;
      for (i = 0; i < attrs.length; i++) {
        at = attributes[attrs[i]];
        if (at !== undefined) {
          range = selectMap[attrs[i]];
          if (range === undefined) {
            range = new delv.continuousRange();
          }
          range.setMin(parseFloat(mins[i]));
          range.setMax(parseFloat(maxes[i]));
          selectMap[attrs[i]] = range;
        }
      }
      selectList[selectList.length] = selectMap;
      determineSelectedItems(selectType);
    };
    
    this.filterCats = function(attr, cats) {
      var at = attributes[attr];
      var ranges = [];
      var range;
      var i;
      if (at !== undefined) {
        if (at.isCategorical()) {
          at.filterNone();
        }
        for (i = 0; i < cats.length; i++) {
          if (at.isCategorical()) {
            at.toggleCatFilter(cats[i]);
          } else {
            range = new delv.continuousRange();
            range.update(parseFloat(cats[i]));
            ranges[ranges.length] = range;
          }
        }
        _filterRanges[attr] = ranges;
        determineFilteredItems();
      }
    };

    this.toggleCatFilter = function(attr, cat) {
      var at = attributes[attr];
      if (at !== undefined && at.isCategorical()) {
        at.toggleCatFilter(cat);
        _filterRanges[attr] = [];
        determineFilteredItems();
      }
    };

    this.filterRanges = function(attr, mins, maxes) {
      var at = attributes[attr];
      var ranges = [];
      var range;
      var i;
      if (at !== undefined) {
        for (i = 0; i < mins.length; i++) {
          range = new delv.continuousRange();
          range.updateMin(parseFloat(mins[i]));
          range.updateMax(parseFloat(maxes[i]));
          ranges[ranges.length] = range;
        }
        _filterRanges[attr] = ranges;
        determineFilteredItems();
      }
    };

    this.colorCat = function(attr, cat, rgbaColor) {
      var at = attributes[attr];
      if (at !== undefined) {
        at.colorCat(cat, rgbaColor);
      }
    };

    this.determineHoveredItems = function() {
      var at;
      var range;
      var id;
      if (_hoverRange.first !== "") {
        at = attributes[_hoverRange.first];
        if (at !== undefined) {
          range = _hoverRange.second;
          if (range !== undefined) {
            for (id = 0; id < itemIds.length; id++) {
              if (range.isInRange(at.getItem(itemIds[id].name))) {
                itemIds[id].hovered = true;
              } else {
                itemIds[id].hovered = false;
              }
            }
          }
        }
      }
    };

    this.determineSelectedItems = function(selectType) {
      switch (selectType) {
      case "PRIMARY":
        determinePrimarySelection(_selectRanges[selectType]);
        break;
      case "SECONDARY":
        determineSecondarySelection(_selectRanges[selectType]);
        break;
      case "TERTIARY":
        determineTertiarySelection(_selectRanges[selectType]);
        break;
      default:
        break;
      }
    };

    this.determinePrimarySelection = function(selectList) {
      var id;
      var smap;
      var selectMap;
      var attr;
      var at;
      var range;
      var select;
      for (id = 0; id < itemIds.length; id++) {
        for (smap = 0; smap < selectList.length; smap++) {
          select = true;
          selectMap = selectList[smap];
          // to be selected by this expression, must be true for all attributes in this map (AND)
          for (attr in selectMap) {
            if (selectMap.hasOwnProperty(attr)) {
              at = attributes[attr];
              if (at !== undefined) {
                range = selectMap[attr];
                if (range !== undefined && !range.isInRange(at.getItem(itemIds[id].name))) {
                  select = false;
                  break;
                }
              }
            }
          }
          // to be selected, OR the above result with the previous selection state for this item
          if (select) {
            itemIds[id].selectedPrimary = true;
          }
        }
      }
    };
    this.determineSecondarySelection = function(selectList) {
      var id;
      var smap;
      var selectMap;
      var attr;
      var at;
      var range;
      var select;
      for (id = 0; id < itemIds.length; id++) {
        for (smap = 0; smap < selectList.length; smap++) {
          select = true;
          selectMap = selectList[smap];
          // to be selected by this expression, must be true for all attributes in this map (AND)
          for (attr in selectMap) {
            if (selectMap.hasOwnProperty(attr)) {
              at = attributes[attr];
              if (at !== undefined) {
                range = selectMap[attr];
                if (range !== undefined && !range.isInRange(at.getItem(itemIds[id].name))) {
                  select = false;
                  break;
                }
              }
            }
          }
          // to be selected, OR the above result with the previous selection state for this item
          if (select) {
            itemIds[id].selectedSecondary = true;
          }
        }
      }
    };
    this.determineTertiarySelection = function(selectList) {
      var id;
      var smap;
      var selectMap;
      var attr;
      var at;
      var range;
      var select;
      for (id = 0; id < itemIds.length; id++) {
        for (smap = 0; smap < selectList.length; smap++) {
          select = true;
          selectMap = selectList[smap];
          // to be selected by this expression, must be true for all attributes in this map (AND)
          for (attr in selectMap) {
            if (selectMap.hasOwnProperty(attr)) {
              at = attributes[attr];
              if (at !== undefined) {
                range = selectMap[attr];
                if (range !== undefined && !range.isInRange(at.getItem(itemIds[id].name))) {
                  select = false;
                  break;
                }
              }
            }
          }
          // to be selected, OR the above result with the previous selection state for this item
          if (select) {
            itemIds[id].selectedTertiary = true;
          }
        }
      }
    };
        
    this.determineFilteredItems = function() {
      var i;
      var j;
      var id;
      var attr;
      var attrFiltered;
      var at;
      var filter;
      var ranges;
      var range;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        filter = true;
        for (attr in _filterRanges) {
          if (_filterRanges.hasOwnProperty(attr)) {
            attrFiltered = false;
            // to be filtered by this expression, must be true for one of the ranges for this attribute (OR)
            at = attributes[attr];
            if (at !== undefined) {
              if (at.isCategorical() && at.isFiltered(id.name)) {
                attrFiltered = true;
              } else {
                ranges = _filterRanges[attr];
                id (ranges !== undefined) {
                  for (j = 0; j < ranges.length; j++) {
                    if (ranges[j].isInRange(at.getItem(id.name))) {
                      attrFiltered = true;
                      break;
                    }
                  }
                }
              }
            }
            // to be filtered, AND the above result with the previous filter state for this item
            if (!attrFiltered) {
              filter = false;
              break;
            }
          }
        }
        id.filtered = filter;
      }
    };
            
    this.getHoverCat = function(attr) {
      var at = attributes[attr];
      var range;
      var cats;
      if (at !== undefined && at.isCategorical()) {
        if (_hoverCoords.length > 0) {
          return at.getItem(_hoverCoords);
        } else {
          if (attr !== _hoverRange.first) {
            // not the hovered attribute, so can't return the assoc cat
            return "";
          }
          range = _hoverRange.second;
          cats = range.getFilteredCategories();
          if (cats.length > 0) {
            return cats[0]; // TODO should never be more than one category here
          } else {
            return "";
          }
        }
      } else {
        return "";
      }
    };

    this.getHoverRange = function(attr) {
      var at = attributes[attr];
      var range;
      var vals = [];
      if (at !== undefined && !at.isCategorical()) {
        if (_hoverCoords.length > 0) {
          vals[0] = at.getItem(_hoverCoords);
          vals[1] = vals[0];
          return vals;
        } else {
          if (attr !== _hoverRange.first) {
            // not the hovered attribute, so can't return the assoc cat
            return vals;
          }
          range = _hoverRange.second;
          vals[0] = "" + range.getMin();
          vals[1] = "" + range.getMax();
          return vals;
        }
      } else {
        return vals;
      }
    };
    
    this.getSelectCats = function(attr, selectType) {
      var cats = new delv.categoricalRange();
      var selectList = _selectRanges.get(selectType);
      var at = attributes[attr];
      var smap;
      var selectMap;
      var range;
      var cts;
      var cat;
      if (at !== undefined && at.isCategorical()) {
        for (smap = 0; smap < selectList.length; smap++) {
          selectMap = selectList[smap];
          range = selectMap[attr];
          if (range !== undefined) {
            cts = range.getFilteredCategories();
            for (cat = 0; cat < cts.length; cat++) {
              cats.addCategory(cts[cat]);
            }
          }
          range = selectMap["__id__"];
          if (range !== undefined) {
            cts = range.getFilteredCategories();
            for (cat = 0; cat < cts.length; cat++) {
              cats.addCategory(at.getItem(cts[cat]));
            }
          }
        }
      }
      return cats.getFilteredCategories();
    };

    // TODO need to validate selectType everywhere
    this.getSelectRanges = function(attr, selectType) {
      var at = attributes[attr];
      var selectList = _selectRanges[selectType];
      var selectRanges = [];
      var smap;
      var selectMap = {};
      var range;
      var vals = [];
      var ids = [];
      var id;
      var idrange;
      if (at !== undefined && !at.isCategorical()) {
        for (smap = 0; smap < selectList.length; smap++) {
          selectMap = selectList[smap];
          range = selectMap[attr];
          vals = [];
          if (range !== undefined) {
            vals[0] = "" + range.getMin();
            vals[1] = "" + range.getMax();
            selectRanges[selectRanges.length] = vals;
          }
          range = selectMap["__id__"];
          if (range !== undefined) {
            ids = range.getFilteredCategories();
            idrange = new delv.continuousRange();
            for (id = 0; id < ids.length; id++) {
              idrange.update(at.getItemAsFloat(ids[id]));
            }
            vals[0] = "" + idrange.getMin();
            vals[1] = "" + idrange.getMax();
            selectRanges[selectRanges.length] = vals;
          }
        }
      }
      return selectRanges;
    };

    this.getSelectCriteria = function(selectType) {
      var selectList = _selectRanges[selectType];
      var selectCrits = [];
      var smap;
      var selectMap = {};
      var numKeys;
      var numMaps = 0;
      var attr;
      var range;
      var cats = [];
      var vals = [];
      var at;
      for (smap = 0; smap < selectList.length; smap++) {
        selectMap = selectList[smap];
        selectCrits[numMaps] = [];
        numKeys = 0;
        for (attr in selectMap) {
          if (selectMap.hasOwnProperty(attr)) {
            range = selectMap[attr];
            vals = [];
            if (attr === "__id__") {
              if (range !== undefined) {
                cats = range.getFilteredCategories();
                vals[0] = "__id__";
                Array.prototype.push.apply(vals, cats);
                selectCrits[numMaps][numKeys] = vals;
              } else {
                selectCrits[numMaps][numKeys] = [];
              }
            } else {
              at = attributes[attr];
              if (at !== undefined && range !== undefined) {
                if (at.isCategorical()) {
                  cats = range.getFilteredCategories();
                  vals[0] = attr;
                  Array.prototype.push.apply(vals, cats);
                  selectCrits[numMaps][numKeys] = vals;
                } else {
                  vals[0] = attr;
                  vals[1] = "" + range.getMin();
                  vals[2] = "" + range.getMax();
                  selectCrits[numMaps][numKeys] = vals;
                }
              } else {
                selectCrits[numMaps][numKeys] = vals;
              }
            }
            numKeys++;
          }
        }
        numMaps++;
      }
      return selectCrits;
    };
              
    this.getFilterCats = function(attr) {
      var at = attributes[attr];
      if (at !== undefined && at.isCategorical()) {
        return at.getFilterCats();
      } else {
        return [];
      }
    };

    this.getFilterRanges = function(attr) {
      var filterVals = [];
      var at = attributes[attr];
      var ranges = _filterRanges[attr];
      var range;
      var i;
      var vals = [];
      if (at !== undefined && !at.isCategorical()) {
        if (ranges !== undefined) {
          for (i = 0; i < ranges.length; i++) {
            range = ranges[i];
            if (range !== undefined) {
              vals = [];
              vals[0] = "" + range.getMin();
              vals[1] = "" + range.getMax();
              filterVals[filterVals.length] = vals;
            }
          }
        } else {
          // ranges not specified, so return range of the data
          vals = [];
          vals[0] = at.getMinVal();
          vals[1] = at.getMaxVal();
          filterVals[filterVals.length] = vals;
        }
      }
      return filterVals;
    };

    this.getFilterCriteria = function() {
      var filterCrits = [];
      var attr;
      var at;
      var cats = [];
      var vals = [];
      var ranges = [];
      var range;
      var i;
      for (attr in _filterRanges) {
        if (_filterRanges.hasOwnProperty(attr)) {
          at = attributes[attr];
          vals = [];
          if (at !== undefined) {
            if (at.isCategorical()) {
              cats = at.getFilterCats();
              vals[0] = attr;
              Array.prototype.push.apply(vals, cats);
              filterCrits.add(vals);
            } else {
              ranges = _filterRanges[attr];
              if (ranges !== undefined) {
                for (i = 0; i < ranges.length; i++) {
                  range = ranges[i];
                  vals = [];
                  vals[0] = attr;
                  vals[1] = "" + range.getMin();
                  vals[2] = "" + range.getMax();
                  filterCrits[filterCrits.length] = vals;
                }
              }
            }
          }
        }
      }
      return filterCrits;
    };

    this.clearHover = function() {
      var id;
      _hoverCoords = [];
      _hoverRange.set("", new delv.categoricalRange);
      for (id = 0; id < itemIds.length; id++){
        itemIds[id].hovered = false;
      }
    };

    this.clearSelect = function(selectType) {
      var id;
      _selectRanges[selectType] = [];
      switch (selectType) {
      case "PRIMARY":
        for (id = 0; id < itemIds.length; id++) {
          itemIds[id].selectedPrimary = false;
        }
        break;
      case "SECONDARY":
        for (id = 0; id < itemIds.length; id++) {
          itemIds[id].selectedSecondary = false;
        }
        break;
      case "TERTIARY":
        for (id = 0; id < itemIds.length; id++) {
          itemIds[id].selectedTertiary = false;
        }
        break;
      default:
        break;
      }
    };

    this.clearFilter = function() {
      var id;
      var attr;
      _filterRanges = {};
      for (id = 0; id < itemIds.length; id++) {
        id.filtered = true;
      }
      for (attr in attributes) {
        if (attributes.hasOwnProperty(attr)) {
          if (attributes[attr].isCategorical()) {
            attributes[attr].filterAll();
          }
        }
      }
    };

    this.hoverColor = function(rgbaColor) {
      _hoverColor = rgbaColor;
      _hoverColorSet = true;
    };
    this.selectColor = function(rgbaColor, selectType) {
      _selectColor[selectType] = rgbaColor;
      _selectColorSet[selectType] = true;
    };
    this.filterColor = function(rgbaColor) {
      _filterColor = rgbaColor;
      _filterColorSet = true;
    };
    this.likeColor = function(rgbaColor) {
      _likeColor = rgbaColor;
      _likeColorSet = true;
    };

    this.clearHoverColor = function() {
      _hoverColorSet = false;
    };
    this.clearSelectColor = function(selectType) {
      _selectColorSet[selectType] = false;
    };
    this.clearFilterColor = function() {
      _filterColorSet = false;
    };
    this.clearLikeColor = function() {
      _likeColorSet = false;
    };

    this.getHoverColor = function() {
      return _hoverColorSet ? _hoverColor : _defaultColor;
    };
    this.getSelectColor = function(selectType) {
      return _selectColorSet[selectType] ? _selectColor[selectType] : _defaultColor;
    };
    this.getFilterColor = function() {
      return _filterColorSet ? _filterColor : _defaultColor;
    }; 
    this.getLikeColor = function() {
      return _likeColorSet ? _likeColor : _defaultColor;
    };
    
    this.getAllCatColorMaps = function(attr) {
      return attributes[attr].getAllCatColorMaps();
    };

    // this.updateFilterMin = function(attr, val) {
    //   attributes[attr].updateFilterMin(val);
    // };
    // this.updateFilterMax = function(attr, val) {
    //   attributes[attr].updateFilterMax(val);
    // };
    // this.getFilterMin = function(attr) {
    //   return attributes[attr].getFilterMin();
    // };
    // this.getFilterMax = function(attr) {
    //   return attributes[attr].getFilterMax();
    // };

  }; // end delv.dataSet

  // TODO add a datatype for date / time?
  delv.AttributeType = {
    UNSTRUCTURED: {name: "UNSTRUCTURED"},
    CATEGORICAL: {name: "CATEGORICAL"},
    CATEGORICAL_LIST: {name: "CATEGORICAL_LIST"},
    CONTINUOUS: {name: "CONTINUOUS"},
    DATETIME: {name: "DATETIME"},
    FLOAT_ARRAY: {name: "FLOAT_ARRAY"}
  }; 

  delv.attribute = function(attr_name, attr_type, color_map, data_range) {
    var items = {};
    var floatItems = {};
    var floatArrayItems = [];
    var floatArrayMap = {};
    var type = attr_type;
    var colorMap = color_map;
    var fullRange = data_range;
    this.name = attr_name;

    this.isCategorical = function() {
      return (type.equals(delv.AttributeType.CATEGORICAL) ||
              type.equals(delv.AttributeType.CATEGORICAL_LIST));
    };
    
    this.clear = function() {
      items = {};
      floatItems = {};
      floatArrayItems = [];
      floatArrayMap = {};
      // TODO add these range interfaces to Processing implementation as well
      fullRange.clear();
    };

    this.clearItems = function() {
      clear();
    };
    
    this.removeItem = function(coord) {
      var id = delv.coordToId(id);
      var idx;
      var anId;
      var anIdx;
      items.remove(id);
      floatItems.remove(id);
      if (type.equals(delv.AttributeType.FLOAT_ARRAY)) {
        idx = floatArrayMap(id);
        floatArrayItems.splice(idx, 1);
        delete floatArrayMap[id];
        // and now update the indexes in the map
        for (anId in floatArrayMap) {
          anIdx = floatArrayMap[anId];
          if (anIdx > idx) {
            floatArrayMap[anId] = anIdx-1;
          }
        }
      }
    };
    
    this.setItem = function(coord, item) {
      var id = delv.coordToId(coord);
      var val;
      if (type === delv.AttributeType.CATEGORICAL) {
        items[id] = item;
        fullRange.addCategory(item);
      } else if (type === delv.AttributeType.DATETIME) {
        // TODO decide how best to store it, this is storing 2!!! copies
        if (typeof(item) === "number") {
          val = new Date(item);
        } else {
          val = new Date(Date.parse(item));
        }
        floatItems[id] = val;
        items[id] = item;
        fullRange.update(val);
      } else if (type === delv.AttributeType.CONTINUOUS) {
        val = parseFloat(item);
        floatItems[id] = val;
        fullRange.update(val);
      } else if (type === delv.AttributeType.FLOAT_ARRAY) {
        // TODO fix this
        delv.log("Cannot set a FLOAT_ARRAY from String");
      } else {
        items[id] = "" + item;
        // TODO handle fullRange for unstructured data
      }
    };

    this.setFloatItem = function(coord, item) {
      var id = delv.coordToId(coord);
      if (type === delv.AttributeType.CONTINUOUS) {
        floatItems[id] = item;
        fullRange.update(item);
      }
    };

    this.setFloatArrayItem = function(coord, item) {
      var id = delv.coordToId(coord);
      var idx;
      if (type === delv.AttributeType.FLOAT_ARRAY) {
        if (floatArrayMap.hasOwnProperty(id)) {
          idx = floatArrayMap[id];
        } else {
          idx = floatArrayItems.length;
          floatArrayMap[id] = idx;
        }
        floatArrayItems[idx] = item;
      }
    };
    
    this.getItem = function(coord) {
      var id = delv.coordToId(coord);
      if (type === delv.AttributeType.CONTINUOUS) {
        return "" + floatItems[id];
      } else {
        if (items.hasOwnProperty(id)) {
          return (items[id]);
        } else {
          return ("");
        }
      }
    };

    this.getItemAsFloat = function(coord) {
      var id = delv.coordToId(coord);
      if (type === delv.AttributeType.CONTINUOUS) {
        return floatItems[id];
      } else if (type === delv.AttributeType.DATETIME) {
        // TODO do this here? or separate getItemAsDate 
        return floatItems[id];
      } else if (type === delv.AttributeType.CATEGORICAL) {
        if (items.hasOwnProperty(id)) {
          return parseFloat(items[id]);
        } else {
          return 0.0;
        }
      } else {
        return 0.0;
      }
    };

    this.getItemAsFloatArray = function(coord) {
      var id = delv.coordToId(coord);
      var idx;
      var item;
      var vals;
      var nums;
      var i;
      if (type === delv.AttributeType.FLOAT_ARRAY) {
        idx = floatArrayMap[id];
        return floatArrayItems[idx];
        // TODO does this make sense for any other type?
      } else if (type === delv.AttributeType.CATEGORICAL) {
        if (items.hasOwnProperty(id)) {
          item = items[id];
          vals = item.split(",");
          nums = [];
          for (i = 0; i < vals.length; i++) {
            nums[i] = parseFloat(vals[i]);
          }
          return nums;
        } else {
          return [];
        }
      } else {
        return [];
      }
    };

    this.getAllItems = function() {
      var its = [];
      var item;
      if (type === delv.AttributeType.CONTINUOUS) {
        its = [];
        for (item in floatItems) {
          if (floatItems.hasOwnProperty(item)) {
            its[its.length] = floatItems[item];
          }
        }
        return its;
      } else {
        for (item in items) {
          if (items.hasOwnProperty(item)) {
            its[its.length] = items[item];
          }
        }
        return its;
      }
      return [];
    };

    this.getAllItemsAsFloat = function() {
      var its;
      var item;
      if (type === delv.AttributeType.CONTINUOUS ||
          type === delv.AttributeType.DATETIME) {
        its = [];
        for (item in floatItems) {
          if (floatItems.hasOwnProperty(item)) {
            its[its.length] = floatItems[item];
          }
        }
        return its;
      } else if (type === delv.AttributeType.CATEGORICAL) {
        // TODO handle case where type doesn't convert well better
        its = [];
        for (item in items) {
          if (items.hasOwnProperty(item)) {
            its[its.length] = parseFloat(items[item]);
          }
        }
        return its;
      }
      return [];
    };

    this.getAllItemsAsFloatArray = function() {
      var its;
      var item;
      var vals;
      var nums;
      var i;
      if (type === AttributeType.FLOAT_ARRAY) {
        return floatArrayItems;
        // TODO does this make sense for any other type?
      } else if (type === AttributeType.CATEGORICAL) {
        its = [];
        for (item in items) {
          if (items.hasOwnProperty(item)) {
            vals = items[item].split(",");
            nums = [];
            for (i = 0; i < vals.length; i++) {
              nums[i] = parseFloat(vals[i]);
            }
            its[its.length] = nums;
          }
        }
        return its;
      }
      return [];
    };

    this.getItemAttrColor = function(id) {
      return colorMap.getColor(getItem(id));
    };

    this.getAllCats = function() {
      if (type === delv.AttributeType.CATEGORICAL) {
        return fullRange.getCategories();
      } else {
      return [];
      }
    };
    
    this.getFilterCats = function() {
      if (type === delv.AttributeType.CATEGORICAL) {
        return fullRange.getFilteredCategories();
      } else {
        return [];
      }
    };

    this.getCatColor = function(cat) {
      return colorMap.getColor(cat);
    };
    
    this.getCatColors = function() {
      var cats = this.getAllCats();
      var colors = [];
      var i;
      for (i = 0; i < cats.length; i++) {
        colors[i] = colorMap.getColor(cats[i]);
      }
      return colors;
    };

    this.getMinVal = function() {
      if (!isCategorical()) {
        return fullRange.getMin();
      } else {
        return "";
      }
    };
    this.getMaxVal = function() {
      if (!isCategorical()) {
        return fullRange.getMax();
      } else {
        return "";
      }
    };

    // TODO right way to construct color obj?
    this.colorCat = function(cat, rgbaColor) {
      if (type === delv.AttributeType.CATEGORICAL) {
        colorMap.setColor(cat, rgbaColor);
      }
    };

    this.filterAll = function() {
      fullRange.filterAll();
    };
    this.filterNone = function() {
      fullRange.filterNone();
    };
    
    this.toggleCatFilter = function(cat) {
      if (type === delv.AttributeType.CATEGORICAL) {
        fullRange.toggleFiltered(cat);
      }
    };

    this.isFiltered = function(coord) {
      var id = delv.coordToId(coord);
      if (type === delv.AttributeType.CATEGORICAL) {
        return fullRange.isCategoryFiltered(getItem(id));
      } else {
        // TODO fix this, UNSTRUCTURED data is always visible for now
        return true;
      }
    };

    this.getAllCatColorMaps = function() {
      // TODO return colorMap or return colorMap.getColor?
      // for now return getColor, see how this works when playing with Processing/Java
      return colorMap.getColor;
    };

    // this.updateVisibleMin = function(val) {
    //   if (type === delv.AttributeType.CONTINUOUS) {
    //     visibleRange.setMin(parseFloat(val));
    //   } else if (type === delv.AttributeType.DATETIME) {
    //     if (typeof(val) === "number") {
    //       visibleRange.setMin(new Date(val));
    //     } else {
    //       visibleRange.setMin(new Date(Date.parse(val)));
    //     }
    //   }
    //   //visibleRange.setMin(val);
    // };
    // this.updateVisibleMax = function(val) {
    //   if (type === delv.AttributeType.CONTINUOUS) {
    //     visibleRange.setMax(parseFloat(val));
    //   } else if (type === delv.AttributeType.DATETIME) {
    //     if (typeof(val) === "number") {
    //       visibleRange.setMax(new Date(val));
    //     } else {
    //       visibleRange.setMax(new Date(Date.parse(val)));
    //     }
    //   }
    //   //visibleRange.setMax(val);
    // };
    // this.getVisibleMin = function() {
    //   return visibleRange.getMin();
    // };
    // this.getVisibleMax = function() {
    //   return visibleRange.getMax();
    // };
    
  }; // end delv.attribute

  delv.coordToId = function(coord) {
    var id = "";
    var cc;
    if (coord.length == 0) {
      return id;
    } else {
      id = coord[0];
      for (cc = 1; cc < coord.length; cc++) {
        id = id + ";" + coord[cc];
      }
      return id;
    }
  };

  delv.idToCoord(id) {
    // TODO perhaps unhardcode separator
    return id.split(";");
  };

  
  delv.itemId = function(id) {
    // want these all to be public
    this.name = delv.coordToId(id);
    this.hovered = false;
    this.selectedPrimary = false;
    this.selectedSecondary = false;
    this.selectedTertiary = false;
    this.filtered = true;
    this.navigated = true;

    
    this.toggleHovered = function() {
      hovered = !hovered;
    };

    this.togglePrimarySelection = function() {
      selectedPrimary = !selectedPrimary;
    };
    this.toggleSecondarySelection = function() {
      selectedSecondary = !selectedSecondary;
    };
    this.toggleTertiarySelection = function() {
      selectedTertiary = !selectedTertiary;
    };
    
    this.toggleFiltered = function() {
      filtered = !filtered;
    };
    this.toggleNavigated = function() {
      navigated = !navigated;
    };
  }; // end delv.itemId

  delv.categoricalRange = function() {
    var categories = [];
    var filtered = {};

    this.clear = function() {
      var categories = [];
      var filtered = {};
    };
    
    this.addCategory = function(cat) {
      var found = false;
      var i;
      for (i = 0; i < categories.length; i++) {
        if (categories[i] === cat) {
          found = true;
          break;
        }
      }
      if (!found) {
        categories[categories.length] = cat;
      }
      filtered[cat] = true;
    };

    this.filterAll = function() {
      var filt;
      for (filt in filtered) {
        if (filtered.hasOwnProperty(filt)) {
          filtered[filt] = true;
        }
      }
    };
    this.filterNone = function() {
      var filt;
      for (filt in filtered) {
        if (filtered.hasOwnProperty(filt)) {
          filtered[filt] = false;
        }
      }
    };
    
    this.getCategories = function() {
      return categories;
    };

    this.getFilteredCategories = function() {
      var filt = [];
      var cat;
      var i;
      for (i = 0; i < categories.length; i++) {
        cat = categories[i];
        if (filtered[cat]) {
          filt[filt.length] = cat;
        }
      }
      return filt;
    };

    this.toggleFiltered = function(cat) {
      filtered[cat] = !filtered[cat];
    };

    this.isInRange = function(val) {
      return isCategoryFiltered(val);
    };
    
    this.isCategoryFiltered = function(cat) {
      var filt = filtered[cat];
      if (filt === undefined) {
        return false;
      }
      return filt;
    };
    
  }; // end delv.dataRange


  delv.continuousRange = function() {
    this.min;
    this.max;
    this._hasMin = false;
    this._hasMax = false;

    this.clear = function() {
      this._hasMin = false;
      this._hasMax = false;
    };
    
    this.hasMin = function() {
      return this._hasMin;
    };
    this.hasMax = function() {
      return this._hasMax;
    };

    this.getMin = function() {
      return this.min;
    };
    this.getMax = function() {
      return this.max;
    };

    this.setMin = function(val) {
      this.min = val;
      this._hasMin = true;
    };
    this.setMax = function(val) {
      this.max = val;
      this._hasMax = true;
    };

    this.updateMin = function(val) {
      if (!this._hasMin || val < this.min) {
        this.min = val;
        this._hasMin = true;
      }
    };
    this.updateMax = function(val) {
      if (!this._hasMax || val > this.max) {
        this.max = val;
        this._hasMax = true;
      }
    };

    this.update = function(val) {
      this.updateMin(val);
      this.updateMax(val);
    };

    this.isInRange = function(val) {
      if (!this._hasMin) {
        if (!this._hasMax) {
          return true;
        } else {
          return (val <= this.max);
        }
      } else if (!this._hasMax) {
        return (this.min <= val);
      } else {
        return (this.min <= val && val <= this.max);
      }
    };

  }; // end delv.continuousRange

  delv.colorMap = function(color) {
    // TODO define color class or color object?
    var defaultColor = ["220", "220", "220"];
    if (typeof(color) !== "undefined") {
      defaultColor = color;
    }
    var colors = {};

    this.getColor = function(value) {
      if (typeof(colors) !== "undefined" && colors.hasOwnProperty(value)) {
        return colors[value];
      } else {
        return defaultColor;
      }
    };

    this.setColor = function(value, c) {
      // sets color map for entry value to color color
      // overrides existing color if that value already exists
      colors[value] = c;
    };

    this.setDefaultColor = function(c) {
      defaultColor = c;
    };

    // way to visualize color map
    // void drawToFile(String filename) {
    //   background(255,255,255);
    //   //size(_colors.size() * 50, 50);
    //   noStroke();
    //   int i = 0;
    //   for (color c : _colors.values()) {
    //     fill(red(c),green(c),blue(c));
    //     rect(i * 50, 0, 50, 50);
    //     i++;
    //   }
    //   save(filename);
    // }
  }; // end delv.colorMap

  delv.continuousColorMap = function(color) {
    this.bounds = {};
    this.colors = {};
    this.defaultColor = color || ["220", "220", "220"];

    this.getColor = function(value) {
      var idx = -1;
      var val = parseFloat(value);
      var i;
      var colorfun;
      var bound;
      var lb;
      var ub;
      var relval;
      for (i = 0; i < this.bounds.length; i++) {
        if (this.bounds[i].contains(val)) {
          idx = i;
          break;
        }
      }
      if (idx < 0) {
        return this.defaultColor;
      } else {
        colorfun = this.colors[idx];
        if (colorfun !== undefined) {
          bound = this.bounds[idx];
          lb = bound._lower;
          ub = bound._upper;
          relval = 0;
          // TODO how to handle case when _hasUpper or _hasLower is false
          if (bound.hasLower) {
            relval = val / ub;
          } else if (!bound.hasUpper) {
            relval = 1 - (lb / val);
          } else {
            relval = (val - lb) / (ub - lb);
          }
          return colorfun.getColor(relval);
        } else {
          return this.defaultColor;
        }
      }
    };

    this.setColor = function(contRange, colorfun) {
      // if the input range overlaps an existing range, the new input range takes precedence
      var numBounds = this.bounds.length;
      var insertLoc;
      var i;
      var finalLoc;
      var newBounds;
      var newColors;

      if (!contRange.hasLower) {
        insertLoc = 0;
      } else {
        insertLoc = numBounds;
        for (i = 0; i < numBounds; i++) {
          if (this.bounds[i].lower === contRange.lower) {
            insertLoc = i;
            break;
          } else if (contRange.lower < this.bounds[i].lower) {
            insertLoc = i;
            break;
          }
        }
      }

      if (insertLoc === numBounds) {
        bounds[numBounds] = contRange;
        colors[colors.length] = colorfun;
        return;
      }

      if (!contRange.hasUpper) {
        finalLoc = numBounds-1;
      } else {
        finalLoc = 0;
        for (i = 0; i < numBounds; i++) {
          if (this.bounds[i].upper === contRange.upper) {
            finalLoc = i+1;
            break;
          } else if (this.bounds[i].upper > contRange.upper) {
            finalLoc = i-1;
            break;
          }
        }
      }

      if (insertLoc < finalLoc) {
        newBounds = this.bounds.slice(0, insertLoc);
        this.bounds = newBounds.concat(this.bounds.slice(finalLoc, this.bounds.length));

        newColors = this.colors.slice(0,insertLoc);
        this.colors = newColors.concat(this.colors.slice(finalLoc, this.colors.length));
      }
      if (insertLoc > 0) {
        if (this.bounds[insertLoc-1].upper > contRange.lower) {
          this.bounds[insertLoc-1].upper = contRange.lower;
        }
      }
      if (insertLoc + 1 < this.bounds.length) {
        if (this.bounds[insertLoc+1].lower < contRange.upper) {
          this.bounds[insertLoc+1].lower = contRange.upper;
        }
      }
      this.bounds.splice(insertLoc, 0, contRange);
      this.colors.splice(insertLoc, 0, colorfun);
    };

    this.setDefaultColor = function(c) {
      this.defaultColor = c;
    };

  // void drawToFile(String filename) {
  //   if (_bounds.size() === 0) {
  //     return;
  //   }
  //   int numsamp = 1000;
  //   int numbounds = _bounds.size();
  //   int numsampperbound = numsamp / numbounds;
  //   numsamp = numsampperbound * numbounds;
  //   ArrayList<Float> samps = new ArrayList<Float>();

  //   float lb;
  //   float ub;
  //   HalfOpenRange b = _bounds.get(0);
  //   if (!b._hasLower) {
  //     lb = b._upper / 10;
  //   } else {
  //     lb = b._lower;
  //   }

  //   b = _bounds.get(numbounds - 1);
  //   if (!b._hasUpper) {
  //     ub = b._lower * 10;
  //   } else {
  //     ub = b._upper;
  //   }

  //   for (int i = 0; i < numsamp; i++) {
  //     samps.add(lb + i * (ub-lb) / numsamp);
  //   }

  //   background(255,255,255);
  //   //size(numsamp, 50);
  //   noStroke();
  //   int i = 0;
  //   for (Float val : samps) {
  //     color c = getColor(""+val);
  //     fill(red(c),green(c),blue(c));
  //     rect(i * 50, 0, 50, 50);
  //     i++;
  //   }
  //   save(filename);
  // }

  }; //end delv.continuousColorMap


  delv.halfOpenRange = function() {
    // implements a half-open range [lower, upper)
    // TODO be sure to enforce condition that both lb and ub can't be None for the same entry
    this.lower = 0;
    this.upper = 1;
    this.hasLower = false;
    this.hasUpper = false;

    this.setLower = function(val) {
      this.hasLower = true;
      this.lower = val;
    };
    this.setUpper = function(val) {
      this.hasUpper = true;
      this.upper = val;
    };

    this.overlapped = function(other) {
      var status = false;
      if ((other.hasLower && this.contains(other.lower)) || (other.hasUpper && this.contains(other.upper))) {
        status = true;
      }
      return status;
    };

    this.contains = function(value) {
      var status = false;
      // TODO python version had this wrapped in an if value != None check.  Is that necessary still?
      if (!this.hasLower && value < this.upper) {
        status = true;
      } else if (!this.hasUpper && value >= this.lower) {
        status = true;
      } else if (this.lower <= value && value < this.upper) {
        status = true;
      }
      return status;
    };
  }; // end delv.halfOpenRange

  // some helper color utilities
  delv.interp1 = function(start, end, value, maximum) {
    return start + (end - start) * value / maximum;
  };

  delv.interp3 = function(start, end, value, maximum) {
    var r = [];
    // TODO use some nice jquery type map syntax
    if (start.length >= 3 && end.length >= 3) {
      r[0] = interp1(start[0], end[0], value, maximum);
      r[1] = interp1(start[1], end[1], value, maximum);
      r[2] = interp1(start[2], end[2], value, maximum);
    }
    return r;
  };
  delv.interp4 = function(start, end, value, maximum) {
    var r = [];
    // TODO use some nice jquery type map syntax
    if (start.length >= 4 && end.length >= 4) {
      r[0] = interp1(start[0], end[0], value, maximum);
      r[1] = interp1(start[1], end[1], value, maximum);
      r[2] = interp1(start[2], end[2], value, maximum);
      r[3] = interp1(start[3], end[3], value, maximum);
    }
    return r;
  };

  delv.rgb2hsv = function(r, g, b) {
    // takes r, g, b in range 0 to 1
    // returns hsv in range 0 to 1
    var minrgb = Math.min( r, Math.min(g, b) );
    var maxrgb = Math.max( r, Math.max(g, b) );
    var diff = maxrgb - minrgb;

    var hsv = [];
    var diffR;
    var diffG;
    var diffB;

    hsv[2] = maxrgb;

    if ( diff === 0 ) {
      // grayscale
      hsv[0] = 0;
      hsv[1] = 0;
    } else {
      // has color
      hsv[1] = diff / maxrgb;

      diffR = ( ( ( maxrgb - r ) / 6 ) + ( diff / 2 ) ) / diff;
      diffG = ( ( ( maxrgb - g ) / 6 ) + ( diff / 2 ) ) / diff;
      diffB = ( ( ( maxrgb - b ) / 6 ) + ( diff / 2 ) ) / diff;

      if      ( r === maxrgb ) { hsv[0] = diffB - diffG; }
      else if ( g === maxrgb ) { hsv[0] = ( 1 / 3 ) + diffR - diffB; }
      else if ( b === maxrgb ) { hsv[0] = ( 2 / 3 ) + diffG - diffR; }

      if ( hsv[0] < 0 ) { hsv[0] += 1; }
      if ( hsv[0] > 1 ) { hsv[0] -= 1; }
    }
    return hsv;
  };

  delv.hsv2rgb = function(h, s, v) {
    // takes h, s, v from range 0 to 1
    // returns rgb in range 0 to 1
    var rgb = [];
    var scaleH;
    var i;
    var p;
    var q;
    var t;
    if ( s === 0 ) {
      rgb[0] = v;
      rgb[1] = v;
      rgb[2] = v;
    } else {
      scaleH = h * 6;
      if ( scaleH === 6 ) {
        //scaleH must be < 1
        scaleH = 0;
      }
      i = Math.floor( scaleH );             //Or ... var_i = floor( var_h )
      p = v * ( 1 - s );
      q = v * ( 1 - s * ( scaleH - i ) );
      t = v * ( 1 - s * ( 1 - ( scaleH - i ) ) );

      if      ( i === 0 ) { rgb[0] = v ; rgb[1] = t ; rgb[2] = p; }
      else if ( i === 1 ) { rgb[0] = q ; rgb[1] = v ; rgb[2] = p; }
      else if ( i === 2 ) { rgb[0] = p ; rgb[1] = v ; rgb[2] = t; }
      else if ( i === 3 ) { rgb[0] = p ; rgb[1] = q ; rgb[2] = v; }
      else if ( i === 4 ) { rgb[0] = t ; rgb[1] = p ; rgb[2] = v; }
      else                { rgb[0] = v ; rgb[1] = p ; rgb[2] = q; }
    }
    return rgb;
  };

  delv.lerp = function(start, end, value) {
    // assumes inputs are RGBA arrays
    // use algorithm from http://stackoverflow.com/questions/168838/color-scaling-function
    // convert everything to HSV
    // interpolate
    // convert back to RGBA
    var start_hsv = rgb2hsv(red(start)/255.0,green(start)/255.0,blue(start)/255.0);
    var end_hsv = rgb2hsv(red(end)/255.0,green(end)/255.0,blue(end)/255.0);
    var interp_hsv = interp3(start_hsv, end_hsv, value, 1);
    var interp_rgb = hsv2rgb(interp_hsv[0], interp_hsv[1], interp_hsv[2]);
    var interp_alpha = interp1(alpha(start)/255.0,alpha(end)/255.0, value, 1);
    // TODO how to handle color object?
    var rgba = color( Math.round(interp_rgb[0] * 255),
                      Math.round(interp_rgb[1] * 255),
                      Math.round(interp_rgb[2] * 255),
                      Math.round(interp_alpha * 255) );
    return rgba;
  };

  // TODO create some default color functions here
  // Note:  color functions assume that value will be in the range [0,1]
  // This is done in order to work with the ContinuousColorMap concept above

  delv.green_scale = function() {
    this.getColor = function(value) {
      return lerp(color(0,0,0), color(0,255,0), value);
    };
  };

  delv.green_to_red = function() {
    this.getColor = function(value) {
      return lerp(color(0,255,0), color(255,0,0), value);
    };
  };

  delv.red_to_blue = function() {
    this.getColor = function(value) {
      return lerp(color(255,0,0), color(0,0,255), value);
    };
  };

  delv.brightgreen = function() {
    this.getColor = function(value) {
      return color(0, 255, 0);
    };
  };

  delv.hex = function(rgb) {
    var result = "#";
    var val = 0;
    var valstr = "";
    if (rgb[0] === '#') {
        return rgb;
    }
    // for hex, alpha comes first (aRGB)
    if (rgb.length > 3) {
      val = parseInt(rgb[3]);
      valstr = val.toString(16);
      result += valstr;
      if (val < 10) {
        result += valstr;
      }
    }
    val = parseInt(rgb[0]);
    valstr = val.toString(16);
    result += valstr;
    if (val < 10) {
      result += valstr;
    }
    val = parseInt(rgb[1]);
    valstr = val.toString(16);
    result += valstr;
    if (val < 10) {
      result += valstr;
    }
    val = parseInt(rgb[2]);
    valstr = val.toString(16);
    result += valstr;
    if (val < 10) {
      result += valstr;
    }
    //result += parseInt(rgb[0]).toString(16) + parseInt(rgb[1]).toString(16) + parseInt(rgb[2]).toString(16);
    return result;
  };

  delv.unhex = function(hex) {
    // Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
    var shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
    var result;
    hex = hex.replace(shorthandRegex, function(m, r, g, b) {
      return r + r + g + g + b + b;
    });

    result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    if (result) {
        return [ parseInt(result[1], 16),
                 parseInt(result[2], 16),
                 parseInt(result[3], 16),
                 parseInt(result[4], 16) ];
    }
    
    result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? [parseInt(result[1], 16),
                     parseInt(result[2], 16),
                     parseInt(result[3], 16)
                    ] : null;
  };


  delv.colorMapWithCheckpoints = function(colors) {
    var _colors = colors;

    this.useDefaultMap = function() {
      _colors = [];
      _colors[0] = delv.unhex("FFFFD9");
      _colors[1] = delv.unhex("EDF8B1");
      _colors[2] = delv.unhex("C7E9B4");
      _colors[3] = delv.unhex("7FCDBB");
      _colors[4] = delv.unhex("41B6C4");
      _colors[5] = delv.unhex("1D91C0");
      _colors[6] = delv.unhex("225EA8");
      _colors[7] = delv.unhex("253494");
      _colors[8] = delv.unhex("081D58");
    };

    this.getColor = function(value) {
      // pass this class into ContinuousColorMap.setColor as colorfun
      // value is in range 0 to 1
      // divide this range into equal pieces depending on number of self.colors
      var numIntervals = _colors.length - 1;
      var interval = 1.0 / numIntervals;
      var c = color(255,255,255);
      var i;
      for (i = 0; i < numIntervals; ++i) {
        if (value < (i+1) * interval) {
          c = lerp(_colors[i], _colors[i+1], (value - (i)*interval) / interval);
          break;
        }
      }
      return c;
    };
  }; // end delv.colorMapWithCheckpoints

  // TODO create some default color map constructors here
  delv.categorical_map_1 = function() {
    // from MulteeSum
    var cmap = ["FF7F00",
                "6A3D9A",
                "1F78B4",
                "33A02C",
                "FB9A99",
                "A6CEE3",
                "B2DF8A",
                "FDBF6F",
                "CAB2D6"];
    return cmap;
  };

  delv.categorical_map_2 = function() {
    // from InSite
    var cmap = ["1F78B4",   // blue
                "33A02C",   // green
                "E31A1C",   // red
                "FF7F00",   // orange
                "6A3D9A",   // purple
                "D2D2D2", // clear old color (FEATURE_DEFAULT_COLOR)
                "A6CEE3",   // lt blue
                "B2DF8A",   // lt green
                "FB9A99",   // lt red
                "FDBF6F",   // lt orangea
                "CAB2D6",   // lt purple
                "010101"]; // clear all colors (FEATURE_CLEAR_COLOR
    return cmap;
  };

  delv.create_discrete_map_from_hex = function(cats, cmap) {
    var cmap_rgb = [];
    var i;
    for (i = 0; i < cmap.length; ++i) {
      cmap_rgb[i] = delv.unhex(cmap[i]);
    }

    return create_discrete_map(cats, cmap_rgb);
  };

  delv.create_discrete_map = function(cats, cols) {
    var num_colors = cols.length;
    var disc_map = new delv.colorMap();
    var i;
    for (i = 0; i < cats.length; i++) {
      disc_map.setColor(cats[i], cols[i % num_colors]);
    }
    return disc_map;
  };

// void testMaps() {
//   DelvContinuousColorMap cmap1 = new DelvContinuousColorMap();
//   cmap1.setDefaultColor(color(130,130,130));
//   HalfOpenRange crange = new HalfOpenRange();
//   crange.setUpper(.3);
//   cmap1.setColor(crange, new green_scale());
//   crange = new HalfOpenRange();
//   crange.setLower(.5);
//   crange.setUpper(.8);
//   cmap1.setColor(crange, new green_to_red());
//   crange = new HalfOpenRange();
//   crange.setLower(.9);
//   crange.setUpper(1.5);
//   cmap1.setColor(crange, new red_to_blue());
//   crange = new HalfOpenRange();
//   crange.setLower(1.6);
//   crange.setUpper(1.9);
//   cmap1.setColor(crange, new brightgreen());
//   cmap1.drawToFile("/tmp/custom_cont_map.png");

//   DelvContinuousColorMap cmap4 = new DelvContinuousColorMap();
//   DelvColorFun checkpts = new ColorMapWithCheckpoints();
//   cmap4.setDefaultColor(color(130,130,130));
//   crange = new HalfOpenRange();
//   crange.setLower(-10);
//   crange.setUpper(20);
//   cmap4.setColor(crange, checkpts);
//   cmap4.drawToFile("/tmp/map_with_checkpoints.png");

//   // create categorical map
//   String[] cat1 = {"a","b","c","d","e","f","g","h","i"};
//   DelvDiscreteColorMap cmap2 = create_discrete_map_from_hex(cat1, categorical_map_1());
//   cmap2.drawToFile("/tmp/cat1.png");

//   String[] cat2 = {"a","b","c","d","e","f","g","h","i","j","k","l"};
//   DelvDiscreteColorMap cmap3 = create_discrete_map_from_hex(cat2, categorical_map_2());
//   cmap3.drawToFile("/tmp/cat2.png");
// }


} ( window.delv = window.delv || {}, Processing, jQuery, vg ) ); // end of delv declaration

