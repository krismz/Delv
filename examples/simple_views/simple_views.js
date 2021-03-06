// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

function init() {
  console.log("entering init");
  dataLoaded = false;
  canvasArray = Array.prototype.slice.call(document.getElementsByTagNameNS("*","canvas"));
  for (var j = 0; j < canvasArray.length; j++) {
    var id = canvasArray[j].getAttribute("id");
    var canvasid = j;
    var canvas = canvasArray[j];
    if (id == "DataInterface")  {
	dataCanvasId = id;
	// temp hack to try programming data interface in processing
        Processing.loadSketchFromSources(canvas,
					 ["./Globals.pde",
            "./Delv.pde",
					  "./InSiteData.pde"]);
	setTimeout(finishLoadingData, 50);
	    
    } else {
	var sketch = new delv.processingSketch(canvas,
						["./Globals.pde",
						 "./Delv.pde",
						 "./"+id+".pde"],
						 id+"View",
						initProcessingSketch);
    }     
  }

  // TODO just a demonstration of how to send a signal back to Python
  $( document ).bind("testEventForPython", emitPythonEvent);

  // TODO to get behavior working like releasing a scroll bar while not over a particular view,
  // may need to catch the document-level mouse released event and forward it on to all views
  // otherwise when mouse is moved back into that view, the view will be behaving as if the mouse is still pressed
    
   // way to load dataIF from pyqt:
  // delv.addDataIF(dataIF, "simpleViews");
  //delv.resizeAll();
}

// TODO, trouble with processing dataIF is that it doesn't have all the signal connect methods
function finishLoadingData() {
  p = Processing.getInstanceById(dataCanvasId);
  try {
	  pDataIF = new p.InSiteData("inSite");
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
    delv.addDataIF(pDataIF);
    delv.giveDataIFToViews("inSite");
    delv.reloadData();
  }  
}

function initProcessingSketch(view, canvasId) {
  console.log("In initProcessingSketch, canvasId: " + canvasId);

  if (canvasId == "Sparkline") {
    view.name("simpleViewsSparkline");

    view.datasetName("Regions")
      .dim1Attr("strength")
      .label("Species");

  } else if (canvasId == "Template200") {
    view.name("simpleViewsTemplate200")
            .datasetName("Regions")
            .dim1Attr("strength")
            .label("Species");
    view.dim2Attr("Species");
  } else {}

  if (dataLoaded) {
      view.dataIF("inSite");
      view.reloadData("simpleViews.js");
  }
    else {
	delv.log("Data hasn't been loaded yet!!!");
    }
  delv.resizeAll();
}

function logEvent(evt) {
  console.log("Event " + evt + " logged.");
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

