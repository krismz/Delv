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
  var views = {};

  var p5s = {};

  var dataSources = {};

  // public
  delv.signalHandlers = {};

  // turn obj into a delv view
  delv.view = function() {
    this._name = "";
    this._dataIF = {};
    this.dataIF = function(dataIFName) {
      this._dataIF = delv.getDataIF(dataIFName);
    };
    this.getName = function() {
      return this._name;
    };
    this.setName = function(name) {
      this._name = name;
      return this;
    };
    this.resize = function(w, h) {};
    this.connectSignals = function() {};
    this.reloadData = function(source) {};
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
      // delv.connectToSignal("selectedIdsChanged", this._name, "onSelectedIdsChanged");
      delv.connectToSignal("categoryColorsChanged", this._name, "onCategoryColorsChanged");
      // TODO add other signals here.

    };
    newObj.onCategoryColorsChanged = function(invoker, dataset, attribute) {
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
      var cats = this._dataIF.getAllCategories(fromDS, fromAttr);
      var colors = this._dataIF.getAllCategoryColors(fromDS, fromAttr);
      var ii;
      for (ii = 0; ii < cats.length; ii++) {
        this._dataIF.updateCategoryColor(this._name, toDS, toAttr, cats[ii], colors[ii]);
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
      var node_ids = this._dataIF.getAllIds(this._nodeDataset, this._nodeNameAttr);
      var node_names = this._dataIF.getAllItems(this._nodeDataset, this._nodeNameAttr);
      var node_sizes = this._dataIF.getAllItems(this._nodeDataset, this._nodeSizeAttr);

      var link_start = this._dataIF.getAllItems(this._linkDataset, this._linkStartAttr);
      var link_end = this._dataIF.getAllItems(this._linkDataset, this._linkEndAttr);

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

    finishSpecLoad = function(chart, view) {
      view.chart = chart({el:"#"+view.elem});
      view.addListeners();
      view.chart.renderer(view._renderer).update();
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

    newObj.updateSignal = function(signal, val, doParse) {
      if (typeof(this.chart) !== "undefined") {
        this.chart.signal(signal, val);
      } else if (typeof(val) === typeof({})) {
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

    newObj.updateScaleType = function(scale, scaletype, doParse) {
      // TODO updates top-level scales only.  For more specific use, probably need to override on case-by-case basis
      var scales = this.spec["marks"][0]["scales"];
      for (var ii = 0; ii < scales.length; ii++) {
        if (scales[ii]["name"] === scale) {
          scales[ii]["type"] = scaletype;
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
	      view.connectSignals();
	      delv.addView(view, elemId);
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
        view.connectSignals();
        delv.addView(view, elemId);
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
	        p._view.connectSignals();
	        delv.addView(p._view, canvasId);
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

  debounce = function(fn, timeout) {
    var timeoutID = -1;
    return function() {
      if (timeoutID > -1) {
	window.clearTimeout(timeoutID);
      }
      timeoutID = window.setTimeout(fn, timeout);
    };
  };

  var debounced_resize =  debounce(function() { do_resize();}, 75);

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
    views[id] = view;
    return delv;
  };

  delv.addP5Instance = function(p, id) {
    p5s[id] = p;
    return delv;
  };
  
  // a hacky function to deal with asychronicity between data load and view load
  delv.giveDataIFToViews = function (dataIFName) {
    var view;
    for (view in views) {
      if (views.hasOwnProperty(view)) {
        views[view].dataIF(dataIFName);
      }
    }
  };	

  delv.connectToQt = function() {
    // Use QtWebKit to connect.  This method should be called from the Qt side of the QtWebKit bridge
    var dataIF;
    for (dataIF in dataSources) {
      if (dataSources.hasOwnProperty(dataIF)) {
        dataSources[dataIF].categoryVisibilityChanged.connect(delv, delv.handleSignal);
        dataSources[dataIF].categoryColorsChanged.connect(delv, delv.handleSignal);
        dataSources[dataIF].hoveredCategoryChanged.connect(delv, delv.handleSignal);
        dataSources[dataIF].highlightedCategoryChanged.connect(delv, delv.handleSignal);

        dataSources[dataIF].selectedIdsChanged.connect(delv, delv.handleSignal);
        dataSources[dataIF].highlightedIdChanged.connect(delv, delv.handleSignal);
        dataSources[dataIF].hoveredIdChanged.connect(delv, delv.handleSignal);
      }
    }
  };

  delv.addDataIF = function (dataIF) {
    console.log("Adding dataIF: " + dataIF.getName());
    dataSources[dataIF.getName()] = dataIF;
    // TODO, the current new way is to have the dataIF call delv.emitSignal, but this requires delv and dataIF to each know about the other.  Is it ok to have them so closely coupled?
    return delv;
  };

  delv.getDataIF = function (id) {
    return dataSources[id];
  };

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

  delv.emitSignal = function(signal, invoker, dataset, attribute) {
    delv.handleSignal(signal, invoker, dataset, attribute);
  };

  delv.handleSignal = function(signal, invoker, dataset, attribute) {
    var key;
    var view;
    var method;
    var fullcall;
    delv.log("handleSignal(" + signal + ", " + invoker + ", " + dataset + ", " + attribute + ")");
    delv.log("typeof invoker: " + typeof(invoker));
    delv.log("typeof dataset: " + typeof(dataset));
    delv.log("typeof attribute: " + typeof(attribute));
    try {
      for (key in delv.signalHandlers[signal]) {
        if (delv.signalHandlers[signal].hasOwnProperty(key)) {
          try {
            view = views[key];
            delv.log("key: " + key);
            delv.log("typeof view: " + typeof(view));
            method = delv.signalHandlers[signal][key];
            fullcall = "view." + method + "(invoker, dataset, attribute)";
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

  // a basic implementation of the delv data interface
  delv.data = function(nm) {
    var delvIF = {};
    var data = {};
    var name = nm;

    this.setName = function(nm) {
      name = nm;
      return this;
    };
    this.getName = function() {
      return name;
    };

    this.setDelvIF = function(dlv) {
      delvIF = dlv;
      return this;
    };

    this.addDataSet = function(name) {
      var ds = new delv.dataSet(name);
      data[name] = ds;
      return ds;
    };

    this.addAttribute = function(dataset, attr) {
      try {
        data[dataset].addAttribute(attr);
      } catch (e) {
        return;
      }
    };

    this.updateSelectedIds = function(invoker, dataset, ids) {
      try {
        data[dataset].updateSelectedIds(ids);
        delvIF.emitSignal('selectedIdsChanged', invoker, dataset, ids);
      } catch (e) {
        return;
      }
    };

    this.updateHighlightedId = function(invoker, dataset, id) {
      try {
        data[dataset].updateHighlightedId(id);
        delvIF.emitSignal('highlightedIdChanged', invoker, dataset, id);
      } catch (e) {
        return;
      }
    };

    this.updateHoveredId = function(invoker, dataset, id) {
      try {
        data[dataset].updateHoveredId(id);
        delvIF.emitSignal('hoveredIdChanged', invoker, dataset, id);
      } catch (e) {
        return;
      }
    };

// TODO subtle here, decide how to track visibility changed this way correctly in DataSet
//   this.updateItemVisibility = function(invoker, dataset, id) {
//      data[dataset].updateItemVisibility(id);
//       delvIF.emitSignal('itemVisibilityChanged', invoker, dataset, id);
//  }

    this.updateHighlightedCategory = function(invoker, dataset, attr, cat) {
      try {
        data[dataset].updateHighlightedCategory(attr, cat);
        delvIF.emitSignal('highlightedCategoryChanged', invoker, dataset, attr);
      } catch (e) {
        return;
      }
    };

    this.updateHoveredCategory = function(invoker, dataset, attr, cat) {
      if (data.hasOwnProperty(dataset)) {
        data[dataset].updateHoveredCategory(attr, cat);
        delvIF.emitSignal('hoveredCategoryChanged', invoker, dataset, attr);
      }
    };

    this.updateCategoryVisibility = function(invoker, dataset, attr, cat) {
      if (data.hasOwnProperty(dataset)) {
        data[dataset].updateCategoryVisibility(attr, cat);
        delvIF.emitSignal('categoryVisibilityChanged', invoker, dataset, attr);
      }
    };

  this.updateCategoryColor = function(invoker, dataset, attr, cat, color) {
    if (color) {
      data[dataset].updateCategoryColor(attr, cat, color);
      delvIF.emitSignal('categoryColorsChanged', invoker, dataset, attr);
    }
  }

    this.setItem = function(dataset, attr, id, item) {
      if (data.hasOwnProperty(dataset)) {
        data[dataset].setItem(attr, id, item);
      }
    };

    this.getAllItems = function(dataset, attr) {
      try {
        return data[dataset].getAllItems(attr);
      } catch (e) {
        delv.log("getAllItems(" + dataset + ", " + attr + ") caught exception: " + e);
        return [];
      }
    };

    this.getAllItemsAsFloat = function(dataset, attr) {
      if (data.hasOwnProperty(dataset)) {
        return data[dataset].getAllItemsAsFloat(attr);
      } else {
        return [];
      }
    };

    this.getAllIds = function(dataset, attr) {
      if (data.hasOwnProperty(dataset)) {
        return data[dataset].getAllIds(attr);
      } else {
        return [];
      }
    };

    this.getSelectedItems = function(dataset, attr) {
      if (data.hasOwnProperty(dataset)) {
        return data[dataset].getSelectedItems(attr);
      } else {
        return [];
      }
    };

    this.getItem = function(dataset, attr, id) {
      if (data.hasOwnProperty(dataset)) {
        return data[dataset].getItem(attr, id);
      } else {
        return "";
      }
    };

    this.getItemAsFloat = function(dataset, attr, id) {
      if (data.hasOwnProperty(dataset)) {
        return data[dataset].getItemAsFloat(attr, id);
      } else {
        return null;
      }
    };

    this.getAllCategories = function(dataset, attr) {
      // return unique set of values from categorical data
      try {
        return data[dataset].getAllCategories(attr);
      } catch (e) {
        delvIF.log("getAllCategories received exception: " + e);
        return [];
      }
    };

    this.getVisibleCategories = function(dataset, attr) {
      try {
        return data[dataset].getVisibleCategories(attr);
      } catch (e) {
      delvIF.log("getVisibleCategories received exception: " + e);
        return [];
      }
    };

    this.getAllCategoryColors = function(dataset, attr) {
    // return unique set of values from categorical data
      try {
        return data[dataset].getAllCategoryColors(attr);
      } catch (e) {
        delvIF.log("getAllCategoryColors received exception: " + e);
        return [];
      }
    };

    this.getVisibleCategoryColors = function(dataset, attr) {
      try {
        return data[dataset].getVisibleCategoryColors(attr);
      } catch (e) {
        delvIF.log("getVisibleCategoryColors received exception: " + e);
        return [];
      }
    };

    this.getAllCategoryColorMaps = function(dataset, attr) {
    // return unique set of values from categorical data
      try {
        return data[dataset].getAllCategoryColorMaps(attr);
      } catch (e) {
        delvIF.log("getAllCategoryColorMaps received exception: " + e);
        return [];
      }
    };

    this.getHoveredCategory = function(dataset, attr) {
      try {
        return data[dataset].getHoveredCategory(attr);
      } catch (e) {
        delvIF.log("getHoveredCategory received exception: " + e);
        return [];
      }
    };

    this.getAttributes = function(dataset) {
      return data[dataset].getAttributes();
    };

    this.getHighlightedId = function(dataset) {
      return data[dataset].getHighlightedId();
    };

    this.getHoveredId = function(dataset) {
      return data[dataset].getHoverId();
    };

    this.hasId = function(dataset, id) {
      return data[dataset].hasId(id);
    };

    this.setVisibleMin = function(dataset, attr, val) {
      try {
        data[dataset].setVisibleMin(attr, val);
      } catch (e) {
        delvIF.log("setVisibleMin received exception: " + e);
      }
    };
    this.setVisibleMax = function(dataset, attr, val) {
      try {
        data[dataset].getVisibleMax(attr, val);
      } catch (e) {
        delvIF.log("setVisibleMax received exception: " + e);
      }
    };
    this.getVisibleMin = function(dataset, attr) {
      try {
        return data[dataset].getVisibleMin(attr);
      } catch (e) {
        delvIF.log("getVisibleMin received exception: " + e);
        return {};
      }
    };
    this.getVisibleMax = function(dataset, attr) {
      try {
        return data[dataset].getVisibleMax(attr);
      } catch (e) {
        delvIF.log("getVisibleMax received exception: " + e);
        return {};
      }
    };
    this.getMin = function(dataset, attr) {
      try {
        return data[dataset].getMin(attr);
      } catch (e) {
        delvIF.log("getMin received exception: " + e);
        return {};
      }
    };
    this.getMax = function(dataset, attr) {
      try {
        return data[dataset].getMax(attr);
      } catch (e) {
        delvIF.log("getMax received exception: " + e);
        return {};
      }
    };


  }; // end delv.data

  delv.dataSet = function(name) {
    var itemIds = [];
    var attributes = {};
    var highlightedId = "";
    var hoverId = "";
    this.name = name;

    this.addId = function(id) {
      var newId = new delv.itemId(id);
      itemIds[itemIds.length] = newId;
    };

    this.clearItems = function() {
      for (attr in attributes) {
        if (attributes.hasOwnProperty(attr)) {
          attributes[attr].clear();
        }
      }
      itemIds = [];
    };
    this.clearAttributes = function() {
      attributes={};
    };
    
    this.getSelectedIds = function() {
      var ids = [];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.selected) {
          ids[ids.length] = id.name;
        }
      }
      return ids;
    };

    this.getVisibleIds = function() {
      var ids = [];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.visible) {
          ids[ids.length] = id.name;
        }
      }
      return ids;
    };

    this.getHighlightedId = function() {
      return highlightedId;
    };

    this.getHoverId = function() {
      return hoverId;
    };

    this.hasId = function(id) {
      var i;
      for (i = 0; i < itemIds.length; i++) {
        if (itemIds[i].name === id) {
          return true;
        }
      }
      return false;
    };

    this.setItem = function(attrName, id, item) {
      if (!this.hasId(id)) {
        this.addId(id);
      }
      attributes[attrName].setItem(id, item);
    };

    this.addAttribute = function(attr) {
      attributes[attr.name] = attr;
    };

    this.getAttributes = function() {
      var keys = [];
      var attr;
      for (attr in attributes) {
        if (attributes.hasOwnProperty(attr)) {
          keys[keys.length] = attr;
        }
      }
      return keys;
    };

    this.getAllCategories = function(attr) {
      return attributes[attr].getAllCategories();
    };

    this.getVisibleCategories = function(attr) {
      return attributes[attr].getVisibleCategories();
    };
  
    this.getAllCategoryColors = function(attr) {
      return attributes[attr].getAllCategoryColors();
    };

    this.getVisibleCategoryColors = function(attr) {
      return attributes[attr].getVisibleCategoryColors();
    };

    this.getAllCategoryColorMaps = function(attr) {
      return attributes[attr].getAllCategoryColorMaps();
    };

    this.getItemColor = function(attr, id) {
      return attributes[attr].getItemColor(id);
    };
    this.getHighlightedCategory = function(attr) {
      return attributes[attr].getHighlightedCategory();
    };
    this.getHoveredCategory = function(attr) {
      return attributes[attr].getHoveredCategory();
    };

    this.getAllItems = function(attr) {
      var items = [];
      var i;
      for (i = 0; i < itemIds.length; i++) {
        items[i] = attributes[attr].getItem(itemIds[i].name);
      }
      return items;
    };

    this.getAllItemsAsFloat = function(attr) {
      // TODO better to handle here, to keep order uniform based on ids?
      var items = [];
      var i;
      for (i = 0; i < itemIds.length; i++) {
        items[i] = attributes[attr].getItemAsFloat(itemIds[i].name);
      }
      return items;
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

    this.getAllItemsAndIds = function(attr) {
      return attributes[attr].getAllIdsAndItems();
    };

    this.getSelectedItems = function(attr) {
      var items=[];
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (id.selected) {
          items[items.length] = attributes[attr].getItem(id.name);
        }
      }
      return items;
    };
    
    this.getItem = function(attr, id) {
      return attributes[attr].getItem(id);
    };

    this.getItemAsFloat = function(attr, id) {
      return attributes[attr].getItemAsFloat(id);
    };

    this.updateCategoryVisibility = function(attr, category) {
      attributes[attr].toggleVisibility(category);
      determineItemVisibility();
    };

    this.updateCategoryColor = function(attr, cat, rgbColor) {
      attributes[attr].setCategoryColor(cat, rgbColor);
    };

    this.updateHighlightedCategory = function(attr, cat) {
      attributes[attr].updateHighlightedCategory(cat);
    };

    this.updateHoveredCategory = function(attr, cat) {
      attributes[attr].updateHoveredCategory(cat);
    };

    this.determineItemVisibility = function() {
      var i;
      var id;
      var attr;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        id.visible = true;
        for (attr in attributes) {
          if (attributes.hasOwnProperty(attr)) {
            if (!attributes[attr].isItemVisible(id.name)) {
              id.visible = false;
              break;
            }
          }
        }
      }
    };
            
    this.updateSelectedIds = function(ids) {
      var i;
      var id;
      for (i = 0; i < itemIds.length; i++) {
        id = itemIds[i];
        if (ids.hasOwnProperty(id.name)) {
          itemIds[i].selected = true;
        } else {
          itemIds[i].selected = false;
        }
      }
    };

    this.updateHighlightedId = function(id) {
      highlightedId = id;
    };

    this.updateHoveredId = function(id) {
      hoveredId = id;
    };

    this.setVisibleMin = function(attr, val) {
      attributes[attr].setVisibleMin(val);
    };
    this.setVisibleMax = function(attr, val) {
      attributes[attr].setVisibleMax(val);
    };
    this.getVisibleMin = function(attr) {
      return attributes[attr].getVisibleMin();
    };
    this.getVisibleMax = function(attr) {
      return attributes[attr].getVisibleMax();
    };
    this.getMin = function(attr) {
      return attributes[attr].getMin();
    };
    this.getMax = function(attr) {
      return attributes[attr].getMax();
    };

  }; // end delv.dataSet

  // TODO add a datatype for date / time?
  delv.AttributeType = {
    UNSTRUCTURED: {name: "UNSTRUCTURED"},
    CATEGORICAL: {name: "CATEGORICAL"},
    CONTINUOUS: {name: "CONTINUOUS"}
  }; 

  delv.attribute = function(attr_name, attr_type, color_map, data_range) {
    var items = {};
    var floatItems = {};
    var floatArrayItems = [];
    var floatArrayMap = {};
    var type = attr_type;
    var colorMap = color_map;
    var fullRange = data_range;
    var visibleRange = data_range;
    var highlightCategory = "";
    var hoverCategory = "";
    this.name = attr_name;

    this.clear = function() {
      items = {};
      floatItems = {};
      floatArrayItems = [];
      floatArrayMap = {};
    };
    
    this.setItem = function(id, item) {
      var val;
      if (type === delv.AttributeType.CATEGORICAL) {
        items[id] = item;
        fullRange.addCategory(item);
        visibleRange.addCategory(item);
      } else if (type === delv.AttributeType.CONTINUOUS) {
        val = parseFloat(item);
        floatItems[id] = val;
        fullRange.update(val);
      } else if (type === delv.AttributeType.FLOAT_ARRAY) {
      // TODO fix this
      delv.log("Cannot set a FLOAT_ARRAY from String");
      } else {
        items[id] = "" + item;
        // TODO handle fullRange / visibleRange for unstructured data
      }
    };

    this.setFloatItem = function(id, item) {
      if (type === delv.AttributeType.CONTINUOUS) {
        floatItems[id] = item;
        fullRange.update(item);
      }
    };

    this.setFloatArrayItem = function(id, item) {
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
    
    this.getItem = function(id) {
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

    this.getItemAsFloat = function(id) {
      if (type === delv.AttributeType.CONTINUOUS) {
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

    this.getItemAsFloatArray = function(id) {
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
      if (type === delv.AttributeType.CONTINUOUS) {
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

    this.updateHighlightedCategory = function(cat) {
      highlightCategory = cat;
    };

    this.updateHoveredCategory = function(cat) {
      hoverCategory = cat;
    };

    this.getHighlightedCategory = function() {
      return highlightCategory;
    };

    this.getHoveredCategory = function() {
      return hoverCategory;
    };

    this.toggleVisibility = function(cat) {
      if (type === delv.AttributeType.CATEGORICAL) {
        visibleRange.toggleVisibility(cat);
      }
    };

    this.getAllCategories = function() {
      if (type === delv.AttributeType.CATEGORICAL) {
        return fullRange.getCategories();
      } else {
      return [];
      }
    };

    this.getVisibleCategories = function() {
      if (type === delv.AttributeType.CATEGORICAL) {
        return visibleRange.getVisibleCategories();
      } else {
        return [];
      }
    };

    this.getAllCategoryColors = function() {
      var cats = this.getAllCategories();
      var colors = [];
      var i;
      var c;
      for (i = 0; i < cats.length; i++) {
        colors[i] = colorMap.getColor(cats[i]);
      }
      return colors;
    };

    this.getVisibleCategoryColors = function() {
      var cats = this.getVisibleCategories();
      var colors = [];
      var cat;
      var c;
      var i;
      for (i = 0; i < cats.length; i++) {
        colors[i] = colorMap.getColor(cats[i]);
      }
      return colors;
    };

    this.getAllCategoryColorMaps = function() {
      // TODO return colorMap or return colorMap.getColor?
      // for now return getColor, see how this works when playing with Processing/Java
      return colorMap.getColor;
    };

    this.getItemColor = function(id) {
      return colorMap.getColor(getItem(id));
    };

    // TODO right way to construct color obj?
    this.setCategoryColor = function(cat, rgbColor) {
      if (type === delv.AttributeType.CATEGORICAL) {
        colorMap.setColor(cat, [rgbColor[0].toString(), rgbColor[1].toString(), rgbColor[2].toString()]);
      }
    };

    this.updateVisibility = function(item) {
      if (type === delv.AttributeType.CONTINUOUS) {
        visibleRange.update(parseFloat(item));
      }
    };

    // this.getVisibleRange = function() {
    //   if (type === delv.AttributeType.CONTINUOUS) {
    //     return visibleRange;
    //   }
    // }

  // this.setVisibleRange = function(vrange) {
  //   if (type = delv.AttributeType.CONTINUOUS) {
  //     visibleRange = vrange;
  //   }
  // }

    this.isItemVisible = function(id) {
      if (type === delv.AttributeType.CATEGORICAL) {
      return visibleRange.isCategoryVisible(items[id]);
      } else if (type === delv.AttributeType.CONTINUOUS) {
        return visibleRange.isInRange(floatItems[id]);
      } else {
        // TODO fix this, UNSTRUCTURED data is always visible for now
        return true;
      }
    };

    this.setVisibleMin = function(val) {
      visibleRange.setMin(val);
    };
    this.setVisibleMax = function(val) {
      visibleRange.setMax(val);
    };
    this.getVisibleMin = function() {
      return visibleRange.getMin();
    };
    this.getVisibleMax = function() {
      return visibleRange.getMax();
    };
    this.getMin = function() {
      return fullRange.getMin();
    };
    this.getMax = function() {
      return fullRange.getMax();
    };
    
  }; // end delv.attribute

  delv.itemId = function(id) {
    // want these all to be public
    this.name = id;
    this.visible = true;
    this.selected = false;

    this.toggleVisibility = function() {
      visible = !visible;
    };

    this.toggleSelection = function() {
      selected = !selected;
    };
  }; // end delv.itemId

  delv.dataRange = function() {
    var categories = [];
    var visible = {};

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
      visible[cat] = true;
    };

    this.getCategories = function() {
      return categories;
    };

    this.getVisibleCategories = function() {
      var vis = [];
      var cat;
      var i;
      for (i = 0; i < categories.length; i++) {
        cat = categories[i];
        if (visible[cat]) {
          vis[vis.length] = cat;
        }
      }
      return vis;
    };

    this.getInvisibleCategories = function() {
      var vis = [];
      var cat;
      var i;
      for (i = 0; i < categories.length; i++) {
        cat = categories[i];
        if (!visible[cat]) {
          vis[vis.length] = cat;
        }
      }
      return vis;
    };

    this.toggleVisibility = function(cat) {
      visible[cat] = !visible[cat];
    };

    this.isCategoryVisible = function(cat) {
      return visible[cat];
    };
  }; // end delv.dataRange

  delv.continuousRange = function() {
    var min;
    var max;
    var _hasMin = false;
    var _hasMax = false;

    this.hasMin = function() {
      return _hasMin;
    };
    this.hasMax = function() {
      return _hasMax;
    };

    this.getMin = function() {
      return min;
    };
    this.getMax = function() {
      return max;
    };

    this.setMin = function(val) {
      min = val;
      _hasMin = true;
    };
    this.setMax = function(val) {
      max = val;
      _hasMax = true;
    };

    this.updateMin = function(val) {
      if (!_hasMin || val < min) {
        min = val;
        _hasMin = true;
      }
    };
    this.updateMax = function(val) {
      if (!_hasMax || val < max) {
        max = val;
        _hasMax = true;
      }
    };

    this.update = function(val) {
      this.updateMin(val);
      this.updateMax(val);
    };

    this.isInRange = function(val) {
      if (!_hasMin) {
        if (!_hasMax) {
          return true;
        } else {
          return (val <= max);
        }
      } else if (!_hasMax) {
        return (min <= val);
      } else {
        return (min <= val && val <= max);
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
    // TODO what about alpha?  Should color be 4 values, not 3?
    if (start.length >= 3 && end.length >= 3) {
      r[0] = interp1(start[0], end[0], value, maximum);
      r[1] = interp1(start[1], end[1], value, maximum);
      r[2] = interp1(start[2], end[2], value, maximum);
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
    // assumes inputs are RGB arrays
    // use algorithm from http://stackoverflow.com/questions/168838/color-scaling-function
    // convert everything to HSV
    // interpolate
    // convert back to RGB
    var start_hsv = rgb2hsv(red(start)/255.0,green(start)/255.0,blue(start)/255.0);
    var end_hsv = rgb2hsv(red(end)/255.0,green(end)/255.0,blue(end)/255.0);
    var interp_hsv = interp3(start_hsv, end_hsv, value, 1);
    var interp_rgb = hsv2rgb(interp_hsv[0], interp_hsv[1], interp_hsv[2]);
    // TODO how to handle color object?
    var rgb = color( Math.round(interp_rgb[0] * 255),
                     Math.round(interp_rgb[1] * 255),
                     Math.round(interp_rgb[2] * 255) );
    return rgb;
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
                "FDBF6F",   // lt orange
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

