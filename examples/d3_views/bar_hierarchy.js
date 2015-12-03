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

d3WrapperNS.bar_hierarchy_view = function ( name, svgId ) {
  var newObj = new delv.d3HierarchyView(name, svgId);

  newObj.init = function() {

  };
  newObj.init();

  newObj.connectSignals = function() {
    this._delv.connectToSignal("selectChanged", this._name, "onSelectChanged");
  };

  newObj.selectionChanged = function( selection ) {
    ids = [];
    ids[0] = selection;
    this._delv.selectItems(this._name, this._nodeDataset, ids, "PRIMARY");
  };

  newObj.onSelectChanged = function(signal, invoker, dataset, coordination, selectType) {
    var items = [];
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
	          this._delv.log("bar_hierarchy_view can only handle single selections!!!");
	        }
	        else {
	          selectItem(items[0]);
	        }
        }
      }
    }
  };

  newObj.onDataChanged = function(signal, invoker, dataset) {
    var hierarchy;
    if (this.configured() &&
        (dataset === this._nodeDataset || dataset === this._linkDataset)) {
      hierarchy = this.convertToHierarchy();
      bindData(hierarchy);
    }
  };


// TODO left margin should really be based on the max width of a node name
var margin = {top: 20, right: 20, bottom: 20, left: 110},
    width = 564 - margin.right - margin.left,
    height = 329 - margin.top - margin.bottom;

var x = d3.scale.linear()
    .range([0, width]);

var y = 20; // bar height

var z = d3.scale.ordinal()
    .range(["steelblue", "#ccc"]); // bar color

var duration = 750,
    delay = 25;

var hierarchy = d3.layout.partition()
    .value(function(d) { return d.size; });

var nodes;

var bundle = d3.layout.bundle();

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("top");

var svgElem;
var svgElemId = svgId;

function createSvgElem() {
  if (svgElemId) {
    svgElem = d3.select("#"+svgElemId);
  } else {
    svgElem = d3.select("body").append("svg");
  }
} 
createSvgElem();


var svg =svgElem.attr("width", width + margin.right + margin.left)
    .attr("height", height + margin.top + margin.bottom)
.style("font", "10px sans-serif")
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

svg.append("rect")
    .attr("class", "background")
    .attr("width", width)
    .attr("height", height)
    .style("fill", "white")
    .on("click", up);

svg.append("g")
    .attr("class", "x axis")
.style("shape-rendering", "crispEdges");

svg.append("g")
    .attr("class", "y axis")
.style("shape-rendering", "crispEdges")
  .append("line")
    .attr("y1", "100%")
.style("fill", "none")
.style("stroke","#000");

newObj.resize = function(w, h) {
  width = w - margin.right - margin.left;
  height = h - margin.top - margin.bottom;
  x.range([0, width]);
  svgElem.attr("width", width + margin.right + margin.left)
  .attr("height", height + margin.top + margin.bottom);
  svg.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  if (typeof(nodes) !== "undefined") {
    svg.selectAll(".x.axis").transition().duration(duration).call(xAxis);
    svg.selectAll("rect")
      .transition()
      .attr("width", function(d) { return x(d.value); });
  }
};

function bindData(json) {
  var root = json;
  nodes = hierarchy.nodes(root);
  x.domain([0, root.value]).nice();
  down(root, 0);
}

function get_path(source, target) {
  var links = [];
  var link = {};
  var source_node_found = false;
  var target_node_found = false;
  var n;
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
  var paths = bundle(links);
  return paths[0];
}

function down(d, i) {
  if (!d.children || this.__transition__) { return; }
  var end = duration + d.children.length * delay;

  // Mark any currently-displayed bars as exiting.
  var exit = svg.selectAll(".enter").attr("class", "exit");

  // Entering nodes immediately obscure the clicked-on bar, so hide it.
  exit.selectAll("rect").filter(function(p) { return p === d; })
      .style("fill-opacity", 1e-6);

  // Enter the new bars for the clicked-on data.
  // Per above, entering bars are immediately visible.
  var enter = bar(d)
      .attr("transform", stack(i))
      .style("opacity", 1);

  // Have the text fade-in, even though the bars are visible.
  // Color the bars as parents; they will fade to children if appropriate.
  enter.select("text").style("fill-opacity", 1e-6).style("font", "10px sans-serif");
  enter.select("rect").style("fill", z(true));

  // Update the x-scale domain.
  x.domain([0, d3.max(d.children, function(d) { return d.value; })]).nice();

  // Update the x-axis.
  svg.selectAll(".x.axis").transition().duration(duration).call(xAxis);

  // Transition entering bars to their new position.
  var enterTransition = enter.transition()
      .duration(duration)
      .delay(function(d, i) { return i * delay; })
      .attr("transform", function(d, i) { return "translate(0," + y * i * 1.2 + ")"; });

  // Transition entering text.
  enterTransition.select("text").style("fill-opacity", 1).style("font", "10px sans-serif");

  // Transition entering rects to the new x-scale.
  enterTransition.select("rect")
      .attr("width", function(d) { return x(d.value); })
      .style("fill", function(d) { return z(!!d.children); });

  // Transition exiting bars to fade out.
  var exitTransition = exit.transition()
      .duration(duration)
      .style("opacity", 1e-6)
      .remove();

  // Transition exiting bars to the new x-scale.
  exitTransition.selectAll("rect").attr("width", function(d) { return x(d.value); });

  // Rebind the current node to the background.
  svg.select(".background").data([d]).transition().duration(end); d.index = i;
}

function up(d) {
  if (!d.parent || this.__transition__) { return; }
  var end = duration + d.children.length * delay;

  // Mark any currently-displayed bars as exiting.
  var exit = svg.selectAll(".enter").attr("class", "exit");

  // Enter the new bars for the clicked-on data's parent.
  var enter = bar(d.parent)
      .attr("transform", function(d, i) { return "translate(0," + y * i * 1.2 + ")"; })
      .style("opacity", 1e-6);

  // Color the bars as appropriate.
  // Exiting nodes will obscure the parent bar, so hide it.
  enter.select("rect")
      .style("fill", function(d) { return z(!!d.children); })
    .filter(function(p) { return p === d; })
      .style("fill-opacity", 1e-6);

  // Update the x-scale domain.
  x.domain([0, d3.max(d.parent.children, function(d) { return d.value; })]).nice();

  // Update the x-axis.
  svg.selectAll(".x.axis").transition().duration(duration).call(xAxis);

  // Transition entering bars to fade in over the full duration.
  var enterTransition = enter.transition()
      .duration(end)
      .style("opacity", 1);

  // Transition entering rects to the new x-scale.
  // When the entering parent rect is done, make it visible!
  enterTransition.select("rect")
      .attr("width", function(d) { return x(d.value); })
    .each("end", function(p) { if (p === d) { d3.select(this).style("fill-opacity", null); } });

  // Transition exiting bars to the parent's position.
  var exitTransition = exit.selectAll("g").transition()
      .duration(duration)
      .delay(function(d, i) { return i * delay; })
      .attr("transform", stack(d.index));

  // Transition exiting text to fade out.
  exitTransition.select("text")
      .style("fill-opacity", 1e-6).style("font", "10px sans-serif");

  // Transition exiting rects to the new scale and fade to parent color.
  exitTransition.select("rect")
      .attr("width", function(d) { return x(d.value); })
      .style("fill", z(true));

  // Remove exiting nodes when the last child has finished transitioning.
  exit.transition().duration(end).remove();

  // Rebind the current parent to the background.
  svg.select(".background").data([d.parent]).transition().duration(end);

  newObj.selectionChanged(d.name);
}

function selectItem(item) {
  svg.select(".background").each( function (d,i) {
      // find common parent
      // up until reach common parent
      // down until reach item
      var path = get_path(d.name, item);
      if (typeof(path) !== "undefined") {
	var going_down = true;
	      var cur_node = path[0];
        var j;
	for (j = 1; j < path.length; j++) {
	  if (path[j].name == cur_node.parent) {
	    going_down = false;
	  }
	  if (going_down) {
	    down(path[j]);
	  } else {
	    up(cur_node);
	  }
	  cur_node = path[j];
	}
      }
    } );
}

function click_down(d) {
  down(d);
  newObj.selectionChanged(d.name);
}

// Creates a set of bars for the given data node, at the specified index.
function bar(d) {
  var br = svg.insert("g", ".y.axis")
      .attr("class", "enter")
      .attr("transform", "translate(0,5)")
    .selectAll("g")
      .data(d.children)
    .enter().append("g")
      .style("cursor", function(d) { return !d.children ? null : "pointer"; })
      .on("click", click_down);

  br.append("text")
      .attr("x", -6)
      .attr("y", y / 2)
      .attr("dy", ".35em")
      .attr("text-anchor", "end")
      .style("font", "10px sans-serif")
      .text(function(d) { return d.tag; });

  br.append("rect")
  .attr("id", function(d) { return svgElemId+"_"+d.name; })
      .attr("width", function(d) { return x(d.value); })
      .attr("height", y);

  return br;
}

// A stateful closure for stacking bars horizontally.
function stack(i) {
  var x0 = 0;
  return function(d) {
    var tx = "translate(" + x0 + "," + y * i * 1.2 + ")";
    x0 += x(d.value);
    return tx;
  };
}

  return newObj;
};
