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

d3WrapperNS.force_collapsible_view = function ( svgId ) {
  var newObj = new delv.d3HierarchyView(svgId);
  //newObj._internal = this;

  newObj.init = function() {
    delv.log("Calling force_collapsible_view.init(), svgElem: " + this.svgElem);
  };
  newObj.init();

  newObj.connectSignals = function() {
    this._delv.connectToSignal("selectChanged", this.svgElem, "onSelectChanged");
  };

  newObj.selectionChanged = function( selection ) {
    this._delv.log("force_collapsible_view.selectionChanged(" + selection + ")");
    ids = [];
    ids[0] = selection;
    this._delv.clearSelect(this.svgElem, this._nodeDataset, "PRIMARY");
    this._delv.selectItems(this.svgElem, this._nodeDataset, ids, "PRIMARY");
  };

  newObj.onSelectChanged = function(invoker, dataset, coordination, selectType) {
    if (invoker === this.svgElem) {
      this._delv.log(this._name + ".onSelectChanged("+dataset+", "+coordination+", "+selectType+") triggered by self");
    }
    else {
      this._delv.log(this._name + ".onSelectChanged("+dataset+", "+coordination+", "+selectType+") triggered by "+invoker);
      if (dataset === this._nodeDataset) {
	      if (selectType === "PRIMARY") {
          items = this._delv.getSelectCoords(this._nodeDataset, selectType);
	        if (items.length > 1) {
	          // TODO figure out what to do in this case
	          this._delv.log("force_collapsible_view can only handle single selections!!!");
	        }
	        else {
	          selectItem(items[0]);
	        }
        }
      }
    }
  };

  newObj.onDataChanged = function() {
    var hierarchy = this.convertToHierarchy();
    bindData(hierarchy);
  };


  // TODO: figure out how to resize this

var width = 564,
    height = 329,
    node,
    link,
    root;

// TODO should linkDistance be based on window size?
var force = d3.layout.force()
    .charge(function(d) { return d.hide_children ? -d.size / 100 : -30; })
    .linkDistance(function(d) { return d.target.hide_children ? 80 : 30; })
    .size([width, height]);

var bundle = d3.layout.bundle();
var all_nodes;

var svgElem;
var svgElemId = svgId;

function createSvgElem() {
  if (svgElemId) {
    svgElem = d3.select("#"+svgElemId);
  } else {
    svgElem = d3.select("#chart").append("svg");
  }
} 
createSvgElem();

var vis = svgElem.attr("width", width)
    .attr("height", height);

newObj.resize = function(w, h) {
  width = w;
  height = h;
  svgElem.attr("width", width)
  .attr("height", height);

  force.size([width, height]);
  if (typeof(root) !== "undefined") {
    root.x = width / 2;
    root.y = height / 2;
    update();
  }
};

var selectedId;

function bindData(json) {
  root = json;
  root.fixed = true;
  root.x = width / 2;
  root.y = height / 2;
  // calling update() here before the collapse
  // seems to help initialize things like position
  // so that later transitions are not bouncing around
  // like crazy.
  update();
  all_nodes = flatten(root);
  collapse(root, 1);
  selectedId = root.name;
  update();
}

// hide all children below level relative to node
function collapse(root_node, level) {
  var i = 0;

  function recurse(node, hide) {
    if (node.children && !node.hide_children) {
      node.size = node.children.reduce(function(p, v) { return p + recurse(v, hide-1); }, 0);
      if (hide <= 0) {
	  node.hide_children = true;
	}
    }
    return node.size;
  }

  root.size = recurse(root_node, level);
}

function update() {
  var nodes = flatten(root),
      links = d3.layout.tree().links(nodes);

  // Restart the force layout.
  force
      .nodes(nodes)
      .links(links)
      .start();

  var filt_links = links.filter( function (d) { return !d.source.hide_children; } );

  // Update the links
  link = vis.selectAll("line.link")
      .data(filt_links, function(d) { return d.target.id; });

  // Enter any new links.
  // TODO figure out how to unhardcode the fill, stroke and stroke-width styles
  link.enter().insert("line", ".node")
      .attr("class", "link")
      .attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; })
      .style("fill", "none")
      .style("stroke", "#9ecae1")
      .style("stroke-width", "1.5px");

  // Exit any old links.
  link.exit().remove();

  // Update the nodes
  node = vis.selectAll("circle.node")
      .data(nodes, function(d) { return d.id; })
      .style("fill", color);

  node.transition()
      .attr("r", function(d) { return (d.children && !d.hide_children) ? 4.5 : Math.sqrt(d.size) / 10.0; });

  // Enter any new nodes.
  // TODO figure out how to unhardcode the cursor, stroke and stroke-width styles
  node.enter().append("circle")
      .attr("class", "node")
      .attr("cx", function(d) { return d.x; })
      .attr("cy", function(d) { return d.y; })
      .attr("r", function(d) { return (d.children && !d.hide_children) ? 4.5 : Math.sqrt(d.size) / 10.0; })
      .attr("id", function(d) { return svgElemId+"_"+d.name; })
      .style("fill", color)
      .style("cursor", "pointer")
      .style("stroke", "#000")
      .style("stroke-width", ".5px")
      .on("click", click)
      .call(force.drag);

  // Exit any old nodes.
  node.exit().remove();

  force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node.attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });
  });
}

// Color leaf nodes orange, and packages white or blue.
// color selected node red
function color(d) {
  return d.name === selectedId ? "#e6550d" : d.hide_children ? "#3182bd" : d.children ? "#c6dbef" : "#fd8d3c";
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
    var cur_node = get_node(item);
      
    if (cur_node.hide_children) {
      cur_node.hide_children = false;
    }
    var still_looking = true;
    while(still_looking) {
      if (typeof(cur_node.parent) === "undefined") {
	still_looking = false;
      } else {
	cur_node = get_node(cur_node.parent);
	if (!cur_node.hide_children) {
	  still_looking = false;
	} else {
	  cur_node.hide_children = false;
	}
      }
    }
    selectedId = item;
    update();
  }
}

function selected(d) {
  selectedId = d.name;
  if (typeof(d.hide_children) === "undefined") {
    d.hide_children = false;
  } else {
    d.hide_children = !d.hide_children;
  }
  update();
}

// Toggle children on click.
function click(d) {
  selected(d);
  newObj.selectionChanged(d.name);
}

// Returns a list of all nodes under the root.
function flatten(root) {
  var nodes = [], i = 0;

  function recurse(node, parent) {
    if (typeof(node.hide_children) === "undefined") {
      node.hide_children = false;
    }
    if (node.children && !node.hide_children) { node.size = node.children.reduce(function(p, v) { return p + recurse(v, node.name); }, 0); }
    if (!node.id) { node.id = ++i; }
    node.parent = parent;
    nodes.push(node);
    return node.size;
  }

  root.size = recurse(root);
  return nodes;
}

  return newObj;

};
