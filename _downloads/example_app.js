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
    console.log("loading script: " + "./" + id + ".js");
    var chart = new delv.d3Chart(id, "./"+id+".js", "d3WrapperNS."+id+"_view", init_view_instance);
  }

  canvasArray = Array.prototype.slice.call(document.getElementsByTagNameNS("*","canvas"));
  for (var j = 0; j < canvasArray.length; j++) {
    var id = canvasArray[j].getAttribute("id");
    var canvas = canvasArray[j];
    var sketch = new delv.processingSketch(canvas,
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

  if (typeof(dataIF) === "undefined") {
    // dataCanvasId = "d3DemoData"
    // var canvas = document.createElement('canvas');
    // canvas.id     = dataCanvasId;
    // canvas.width  = 0;
    // canvas.height = 0;
    // canvas.style.zIndex   = 8;
    // document.body.appendChild(canvas);

    // Processing.loadSketchFromSources(dataCanvasId,
		// 			 ["./Globals.pde",
		// 				"./DelvBasicData.pde",
		// 				"./DelvColorMap.pde",
		// 				"./DelvEnums.java",
		// 			  "./d3DemoData.pde"]);
	  // setTimeout(finishLoadingData, 50);
    dataIF = new d3WrapperNS.d3_demo_data("d3Demo");
    dataIF.load_data();
    delv.giveDataIFToViews("d3Demo");
    delv.reloadData("d3Demo");
    
  } else {
    delv.addDataIF(dataIF, "d3Demo");
  }

  resizeAll();
}

function finishLoadingData() {
  p = Processing.getInstanceById(dataCanvasId);
  try {
	  pDataIF = new p.d3DemoData();
	  dataLoaded = true;
	  delv.log("Test data initialized!!!");
  } catch (e) {
	  delv.log("initializing Test data failed.  Try again later");
	  setTimeout(finishLoadingData, 5);
	  dataLoaded = false;
  }
  if (dataLoaded) {
    pDataIF.loadData();
    pDataIF.setDelvIF(delv);
    delv.addDataIF(pDataIF, "d3Demo");
    delv.giveDataIFToViews("d3Demo");
    delv.reloadData("d3Demo");
  }  
}
function init_view_instance(view, elemId) {
  delv.log("init_view_instance(" + view + ", " + elemId + ")");
  view.dataIF("d3Demo");
  if (elemId == "Region") {
  delv.log("init_view_instance Region setup");
    view.name("d3Demo.Region");
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
    view.setName("d3Demo.partition_sunburst_zoom")
            .setNodeDatasetName("Nodes")
            .setLinkDatasetName("Links")
            .setNodeSizeAttr("size")
            .setNodeNameAttr("name")
            .setLinkStartAttr("StartNode")
            .setLinkEndAttr("EndNode");

  } else if (elemId == "force_collapsible") {
    view.setName("d3Demo.force_collapsible")
            .setNodeDatasetName("Nodes")
            .setLinkDatasetName("Links")
            .setNodeSizeAttr("size")
            .setNodeNameAttr("name")
            .setLinkStartAttr("StartNode")
            .setLinkEndAttr("EndNode");

  } else if (elemId == "bar_hierarchy") {
    view.setName("d3Demo.bar_hierarchy")
            .setNodeDatasetName("Nodes")
            .setLinkDatasetName("Links")
            .setNodeSizeAttr("size")
            .setNodeNameAttr("name")
            .setLinkStartAttr("StartNode")
            .setLinkEndAttr("EndNode");

  } else if (elemId == "tree_interactive") {
    view.setName("d3Demo.tree_interactive")
            .setNodeDatasetName("Nodes")
            .setLinkDatasetName("Links")
            .setNodeSizeAttr("size")
            .setNodeNameAttr("name")
            .setLinkStartAttr("StartNode")
            .setLinkEndAttr("EndNode");
  }
  // if (dataLoaded) {
    delv.log("init_view_instance reloadData");
    view.reloadData("d3Demo.js");
  // }
  delv.log("init_view_instance resizeAll");
  resizeAll();
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

