// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================
function init() {
  // check for HTML5 File API support 
  if (window.File && window.FileReader && window.FileList && window.Blob) {
    // it's supported!
    // set up the listeners
    
    var regionFiles = document.getElementById('region_files');
    regionFiles.addEventListener('change', handleRegionFilesSelect, false);
    regionFiles.addEventListener('dragover', handleRegionFilesDragOver, false);
    regionFiles.addEventListener('drop', handleRegionFilesDrop, false);

  } else {
    alert('The HTML5 File APIs are not fully supported in this browser');
  }

  dataLoaded = false;
  //delv.noLog();
  var readers = [];
  canvasArray = Array.prototype.slice.call(document.getElementsByTagNameNS("*","canvas"));
  for (var j = 0; j < canvasArray.length; j++) {
    var id = canvasArray[j].getAttribute("id");
    var canvasid = j;
    var canvas = canvasArray[j];
    if (id == "DataInterface")  {
	dataCanvasId = id;
	// temp hack to try programming data interface in processing
      Processing.loadSketchFromSources(canvas,
					 ["Globals.pde",
						"Delv.pde",
					  "InSiteData.pde"]);
	setTimeout(finishLoadingData, 50);
	    
    } else {
	    var sketch = new delv.processingSketch(id, canvas,
						["Globals.pde",
						 "Attribute.pde",
						 "Delv.pde",
						 "BasicRegion.pde", // currently only needed for the RegionView
						 "DropDown.pde", // currently only needed for the ColorLegendWithDropdown
						 "ColorPickerLegend.pde", // currently only needed for the ColorLegendWithDropdown
						 ""+id+".pde"],
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
  // delv.addDataIF(dataIF, "inSite");
  //delv.resizeAll();
}

function handleRegionFilesDragOver(evt) {
  evt.dataTransfer.dropEffect = 'link';
}
function handleRegionFilesDrop(evt) {
  var files = evt.dataTransfer.files;
  delv.log("handleRegionFilesDrop files: ");
  delv.log(files);
  readRegionFiles(files);
}
function handleRegionFilesSelect(evt) {
  var files = evt.target.files;
  readRegionFiles(files);
}

// using jQuery promises
function readRegionFile(a_file) {
  // return a promise to read the file
  var d = $.Deferred();
  var reader = new FileReader();
  reader.onload = function(evt) {
    try {
      delv.log("reading Region text");
      pDataSet.readRegionText(evt.target.result);
      d.resolve();
    } catch (e) {
      d.reject();
    }
  }
  reader.readAsText(a_file);
  return d.promise();
}

function readRegionFiles(files) {
  if (typeof(files) !== "undefined") {
    var regionPromises=[];
    pDataSet.clearRegionFiles();
    for (var j = 0; j < files.length; j++) {
      regionPromises[j] = readRegionFile(files[j]);
    }
    $.when.apply($, regionPromises)
      .done(function (responses) { delv.dataChanged("readRegionFiles", "Regions"); });
  }
}

// Once Javascript Promises are more available, use the following.
// Otherwise stick with the jQuery implementation above.
// function readRegionFile(a_file) {
//   // return a promise to read the file
//   return new Promise(function(resolve, reject) {
//     var reader = new FileReader();
//     reader.onload = function(evt) {
//       try {
//         pDataSet.readRegionText(evt.target.result);
//         resolve("region has been read");
//       } catch (e) {
//         reject(e);
//       }
//     }
//     reader.readAsText(a_file);
//   });
// }

// function readRegionFiles(files) {
//   if (typeof(files) !== "undefined") {
//     var regionPromises=[];
//     pDataSet.clearRegionFiles();
//     for (var j = 0; j < files.length; j++) {
//       regionPromises[j] = readRegionFile(files[j]);
//     }
//     Promise.all(regionPromises).then(
//       function(response) {
//         delv.reloadData();
//       },
//       function(error) {
//         delv.log("Failure!!!", error);
//       }
//     );
//   }
// }

// TODO, trouble with processing dataIF is that it doesn't have all the signal connect methods
function finishLoadingData() {
  var p = Processing.getInstanceById(dataCanvasId);
  try {
	  pDataSet = new p.InSiteDataSet("inSite");
	  dataLoaded = true;
	  delv.log("Test data initialized!!!");
  } catch (e) {
	  delv.log("initializing Test data failed.  Try again later");
	  setTimeout(finishLoadingData, 5);
	  dataLoaded = false;
  }
  if (dataLoaded) {
    // TODO add any initialization or customization here
    //pDataSet.clearRegionFiles();
    pDataSet.loadData();
    pDataSet.bindDelv(delv);
    delv.addDataSet("inSite", pDataSet);

  }  
}

function initProcessingSketch(view, canvasId) {

  if (canvasId == "Region") {
    aboveDataset = view.createDataset("Regions");
    aboveDataset.regionTypeAttr("Species")
                .regionLengthAttr("totalLength")
                .barStartAttr("start")
                .barLengthAttr("length")
                .barTypeAttr("motif_type")
                .barHeightAttr("strength")
                .units("bp");
    view.addDataset(aboveDataset, false);

    belowDataset = view.createDataset("Annotations");
    belowDataset.regionTypeAttr("Species")
                .regionLengthAttr("totalLength")
                .barStartAttr("start")
                .barLengthAttr("length")
                .barTagAttr("description")
                .defaultBarType("Annotation");
    view.addDataset(belowDataset, true);

  } else if (canvasId == "DropDown") {
    view.dataSet("Regions")
        .catAttr("Species")
        .title("Species");

  } else if (canvasId == "ColorPickerLegend") {
    view.dataSet("Regions")
        .dataAttr("motif_type");

  } else if (canvasId == "ColorLegendWithDropdown") {
    view.dataSet("Regions")
        .dataAttr("motif_type")
        .title("TF");

  } else if (canvasId == "Alignment") {

  } else if (canvasId == "BarHeight") {
    view.dataSet("Regions")
        .dim1Attr("strength")
        .dim2Attr("motif_type");
  } else {}

  if (dataLoaded) {
    view.onDataChanged("dataChanged", "inSite.js", "Regions");
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

