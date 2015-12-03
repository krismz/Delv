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

d3WrapperNS.tree_interactive_view = function ( name, svgElemId ) {
  var newObj = new delv.d3HierarchyView(name, svgElemId);

  newObj.init = function() {
    delv.log("Calling tree_interactive_view.init(), svgElem: " + this.svgElem);
  };
  newObj.init();

  newObj.connectSignals = function() {
    this._delv.connectToSignal("selectChanged", this._name, "onSelectChanged");
  };

  newObj.selectionChanged = function( selection ) {
    this._delv.log("tree_interactive_view.selectionChanged(" + selection + ")");
    ids = [];
    ids[0] = selection;
    this._delv.selectItems(this._name, this._nodeDataset, ids, "PRIMARY");
  };

  newObj.onSelectChanged = function(signal, invoker, dataset, coordination, selectType) {
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
	          this._delv.log("tree_interactive_view can only handle single selections!!!");
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

// TODO left margin should really be based on the max width of the root node name
var margin = {top: 20, right: 20, bottom: 20, left: 50},
  width = 564 - margin.right - margin.left,
  height = 329 - margin.top - margin.bottom,
    i = 0,
    duration = 500,
    root;

var tree = d3.layout.tree()
  .size([height, width]);
var all_nodes;
var prev_selection;
var diagonal = d3.svg.diagonal()
    .projection(function(d) { return [d.y, d.x]; });

  newObj.resize = function(w, h) {
  width = w - margin.right - margin.left;
  height = h - margin.top - margin.bottom;
  tree = d3.layout.tree()
  .size([height, width]);
  svgElem.attr("width", width + margin.right + margin.left)
  .attr("height", height + margin.top + margin.bottom);
  vis.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  if (typeof(root) !== "undefined") {
    root.x0 = height / 2;
    root.y0 = 0;
    update(prev_selection);
  }
};

var svgElem;
function createSvgElem() {
  if (svgElemId) {
    svgElem = d3.select("#"+svgElemId);
  } else {
    svgElem = d3.select("body").append("svg");
  }
}
createSvgElem();


var vis =svgElem.attr("width", width + margin.right + margin.left)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

function bindData(json) {
  root = json;
  root.x0 = height / 2;
  root.y0 = 0;
  all_nodes = tree.nodes(root);

  function collapse(d) {
    if (d.children) {
      d._children = d.children;
      d._children.forEach(collapse);
      d.children = null;
    }
  }

  root.children.forEach(collapse);
  update(root);
}

function update(source) {

  // Compute the new tree layout.
  var nodes = tree.nodes(root).reverse();

  // Normalize for fixed-depth.
//   nodes.forEach(function(d) { d.y = d.depth * 180; });
  nodes.forEach(function(d) { d.y = d.depth * 115; });

  // Update the nodes
  var node = vis.selectAll("g.node")
      .data(nodes, function(d) { return d.id || (d.id = ++i); });

  // Enter any new nodes at the parent's previous position.
  var nodeEnter = node.enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
      .on("click", click);

  // TODO figure out how to handle style better
  nodeEnter.append("circle")
      .attr("r", 1e-6)
    .attr("id", function(d) { return svgElemId+"_"+d.name; })
    .style("cursor","pointer")
    .style("stroke","steelblue")
    .style("stroke-width", "1.5px")
    .style("fill", function(d) { return d.name === source.name ? "#e6550d" : d._children ? "lightsteelblue" : "#fff"; });

  nodeEnter.append("text")
       .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
//      .attr("x", function(d) { return d.children || d._children ? -5 : 5; })
      .attr("dy", ".35em")
      .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
      .text(function(d) { return d.tag; })
    .style("font", "10px sans-serif")
      .style("fill-opacity", 1e-6);

  // Transition nodes to their new position.
  var nodeUpdate = node.transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

  nodeUpdate.select("circle")
      .attr("r", 4.5)
      .style("fill", function(d) { return d.name === source.name ? "#e6550d" : d._children ? "lightsteelblue" : "#fff"; });

  nodeUpdate.select("text")
      .style("fill-opacity", 1);

  // Transition exiting nodes to the parent's new position.
  var nodeExit = node.exit().transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
      .remove();

  nodeExit.select("circle")
      .attr("r", 1e-6);

  nodeExit.select("text")
      .style("fill-opacity", 1e-6);

  // Update the links
  var link = vis.selectAll("path.link")
      .data(tree.links(nodes), function(d) { return d.target.id; });

  // Enter any new links at the parent's previous position.
  link.enter().insert("path", "g")
      .attr("class", "link")
    .style("fill","none")
    .style("stroke","#ccc")
    .style("stroke-width","1.5px")
      .attr("d", function(d) {
        var o = {x: source.x0, y: source.y0};
        return diagonal({source: o, target: o});
      });

  // Transition links to their new position.
  link.transition()
      .duration(duration)
      .attr("d", diagonal);

  // Transition exiting nodes to the parent's new position.
  link.exit().transition()
      .duration(duration)
      .attr("d", function(d) {
        var o = {x: source.x, y: source.y};
        return diagonal({source: o, target: o});
      })
      .remove();

  // Stash the old positions for transition.
  nodes.forEach(function(d) {
    d.x0 = d.x;
    d.y0 = d.y;
  });

  prev_selection = source;
}

  function get_node(name) {
    var n;
  for (n = 0; n < all_nodes.length; n++) {
    if (all_nodes[n].name === name) {
      return all_nodes[n];
    }
  }
  return;
}

function selectItem(item) {
  var node = vis.select("#"+svgElemId+"_"+item)
  .each(selected);

  if (node.empty()) {
    // need to expand until we reach item.
    
    var item_node = get_node(item);
    var cur_node = item_node;
 
    if (cur_node._children) {
      cur_node.children = cur_node._children;
      cur_node._children = null;
    }
    var still_looking = true;
    while(still_looking) {
      if (typeof(cur_node.parent) === "undefined") {
	still_looking = false;
      } else {
	cur_node = get_node(cur_node.parent.name);
	if (cur_node.children) {
	  still_looking = false;
	} else {
	  if (cur_node._children) {
	    cur_node.children = cur_node._children;
	    cur_node._children = null;
	  }
	}
      }
    }
    update(item_node);
  }
}

function selected(d) {
  if (d.children) {
    d._children = d.children;
    d.children = null;
  } else {
    d.children = d._children;
    d._children = null;
  }
  update(d);
}

// Toggle children on click.
function click(d) {
  selected(d);
  newObj.selectionChanged(d.name);
}

  return newObj;
};
