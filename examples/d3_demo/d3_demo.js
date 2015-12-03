// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

function init() {
  console.log("entering init");
  dataLoaded = false;
  d3Array = Array.prototype.slice.call(document.getElementsByTagNameNS("*","svg"));
  for (var j = 0; j < d3Array.length; j++) {
    var id = d3Array[j].getAttribute("id");
    var svgElem = d3Array[j];
    console.log("loading script: " + "" + id + ".js");
    var chart = new delv.d3Chart(id, id, "./"+id+".js", "d3WrapperNS."+id+"_view", init_view_instance);
  }

  canvasArray = Array.prototype.slice.call(document.getElementsByTagNameNS("*","canvas"));
  for (var j = 0; j < canvasArray.length; j++) {
    var id = canvasArray[j].getAttribute("id");
    var canvas = canvasArray[j];
    var sketch = new delv.processingSketch(id, canvas,
					    ["./Globals.pde",
					     "./Attribute.pde",
					     "./Delv.pde",
					     "./BasicRegion.pde", // currently only needed for the RegionView
					     "./"+id+".pde"],
					    id+"View",
					    init_view_instance);
  }     

  // TODO just a demonstration of how to send a signal back to Python
  $( document ).bind("testEventForPython", emitPythonEvent);

  // TODO to get behavior working like releasing a scroll bar while not over a particular view,
  // may need to catch the document-level mouse released event and forward it on to all views
  // otherwise when mouse is moved back into that view, the view will be behaving as if the mouse is still pressed


  console.log("Initializing dataSet");
  // To use data from pyqt, go to the else branch of the following commented-out if statement
  // The following uses a javascript data interface
  //if (typeof(dataSet) === "undefined") {
    console.log("dataSet undefined, so creating from d3_demo_data");
    dataSet = new d3WrapperNS.d3_demo_data("d3Demo");
    dataSet.load_data(finishLoadingJSData);
    
  // } else {
  //   console.log("dataIF exists, so just adding it");
  //   delv.addDataIF(dataIF);
  // }

  resizeAll();
}

function finishLoadingJSData() {
  console.log("finishLoadingJSData called");
  dataLoaded = true;
  //delv.giveDataIFToViews("d3Demo");
}

  
function finishLoadingData() {
  p = Processing.getInstanceById(dataCanvasId);
  try {
	  pDataSet = new p.d3DemoData("d3Demo");
	  dataLoaded = true;
	  delv.log("Test data initialized!!!");
  } catch (e) {
	  delv.log("initializing Test data failed.  Try again later");
	  setTimeout(finishLoadingData, 5);
	  dataLoaded = false;
  }
  if (dataLoaded) {
    pDataSet.loadData();
    pDataSet.bindDelv(delv);
    delv.addDataSet("inSite", pDataSet);
  }  
}
function init_view_instance(view, elemId) {
  delv.log("init_view_instance(" + view + ", " + elemId + ")");
  if (elemId == "Region") {
  delv.log("init_view_instance Region setup");
    aboveDataset = view.createDataset("Nodes");
    aboveDataset.barStartAttr("size")
                .barTagAttr("name")
                .units("loc")
                .defaultRegionType("allNodes")
                .defaultBarHeight("1.0")
                .defaultBarLength("0")
                .defaultBarType("node");
    view.addDataset(aboveDataset, false);

  } else if (elemId == "partition_sunburst_zoom") {
    view.setNodeDatasetName("Nodes")
        .setLinkDatasetName("Links")
        .setNodeSizeAttr("size")
        .setNodeNameAttr("name")
        .setLinkStartAttr("StartNode")
        .setLinkEndAttr("EndNode");

  } else if (elemId == "force_collapsible") {
    view.setNodeDatasetName("Nodes")
        .setLinkDatasetName("Links")
        .setNodeSizeAttr("size")
        .setNodeNameAttr("name")
        .setLinkStartAttr("StartNode")
        .setLinkEndAttr("EndNode");

  } else if (elemId == "bar_hierarchy") {
    view.setNodeDatasetName("Nodes")
        .setLinkDatasetName("Links")
        .setNodeSizeAttr("size")
        .setNodeNameAttr("name")
        .setLinkStartAttr("StartNode")
        .setLinkEndAttr("EndNode");

  } else if (elemId == "tree_interactive") {
    view.setNodeDatasetName("Nodes")
        .setLinkDatasetName("Links")
        .setNodeSizeAttr("size")
        .setNodeNameAttr("name")
        .setLinkStartAttr("StartNode")
        .setLinkEndAttr("EndNode");
  }
  if (dataLoaded) {
    delv.log("init_view_instance onDataChanged");
    view.onDataChanged("dataChanged", "d3Demo.js", "Nodes");
    delv.log("init_view_instance resizeAll");
    resizeAll();
  }
}

function logEvent(evt) {
  console.log("Event " + evt + " logged.");
}

function resizeAll() {
  delv.resizeAll();
}

// kept around in case we need to do this in the future, but not used really right now
function emitPythonEvent(e, name, args) {
  if (typeof(QtWin) != "undefined") {
    if (typeof(e) === "object") {
      console.log("QtWin: " + QtWin + ", event(" + typeof(e) + "): " + name);
      QtWin.emitEvent(name, args);
    }
    else {
      console.log("QtWin: " + QtWin + ", event(" + typeof(e) + "): " + e.toString());
      QtWin.emitEvent(e.toString(), args);
    }
  }
  else {
    console.log("No QtWin yet");
  }
}

