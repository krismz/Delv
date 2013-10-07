/* globals tangeloViews */
var tangeloViews = tangeloViews || {};

///////////////////////////////////
//              View             //
///////////////////////////////////

tangeloViews.hive_plot_view = function ( svgElem ) {
  var width = 960,
    height = 500,
    innerRadius = 40,
    outerRadius = 240;

var angle = d3.scale.ordinal().domain([]).rangePoints([0, 2 * Math.PI]),
    radius = d3.scale.linear().range([innerRadius, outerRadius]),
    color = d3.scale.category10();

// var nodes = [
//   {x: 0, y: .1},
//   {x: 0, y: .9},
//   {x: 1, y: .2},
//   {x: 1, y: .3},
//   {x: 2, y: .1},
//   {x: 2, y: .8}
// ];

// var links = [
//   {source: nodes[0], target: nodes[2]},
//   {source: nodes[1], target: nodes[3]},
//   {source: nodes[2], target: nodes[4]},
//   {source: nodes[2], target: nodes[5]},
//   {source: nodes[3], target: nodes[5]},
//   {source: nodes[4], target: nodes[0]},
//   {source: nodes[5], target: nodes[1]}
// ];

var svg = d3.select("#" + svgElem)
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(" + outerRadius * .20 + "," + outerRadius * .57 + ")");
    // .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

  var newObj = new delv.d3HierarchyView(svgElem);
  newObj._nodeTypeAttr = "";
  newObj._linkSizeAttr = "";
  newObj.config = {};

  newObj.init = function() {
    delv.log("Calling hive_plot_view.init(), svgElem: " + this.svgElem);
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

  newObj.setConfig = function(cfg) {
    delv.log("In hive_plot_view.setConfig, cfg: " + cfg);
    this.config = cfg;
    return this;
  };

  // not interactive, so no signals connected yet
  // newObj.connectSignals = function() {
  //   delv.connectToSignal("selectedIdsChanged", this.svgElem, "onSelectedIdsChanged");
  // };

  // newObj.selectionChanged = function( selection ) {
  //   delv.log("hive_plot_view.selectionChanged(" + selection + ")");
  //   ids = [];
  //   ids[0] = selection;
  //   this._dataIF.updateSelectedIds(this.svgElem, this._nodeDataset, ids);
  // };

  // newObj.onSelectedIdsChanged = function(invoker, dataset, ids) {
  //   if (invoker == this.svgElem) {
  //     delv.log(this._name + ".onSelectedIdsChanged("+dataset+", "+ids+") triggered by self");
  //   }
  //   else {
  //     delv.log(this._name + ".onSelectedIdsChanged("+dataset+", "+ids+") triggered by "+invoker);
  //     if (dataset == this._nodeDataset) {
	// if (ids.length != 1) {
	//   // TODO figure out what to do in this case
	//   delv.log("hive_plot_view can only handle single selections!!!");
	// }
	// else {
	//   this.view.selectItem(ids[0]);
	// }
  //     }
  //   }
  // };

  function newNode() {
    var node = {
      id: "",
      size: 0,
      name: "",
      type: "",
      count: 0
    };
    return node;
  };

  function newLink() {
    var link = {
      id: "",
      source: "",
      target: "",
      size: 0
    };
    return link;
  };


  newObj.reloadData = function() {
    var node_ids = this._dataIF.getAllIds(this._nodeDataset, this._nodeNameAttr);
    var node_names = this._dataIF.getAllItems(this._nodeDataset, this._nodeNameAttr);
    var node_sizes = this._dataIF.getAllItems(this._nodeDataset, this._nodeSizeAttr);
    var node_types = this._dataIF.getAllItems(this._nodeDataset, this._nodeTypeAttr);
    var categories = this._dataIF.getAllCategories(this._nodeDataset, this._nodeTypeAttr);

    var link_ids = this._dataIF.getAllIds(this._linkDataset, this._linkStartAttr);
    var link_start = this._dataIF.getAllItems(this._linkDataset, this._linkStartAttr);
    var link_end = this._dataIF.getAllItems(this._linkDataset, this._linkEndAttr);
    var link_size = this._dataIF.getAllItems(this._linkDataset, this._linkSizeAttr);

    var nodes = [];
    var links = [];
    var node;
    var link;
    var i;
    for (i = 0; i < node_ids.length; i++) {
      node = newNode();
      node.id = node_ids[i];
      node.size = parseFloat(node_sizes[i]);
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
      link.size = parseFloat(link_size[i]);
      links[i] = link;
    }

    setTypes(categories);
    bindData(nodes, links);
  };

  newObj.clear = function() {
    bindData([], []);
  };

  newObj.resize = function(w, h) {
    width = w;
    height = h;
    innerRadius = 0.042 * width;
    outerRadius = 0.666 * width;
    radius = d3.scale.linear().range([innerRadius, outerRadius]);
    svg.attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + outerRadius * .20 + "," + outerRadius * .57 + ")");
    // .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
  };

  function setTypes(types) {
    angle = d3.scale.ordinal().domain(types).rangePoints([0, 2 * Math.PI]);
    color = d3.scale.category10().domain(d3.range(20));
  };

  function bindData(nodes, links) {
    var nodesByType = d3.nest()
      .key(function(d) { return d.type; })
      .sortKeys(d3.ascending)
      .entries(nodes);

    // delv.log("nodesByType: ");
    // nodesByType.forEach(function(type) {
    //   delv.log("key: " + type.key);
    //   for (var v = 0; v < type.values.length; v++) {
    //     for (var p in type.values[v]) {
    //       delv.log("value[" + v + "][" + p + "]: " + type.values[v][p]);
    //     }
    //   }
    // });

    // Compute the rank for each type, with padding between packages.
    nodesByType.forEach(function(type) {
      var lastName = type.values[0].name, count = 0;
      type.values.forEach(function(d, i) {
        if (d.name !== lastName) {lastName = d.name; count += 2;}
        d.index = count++;
      });
      type.count = count - 1;
    });

    // delv.log("nodesByType with rank: ");
    // nodesByType.forEach(function(type) {
    //   delv.log("key: " + type.key);
    //   for (var v = 0; v < type.values.length; v++) {
    //     for (var p in type.values[v]) {
    //       delv.log("value[" + v + "][" + p + "]: " + type.values[v][p]);
    //     }
    //   }
    // });

    // Set the radius domain.
    radius.domain(d3.extent(nodes, function(d) { return d.index; }));

    // Draw the axes.
    svg.selectAll(".axis")
      .data(nodesByType)
      .enter().append("line")
      .attr("class", "axis")
      .attr("transform", function(d) { return "rotate(" + degrees(angle(d.key)) + ")"; })
      .attr("x1", radius(-2))
      .attr("x2", function(d) { return radius(d.count + 2); })
      .style("stroke", "#000")
      .style("stroke-width", "1.5px");

    svg.selectAll(".link")
      .data(links)
      .enter().append("path")
      .attr("class", "link")
      .attr("d", link()
            .angle(function(d) { return angle(d.x); })
            .radius(function(d) { return radius(d.y); }))
      .style("stroke", function(d) { return color(d.source.x); })
      .style("fill", "none")
      .style("stroke-width", "1.5px");

    svg.selectAll(".node")
      .data(nodes)
      .enter().append("circle")
      .attr("class", "node")
      .attr("transform", function(d) { return "rotate(" + degrees(angle(d.type)) + ")"; })
      .attr("cx", function(d) { return radius(d.index); })
      .attr("r", 5)
      .style("fill", function(d) { return color(d.type); })
      .style("stroke", "#000")
      .style("stroke-width", "1.5px");

  }; // end this.bindData

  function degrees(radians) {
    return radians / Math.PI * 180 - 90;
  }

  function link() {
    var source = function(d) { return d.source; },
      target = function(d) { return d.target; },
      angle = function(d) { return d.angle; },
      startRadius = function(d) { return d.radius; },
      endRadius = startRadius,
      arcOffset = -Math.PI / 2;

    function link(d, i) {
      var s = node(source, this, d, i),
        t = node(target, this, d, i),
        x;
      if (t.a < s.a) { x = t; t = s; s = x; }
      if (t.a - s.a > Math.PI) s.a += 2 * Math.PI;
      var a1 = s.a + (t.a - s.a) / 3,
        a2 = t.a - (t.a - s.a) / 3;
      return s.r0 - s.r1 || t.r0 - t.r1
        ? "M" + Math.cos(s.a) * s.r0 + "," + Math.sin(s.a) * s.r0
        + "L" + Math.cos(s.a) * s.r1 + "," + Math.sin(s.a) * s.r1
        + "C" + Math.cos(a1) * s.r1 + "," + Math.sin(a1) * s.r1
        + " " + Math.cos(a2) * t.r1 + "," + Math.sin(a2) * t.r1
        + " " + Math.cos(t.a) * t.r1 + "," + Math.sin(t.a) * t.r1
        + "L" + Math.cos(t.a) * t.r0 + "," + Math.sin(t.a) * t.r0
        + "C" + Math.cos(a2) * t.r0 + "," + Math.sin(a2) * t.r0
        + " " + Math.cos(a1) * s.r0 + "," + Math.sin(a1) * s.r0
        + " " + Math.cos(s.a) * s.r0 + "," + Math.sin(s.a) * s.r0
        : "M" + Math.cos(s.a) * s.r0 + "," + Math.sin(s.a) * s.r0
        + "C" + Math.cos(a1) * s.r1 + "," + Math.sin(a1) * s.r1
        + " " + Math.cos(a2) * t.r1 + "," + Math.sin(a2) * t.r1
        + " " + Math.cos(t.a) * t.r1 + "," + Math.sin(t.a) * t.r1;
    }

    function node(method, thiz, d, i) {
      var nd = method.call(thiz, d, i),
        a = +(typeof angle === "function" ? angle.call(thiz, nd, i) : angle) + arcOffset,
        r0 = +(typeof startRadius === "function" ? startRadius.call(thiz, nd, i) : startRadius),
        r1 = (startRadius === endRadius ? r0 : +(typeof endRadius === "function" ? endRadius.call(thiz, nd, i) : endRadius));
      return {r0: r0, r1: r1, a: a};
    }

    link.source = function(_) {
      if (!arguments.length) return source;
      source = _;
      return link;
    };

    link.target = function(_) {
      if (!arguments.length) return target;
      target = _;
      return link;
    };

    link.angle = function(_) {
      if (!arguments.length) return angle;
      angle = _;
      return link;
    };

    link.radius = function(_) {
      if (!arguments.length) return startRadius;
      startRadius = endRadius = _;
      return link;
    };

    link.startRadius = function(_) {
      if (!arguments.length) return startRadius;
      startRadius = _;
      return link;
    };

    link.endRadius = function(_) {
      if (!arguments.length) return endRadius;
      endRadius = _;
      return link;
    };

    return link;
  } // end link

  return newObj;

}; // end tangeloViews.hive_plot_view