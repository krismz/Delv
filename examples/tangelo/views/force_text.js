/* globals tangeloViews */
var tangeloViews = tangeloViews || {};

///////////////////////////////////
//              View             //
///////////////////////////////////

tangeloViews.force_text_view = function ( svgElem ) {

  var link,
  node,
  charge,
  scaler,
  that,
  cards,
  svg,
  svgId,
  width,
  height,
  nodeCharge,
  textCharge,
  force,
  fade_time,
  cfg,
  color,
  selectedId;

  svgId = svgElem;
  
  width = 200;
  height = 200;
  nodeCharge = -120;
  textCharge = -600;
  // Duration of fade-in/fade-out transitions.
  fade_time = 500;
  force = d3.layout.force()
    .linkDistance(30)
    .size([width, height]);

  var newObj = new delv.d3HierarchyView(svgElem);
  newObj._nodeTypeAttr = "";
  newObj._linkSizeAttr = "";
  newObj.config = {};
  newObj.nodes = [];
  newObj.links = [];

  newObj.init = function() {
  };
  newObj.init();

  newObj.getNodeTypeAttr = function() {
    return this._nodeTypeAttr;
  };
  newObj.setNodeTypeAttr = function(attr) {
    this._nodeTypeAttr = attr;
    return this;
  };
  newObj.getLinkSizeAttr = function() {
    return this._linkSizeAttr;
  };
  newObj.setLinkSizeAttr = function(attr) {
    this._linkSizeAttr = attr;
    return this;
  };

  newObj.connectSignals = function() {
    delv.connectToSignal("selectedIdsChanged", this.svgElem, "onSelectedIdsChanged");
    delv.connectToSignal("categoryColorsChanged", this.svgElem, "onCategoryColorsChanged");
  };

  // newObj.selectionChanged = function( selection ) {
  //   delv.log("force_text_view.selectionChanged(" + selection + ")");
  //   ids = [];
  //   ids[0] = selection;
  //   this._dataIF.updateSelectedIds(this.svgElem, this._nodeDataset, ids);
  // };

  newObj.onSelectedIdsChanged = function(invoker, dataset, ids) {
    if (invoker === this.svgElem) {
      delv.log(this._name + ".onSelectedIdsChanged("+dataset+", "+ids+") triggered by self");
    } else {
      delv.log(this._name + ".onSelectedIdsChanged("+dataset+", "+ids+") triggered by "+invoker);
      if (dataset === this._nodeDataset) {
	      if (ids.length != 1) {
	        // TODO figure out what to do in this case
	        delv.log("force_text_view can only handle single selections!!!");
	      } else {
	        selectItem(ids[0]);
	      }
      }
    }
  };

  newObj.onCategoryColorsChanged = function(invoker, dataset, attribute) {
    var cmap = {};
    if (invoker === this.svgElem) {
      delv.log(this._name + ".onCategoryColorsChanged("+dataset+", "+attribute+") triggered by self");
    } else {
      delv.log(this._name + ".onCategoryColorsChanged("+dataset+", "+attribute+") triggered by "+invoker);
      if (dataset === this._nodeDataset && attribute === this._nodeTypeAttr) {
        cmap = this._dataIF.getAllCategoryColorMaps(this._nodeDataset, this._nodeTypeAttr);
	      setColorMap(cmap);
      }
    }
  };

  function newNode() {
    var node = {
      id: "",
      count: 0,
      name: "",
      type: ""
    };
    return node;
  };

  function newLink() {
    var link = {
      id: "",
      source: "",
      target: "",
      count: 0
    };
    return link;
  };


  newObj.reloadData = function() {
    var node_ids = this._dataIF.getAllIds(this._nodeDataset, this._nodeNameAttr);
    var node_names = this._dataIF.getAllItems(this._nodeDataset, this._nodeNameAttr);
    var node_sizes = this._dataIF.getAllItems(this._nodeDataset, this._nodeSizeAttr);
    var node_types = this._dataIF.getAllItems(this._nodeDataset, this._nodeTypeAttr);

    var link_ids = this._dataIF.getAllIds(this._linkDataset, this._linkStartAttr);
    var link_start = this._dataIF.getAllItems(this._linkDataset, this._linkStartAttr);
    var link_end = this._dataIF.getAllItems(this._linkDataset, this._linkEndAttr);
    var link_count = this._dataIF.getAllItems(this._linkDataset, this._linkSizeAttr);

    var nodes = [];
    var links = [];
    var node;
    var link;
    var i;
    for (i = 0; i < node_ids.length; i++) {
      node = newNode();
      node.id = node_ids[i];
      node.count = parseFloat(node_sizes[i]);
      node.name = node_names[i];
      // TODO maybe need a category attr, instead of hijacking node name
      node.type = node_types[i];
      nodes[i] = node;
    }

    for (i = 0; i < link_start.length; i++) {
      link = newLink();
      link.id = link_ids[i];
      link.source = -1;
      link.target = -1;
      for (j = 0; j < node_ids.length; j++) {
        if (link_start[i] === node_ids[j]) {
          link.source = j;
        }
        if (link_end[i] === node_ids[j]) {
          link.target = j;
        }
        if (link.source > -1 && link.target > -1) {
          break;
        }
      }
      link.count = parseFloat(link_count[i]);
      links[i] = link;
    }

    this.bindData(nodes, links);
  };

  newObj.clear = function() {
    this.bindData([], []);
  };

  function grey(cat) {
    return delv.hex(["210", "210", "210"]);
  };

  newObj.setConfig = function(config) {
    this.config = config;
    cfg = config;
    //color = cfg.cmap_func;
    return this;
  };

  newObj.defaultConfig = function() {
    cfg = {
      nodeScale: false,
      linkScale: false,
      useTextLabels: false,
      //cmap_func: d3.scale.category20()
      cmap_func: grey
    };
    newObj.setConfig(cfg);
    // TODO undo this assignment
    color = cfg.cmap_func;
  };
  newObj.defaultConfig();

  function setColorMap(cmap) {
    color = cmap;
    node = svg.select("g#nodes").selectAll("*.node")
      .style("fill", function (d) { return d.id === selectedId ? "#e6550d" : delv.hex(color(d.type)); });

  };

  function selectItem(id) {
    selectedId = id;
  };

  function createSvgElem() {
    if (svgId) {
      svg = d3.select("#"+svgId);
    } else {
      svg = d3.select("#chart").append("svg");
    }
  }
  createSvgElem();

  newObj.bindData = function(nodes, links) {
    this.nodes = nodes;
    this.links = links;
    link = svg.select("g#links").selectAll("line.link")
      .data(links, function (d) { return d.id; });

    link.enter().append("line")
      .classed("link", true)
      .style("opacity", 0.0)
      .style("stroke-width", 0.0)
      .transition()
      .duration(fade_time)
      .style("opacity", 0.5)
      .style("stroke-width", linkScalingFunction());

    link.exit()
      .transition()
      .duration(fade_time)
      .style("opacity", 0.0)
      .style("stroke-width", 0.0)
      .remove();

    // The base selector is "*" to allow for selecting either
    // "circle" elements or "text" elements (depending on which
    // rendering mode we are in).
    node = svg.select("g#nodes").selectAll("*.node")
      .data(nodes, function (d) { return d.id; });

    // Compute the nodal charge based on the type of elements, and
    // their size.
    charge = cfg.useTextLabels ? textCharge : nodeCharge;
    if (cfg.nodeScale) {
      force.charge(function (n) { return 2 * Math.sqrt(n.count) * charge; });
    } else {
      force.charge(charge);
    }

    // Create appropriate SVG elements to represent the nodes, based
    // on the current rendering mode.
    if (cfg.useTextLabels) {
      scaler = nodeScalingFunction();
      cards = node.enter().append("g")
        .attr("id", function (d) { return d.id; })
        .attr("scale", function (d) { return "scale(" + Math.sqrt(scaler(d)) + ")"; })
        .attr("translate", "translate(0,0)")
        .classed("node", true)
        .call(force.drag);

      cards.append("text")
        .text(function (d) { return d.name; })
        .style("fill", "black")
        .datum(function (d) {
          // Augment the selection's data with the bounding
          // box of the text elements.
          d.bbox = this.getBBox();
        });

      cards.insert("rect", ":first-child")
        .attr("width", function (d) { return d.bbox.width; })
        .attr("height", function (d) { return d.bbox.height; })
        .attr("y", function (d) { return -0.75 * d.bbox.height; })
        .style("stroke", function (d) { return delv.hex(color(d.type)); })
        .style("stroke-width", "2px")
        .style("fill", function (d) { return d.type === "DOCUMENT" ? delv.hex(color("DOCUMENT")) : "#e5e5e5"; })
        .style("fill-opacity", "0.8");
    } else {
      node.enter().append("circle")
        .classed("node", true)
        .attr("r", nodeScalingFunction())
        .attr("cx", width / 2)
        .attr("cy", height / 2)
        .style("fill", function (d) { return d.id === selectedId ? "#e6550d" : delv.hex(color(d.type)); })
        .style("opacity", 0.0)
        .call(force.drag)
        .transition()
        .duration(fade_time)
        .style("opacity", 1.0);

      node.append("title")
        .text(function (d) { return d.name; });
    }

    node.exit()
      .transition()
      .duration(fade_time)
      .style("opacity", 0.0)
      .remove();

    // force.stop()
    //   .nodes(nodes)
    //   .links(links)
    //   .start();
    force.stop();
    force.nodes(nodes);
    force.links(links);
    force.start();

    that = this;
    force.on("tick", function () {
      link.attr("x1", function (d) { return d.source.x; })
        .attr("y1", function (d) { return d.source.y; })
        .attr("x2", function (d) { return d.target.x; })
        .attr("y2", function (d) { return d.target.y; });

      if (cfg.useTextLabels) {
        //node.attr("x", function(d) { return d.x; })
        //.attr("y", function(d) { return d.y; });
        node.attr("translate", function (d) { return "translate(" + d.x + "," + d.y + ")"; })
          .attr("transform", function () { return this.getAttribute("translate") + " " + this.getAttribute("scale"); });
      } else {
        node.attr("cx", function (d) { return d.x; })
          .attr("cy", function (d) { return d.y; });
      }

      that.recenter();
    });

  }; // end bindData

  newObj.resize = function(w, h) {
    width = w;
    height = h;
    svg.attr("width", width)
      .attr("height", height);

    force.size([width, height]);
    // force.start();
    this.recenter();
  };


  newObj.recenter = function() {
    // Compute the average position of the nodes, and transform the
    // entire svg element so that this position is the center of the
    // element.

    var avg_x,
    avg_y,
    center_x,
    center_y,
    translate;

    // If there are no nodes, return right away.
    if (this.nodes.length === 0) {
      return;
    }

    // Compute the average position.
    avg_x = 0;
    avg_y = 0;

    $.each(this.nodes, function (i, d) {
      avg_x += d.x;
      avg_y += d.y;
    });

    avg_x /= this.nodes.length;
    avg_y /= this.nodes.length;

    // Compute the svg canvas's center point.
    center_x = width;
    center_y = height;

    center_x = center_x / 2.0;
    center_y = center_y / 2.0;

    // Translate the average position to the center of the canvas.
    translate = "translate(" + (center_x - avg_x) + ", " + (center_y - avg_y) + ")";
    svg.select("g#nodes")
      .attr("transform", translate);
    svg.select("g#links")
      .attr("transform", translate);

  };

  function nodeScalingFunction() {
    var base,
    factor,
    ret;

    base = cfg.useTextLabels ? 0.5 : 5;
    factor = cfg.useTextLabels ? 0.5 : 1;
    if (cfg.nodeScale) {
      ret = function (d) { return base + factor * Math.log(Math.sqrt(d.count)); };
    } else {
      ret = function () { return base; };
    }

    return ret;
  };

  function linkScalingFunction() {
    var ret;

    if (cfg.linkScale) {
      ret = function (d) { return Math.sqrt(d.count); };
    } else {
      ret = 1;
    }
    
    return ret;
  };

  return newObj;
};