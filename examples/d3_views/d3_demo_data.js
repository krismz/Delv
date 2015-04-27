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

d3WrapperNS.d3_demo_data = function ( name ) {
  var newObj = new delv.data(name);
  newObj.setDelvIF(delv);
  delv.addDataIF(newObj);

  newObj.load_data = function(when_finished) {
    delv.log("Loading data from file: " + "test_data/flare.json");
    this.load_from_file("test_data/flare.json", when_finished);
  };

  newObj.load_from_file = function(filename, when_finished) {
    d3.json(filename, 
            function(error, json) {
              delv.log("load_from_file, error: " + error);
              d3WrapperNS.convert_to_nodes_links(json, name);
              when_finished();
            });
  };
  return newObj;
};


d3WrapperNS.convert_to_nodes_links = function(json, name) {
  var dataIF = delv.getDataIF(name);
  var nodes = dataIF.addDataSet("Nodes");
  var links = dataIF.addDataSet("Links");
  var def_color = ["210", "210", "210"];
  var total_size;
  var linkId = 0;
  var nodeId = 0;

  add_node = function(id, name, size) {
    nodes.addId(id);
    nodes.setItem("name", id, name);
    nodes.setItem("size", id, size);
  };

  add_link = function(id, startNode, endNode) {
    links.addId(id);
    links.setItem("StartNode", id, startNode);
    links.setItem("EndNode", id, endNode);
  };

  convert_one_level = function(json, level, parent) {
    var name = json["name"];
    var node_size = 0;
    var node_id = "" + nodeId;
    var children = [];
    var ii;
    nodeId += 1;
    if (json.hasOwnProperty("children")) {
      children = json["children"];
      for (ii = 0; ii < children.length; ii++) {
        node_size += this.convert_one_level(children[ii], level+1, node_id);
      }
    }
    if (json.hasOwnProperty("size")) {
      node_size += parseInt(json["size"], 10);
    }
    add_node(node_id, name, node_size);
    if (parent !== "") {
      add_link("" + level + "_" + linkId, parent, node_id);
      linkId += 1;
    }
    return node_size;
  };

  nodes.addAttribute( new delv.attribute("name", delv.AttributeType.UNSTRUCTURED,
                                         new delv.colorMap(def_color),
                                         new delv.dataRange()) );
  nodes.addAttribute( new delv.attribute("size", delv.AttributeType.CONTINUOUS,
                                         new delv.continuousColorMap(def_color),
                                         new delv.continuousRange()) );

  links.addAttribute( new delv.attribute("StartNode", delv.AttributeType.UNSTRUCTURED,
                                           new delv.colorMap(def_color),
                                           new delv.dataRange()) );
  links.addAttribute( new delv.attribute("EndNode", delv.AttributeType.UNSTRUCTURED,
                                           new delv.colorMap(def_color),
                                           new delv.dataRange()) );

  total_size = convert_one_level(json, 0, "");

};
