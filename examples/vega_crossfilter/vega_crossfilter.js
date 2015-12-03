function init() {
  console.log("entering init");
  dataLoaded = false;
  //delv.noLog();
  delv.doSignalDebounce(75);

  var chartsrc = "./bar_chart.json";
  var viewsrc = "./bar_chart.js";
  var constructor = "vgWrapperNS.bar_chart_view";
  var id = "TimeOfDay";
  console.log("creating vega chart: " + id);
  var chart = new delv.vegaChart(id, id, viewsrc, chartsrc, constructor, init_view_instance);
  
  id = "Delay";
  console.log("creating vega chart: " + id);
  chart = new delv.vegaChart(id, id, viewsrc, chartsrc, constructor, init_view_instance);
  
  id = "Distance";
  console.log("creating vega chart: " + id);
  chart = new delv.vegaChart(id, id, viewsrc, chartsrc, constructor, init_view_instance);
  
  id = "Date";
  console.log("creating vega chart: " + id);
  chart = new delv.vegaChart(id, id, viewsrc, chartsrc, constructor, init_view_instance);

  console.log("Initializing dataSet");
  dataSet = new vgWrapperNS.vega_crossfilter_data("vgDemo");
  dataSet.load_data("./data/vega_crossfilter_data.json", finishLoadingJSData);

  resizeAll();
}

function finishLoadingJSData() {
  console.log("finishLoadingJSData called");
  dataLoaded = true;
}

function init_view_instance(view, elemId) {
  delv.log("init_view_instance(" + view + ", " + elemId + ")");
  if (elemId == "TimeOfDay") {
    view.setDatasetName("times")
      .setXAttr("bin_hour")
      .setYAttr("count_delay")
      .setTitle("Time of Day", false)
      .setXDomain([0, 24], false)
      .renderSVG();
    
  } else if (elemId == "Delay") {
    view.setDatasetName("delay")
      .setXAttr("bin_delay")
      .setYAttr("count_delay")
      .setTitle("Delay (min.)", false)
      .setXDomain([-60, 140], false)
      .renderSVG();
    
  } else if (elemId == "Distance") {
    view.setDatasetName("distance")
      .setXAttr("bin_dist")
      .setYAttr("count_delay")
      .setTitle("Distance (mi.)", false)
      .setXDomain([0, 2000], false)
      .renderSVG();

  } else if (elemId == "Date") {
    view.setDatasetName("date")
      .setXAttr("day")
      .setYAttr("count_delay")
      .setTitle("Date", false)
      .setXDomain(["datetime('Jan 1 2001')", "datetime('Mar 31 2001')"], false)
      .xIsDate(true)
      .renderSVG();

  }
  delv.log("init_view_instance , dataLoaded: " + dataLoaded);
  if (dataLoaded) {
    view.onDataChanged("dataChanged", "vega_crossfilter", "times");
    view.onDataChanged("dataChanged", "vega_crossfilter", "distance");
    view.onDataChanged("dataChanged", "vega_crossfilter", "delay");
    view.onDataChanged("dataChanged", "vega_crossfilter", "date");
    resizeAll();
  }
}

function resizeAll() {
  delv.resizeAll();
}
