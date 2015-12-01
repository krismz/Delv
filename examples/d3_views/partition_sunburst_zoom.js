// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

var d3WrapperNS = d3WrapperNS || {};

///////////////////////////////////
//              View             //
///////////////////////////////////

d3WrapperNS.partition_sunburst_zoom_view = function ( name, svgElemId ) {
  // example from d3/examples/partition/partition-sunburst-zoom.html
  // git commit e01f789017e7de784811c7c97edc3ddfc9568111

  var newObj = new delv.d3HierarchyView(name, svgElemId);

  // TODO remove init function, not necessary now that view and mediator are 1
  newObj.init = function() {
    delv.log("Calling partition_sunburst_zoom_view.init(), svgElem: " + this.svgElem);
  };
  newObj.init();

  newObj.connectSignals = function() {
    this._delv.connectToSignal("selectChanged", this._name, "onSelectChanged");
  };

  newObj.selectionChanged = function( selection ) {
    this._delv.log("partition_sunburst_zoom_view.selectionChanged(" + selection + ")");
    ids = [];
    ids[0] = selection;
    this._delv.selectItems(this._name, this._nodeDataset, ids, "PRIMARY");
  };

  newObj.onSelectChanged = function(invoker, dataset, coordination, selectType) {
    if (invoker === this._name) {
      this._delv.log(this._name + ".onSelectChanged("+dataset+", "+coordination+", "+selectType+") triggered by self");
    }
    else {
      this._delv.log(this._name + ".onSelectChanged("+dataset+", "+coordination+", "+selectType+") triggered by "+invoker);
      if (dataset === this._nodeDataset) {
	      if (selectType === "PRIMARY") {
          items = this._delv.getSelectCoords(this._nodeDataset, selectType);
	        if (items.length > 1) {
	          // TODO figure out what to do in this case
	          this._delv.log("partition_sunburst_zoom_view can only handle single selections!!!");
	        }
	        else {
	          selectItem(items[0]);
	        }
        }
      }
    }
  };

  newObj.onDataChanged = function(invoker, dataset) {
    var hierarchy;
    if (dataset === this._nodeDataset || dataset === this._linkDataset) {
       hierarchy = this.convertToHierarchy();
      bindData(hierarchy);
    }
  };

  // TODO figure out how to resize this
var width = 564,
    height = 329,
    radius = Math.min(width, height) / 2;

var x = d3.scale.linear()
    .range([0, 2 * Math.PI]);

var y = d3.scale.sqrt()
    .range([0, 1.8 * radius]);

var color = d3.scale.category20c();

var svgElem;

function createSvgElem() {
  if (svgElemId) {
    svgElem = d3.select("#"+svgElemId);
  } else {
    svgElem = d3.select("#chart").append("svg");
  }
} 
createSvgElem();

var vis = svgElem.attr("width", width)
  .attr("height", height)
    .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

var partition = d3.layout.partition()
    .value(function(d) { return d.size; });

var bundle = d3.layout.bundle();
var root;
var prev_node;

var arc = d3.svg.arc()
    .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x))); })
    .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))); })
    .innerRadius(function(d) { return Math.max(0, y(d.y)); })
    .outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); });

function selected(path, d) {
    path.transition()
    .duration(750)
      .attrTween("d", arcTween(d));

    prev_node = d;
}

newObj.resize = function (w, h) {
  width = w;
  height = h;
  radius = Math.min(w, h) / 2;
  y = d3.scale.sqrt().range([0, radius]);
  svgElem.attr("width", width)
  .attr("height", height);
  vis.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

  if (typeof(root) !== "undefined") {
    var path = vis.selectAll("path");
    selected(path, prev_node);
  }
};

  function isEmpty(obj) {
    var o;
    for (o in obj) {
      if (obj.hasOwnProperty(o)) {
        return false;
      }
    }
    return true;
  }

// TODO: added hard-coded stroke and fill-rule for now, need to figure out a better way to handle style
// TODO: easiest to determine selected item by just setting the id appropriately.  Alternatively, you could figure out
// which path it is the hard way
function bindData(json) {
  root = json;
  if (isEmpty(json)) {
    return;
  }
  var path = vis.data([json]).selectAll("path")
    .data(partition.nodes)
    .enter().append("path")
    .attr("d", arc)
    .attr("id", function(d) { return svgElemId+"_"+d.name; })
    .style("fill", function(d) { return color((d.children ? d : d.parent).name); })
    .style("stroke", "#fff")
    .style("fill-rule", "evenodd")
    .on("click", click);

  function click(d) {
    selected(path, d);
    newObj.selectionChanged(d.name);
  }

  delv.log("bindData partitioning nodes");
  prev_node = partition.nodes(root)[0];
  delv.log("bindData exiting");
}

function get_path(source, target) {
  var nodes = partition.nodes(root);
  var links = [];
  var link = {};
  var source_node_found = false;
  var target_node_found = false;
  var n;
  var paths = {};

  for (n = 0; n < nodes.length; n++) {
    if (nodes[n].name == source) {
      link.source = nodes[n];
      source_node_found = true;
    } else if (nodes[n].name == target) {
      link.target = nodes[n];
      target_node_found = true;
    }
    if (source_node_found && target_node_found) {
      break;
    }
  }

  links[0] = link;
  paths = bundle(links);
  return paths[0];
}

function selectItem(item) {
  var node_path = get_path(prev_node.name, item);
  var going_down = true;
  var cur_node = {};
  var i;
  var path = {};
  if (typeof(node_path) !== "undefined") {
    going_down = true;
    cur_node = node_path[0];
    for (i = 1; i < node_path.length; i++) {
      if (node_path[i].name == cur_node.parent) {
	      going_down = false;
      }
      if (going_down) {
	      path = vis.selectAll("path");
	      selected(path, node_path[node_path.length-1]);
	      break;
      } else {
	      path = vis.selectAll("path");
	      selected(path, node_path[i]);
      }
      cur_node = node_path[i];
    }
  }
}

// Interpolate the scales!
function arcTween(d) {
  var xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]),
      yd = d3.interpolate(y.domain(), [d.y, 1]),
      yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius]);
  return function(d, i) {
    return i
        ? function(t) { return arc(d); }
        : function(t) { x.domain(xd(t)); y.domain(yd(t)).range(yr(t)); return arc(d); };
  };
}

  return newObj;
};
