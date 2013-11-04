/*jslint browser: true, unparam: true */

/*globals tangelo, CryptoJS, $, d3, escape, FileReader, console, delv */

// This is declared null for now - it will be initialized in the window's
// onready method, as it depends on elements being loaded in the page.
var graph = null;

// Top-level container object for this js file.
var NER = {};

NER.cfgDefaults = null;

// Get the mongo server to use from the configuration.
NER.getMongoDBServer = function () {
    "use strict";

    return localStorage.getItem('NER:mongodb-server') || NER.cfgDefaults["mongodb-server"] || 'localhost';
};

// Save the mongo server to use to the configuration.
NER.setMongoDBServer = function (val) {
    "use strict";

    return localStorage.setItem('NER:mongodb-server', val);
};

NER.dataIF = function(name) {
  var newIF = new delv.data(name);
  newIF.setDelvIF(delv);
  // TODO extend basic js dataIF

  newIF.clearAll = function() {
    newIF.initTables();
  };

  newIF.initTables = function() {
    newIF.addDataSet('Nodes');
    newIF.addDataSet('Links');
    newIF.addAttribute('Nodes',
      new delv.attribute('name', delv.AttributeType.UNSTRUCTURED,
                          new delv.colorMap(),
                          new delv.dataRange()));
    newIF.addAttribute('Nodes',
      new delv.attribute('type', delv.AttributeType.CATEGORICAL,
                          new delv.colorMap(),
                          new delv.dataRange()));
    newIF.addAttribute('Nodes',
      new delv.attribute('count', delv.AttributeType.CONTINUOUS,
                          new delv.continuousColorMap(),
                          new delv.continuousRange()));

    newIF.addAttribute('Links',
      new delv.attribute('source', delv.AttributeType.UNSTRUCTURED,
                          new delv.colorMap(),
                          new delv.dataRange()));
    newIF.addAttribute('Links',
      new delv.attribute('target', delv.AttributeType.CATEGORICAL,
                          new delv.colorMap(),
                          new delv.dataRange()));
    newIF.addAttribute('Links',
      new delv.attribute('type', delv.AttributeType.CATEGORICAL,
                          new delv.colorMap(),
                          new delv.dataRange()));
    newIF.addAttribute('Links',
      new delv.attribute('count', delv.AttributeType.CONTINUOUS,
                          new delv.continuousColorMap(),
                          new delv.continuousRange()));

  };

  newIF.addDocument = function(filename, entities) {
    // Create an entry for the document itself.
    newIF.setItem('Nodes', 'name', filename, filename);
    newIF.setItem('Nodes', 'type', filename, "DOCUMENT");
    newIF.setItem('Nodes', 'count', filename, 1.0);
    doc_index = filename;

    // TODO understand the types, does this really need to be a separate table?
    // otherwise we can just pull the categories from the type attribute in the
    // Nodes dataset
    // Augment the count for the DOCUMENT type in the type table.
    // var cnt = newIF.getItem('Types', 'count', "DOCUMENT");
    // newIF.data['Types'].setItem('count', "DOCUMENT", cnt + 1 || 1);

    // Process the entities.
    $.each(entities, function (i, e) {
      var key,
      entity_index,
      link;

      // Place the entity into the global entity list
      // if not already there.
      //
      // Also update the count of this entity.
      key = '["' + e[0] + '","' + e[1] + '"]';
      // TODO implement hasId method (make it part of the API?)
      if (!newIF.hasId('Nodes', key)) {
        newIF.setItem('Nodes', 'name', key, key);
        newIF.setItem('Nodes', 'type', key, "" + e[0]);
        newIF.setItem('Nodes', 'count', key, 1.0);

        // Augment the type count.
        // cnt = newIF.getItem('Types','count', e[0]);
        // newIF.data['Types'].setItem('count', e[0], cnt + 1 || 1);
      } else {
        newIF.setItem('Nodes', 'count', key, newIF.getItemAsFloat('Nodes', 'count', key) + 1.0);
      }

      entity_index = key;

      // Enter a link into the link list, or just increase the count if
      // the link exists already.
      link = "(" + entity_index + "," + doc_index + ")";
      if (!newIF.hasId('Links', link)) {
        newIF.setItem('Links', 'source', link, "" + entity_index);
        newIF.setItem('Links', 'target', link, "" + doc_index);
        newIF.setItem('Links', 'type', link, "" + e[0]);
        newIF.setItem('Links', 'count', link, 1);
      } else {
        newIF.setItem('Links', 'count', link, newIF.getItemAsFloat('Links', 'count', link) + 1);
      }
    }); // end for each entity
  }; // end addDocument

  return newIF;
}; // end NER.dataIF

NER.data = new NER.dataIF("NER");

// "nodes" is a table of entity names, mapping to an array position generated
// uniquely by the "counter" variable.  Once the table is complete, the nodes
// table can be recast into an array.
NER.data.initTables();
delv.addDataIF(NER.data);
// NER.nodes = {};
// NER.links = {};
// NER.counter = 0;
// NER.linkcounter = 0;

// A catalog of NER types found by the analysis.  This will be used to construct
// the color legend at the top of the graph display.
// NER.types = {};

// This count will signal when the last ajax request has completed, and graph
// assembly can continue.
NER.num_files = 0;
NER.files_processed = 0;

// This table stores formatted filename information that can be dynamically
// added to in different situations ("processing" to "processed", etc.).
NER.filenames = {};

NER.datasets = [
    {
        option: "Letters from Abbottabad",
        dir: "data/letters-from-abbottabad"
    }
];

NER.customdata = "Custom (use file selector)";

NER.force_graph = {};
NER.legend = {};
NER.sunburst = {};
NER.joinView = {};

function appendInfo(msg) {
    "use strict";

    var con;

    con = d3.select("#console");
    con.text(con.text() + msg + "\n");
}

function clearAll() {
    "use strict";

    NER.data.clearAll();
    // NER.nodes = {};
    // NER.links = {};
    // NER.counter = 0;
    // NER.linkcounter = 0;

    // NER.types = {};

    NER.num_files = 0;
    NER.files_processed = 0;
}

// This function can be called with a filename to *generate* an AJAX-success
// callback function to process the contents of some file.  The parameter passed
// into the generator is so that the callback has access to the name of the file
// being processed.
function processFileContents(filename, id, file_hash) {
    "use strict";

    return function (response) {
        var entities,
            li,
            ok,
            doc_index;

        // Check the error code in the AJAX response.  If there is an error,
        // write the error message in the information window and abort the
        // operation.
        if (response.error !== null) {
            appendInfo(response.error);
            return;
        }

        // Extract the actual result from the response object.
        entities = response.result;

        // Write a message.
        appendInfo(filename + " processed");

        // If the "store" parameter is set to true, store the data in the
        // database (caching it for future retrieval).
        if (file_hash !== undefined) {
            // Fire an AJAX call that will install the computed data in the DB.
            ok = true;
            $.ajax({
                type: 'POST',
                url: 'service/nermongo/' + NER.getMongoDBServer() + '/xdata/ner-cache',
                data: {
                    file_hash: file_hash,
                    data: JSON.stringify(entities)
                },
                dataType: 'json',
                success: function (resp) {
                    // If there was an error, continue anyway, as the failure
                    // would be in writing an entry to the database, and we
                    // already have the data in hand.
                    if (resp.error !== null) {
                        console.log("error: " + resp.error);
                    }
                }
            });
        }

        NER.data.addDocument(filename, entities);

        // Increment the number of successfully processed files; if the number
        // reaches the number of total files to process, launch the final step
        // of assembling the graph.
        NER.files_processed += 1;

        if (NER.files_processed === NER.num_files) {
            delv.log("all files processed, assembling graph");
            graph.assemble(NER.data, NER.nodeSlider.slider("value"));
            // graph.recompute(NER.nodeSlider.slider("value"));
            graph.render();
        }
    };
}

function processFile(filename, id) {
    "use strict";

    return function (e) {
        var text,
            file_hash;

        // Grab the text of the file.
        text = e.target.result;

        // Create a "progress" bullet point describing the current
        // AJAX state of this file.

        //var elem = document.createElement("li");
        //elem.innerHTML = "processing " + filename;
        //elem.setAttribute("id", filename.replace(".","-"));
        //elem.setAttribute("class", "processing inprogress");
        //$("#blobs").get(0).appendChild(elem);

        file_hash = CryptoJS.MD5(text).toString();

        // Check to see if the file contents were already processed,
        // by querying the database for the results.  If they are
        // found, retrieve them directly; if not, fire the AJAX call
        // below to compute the results (but db cache the result
        // when it finishes!).
        $.ajax({
            type: 'POST',
            url: 'service/nermongo/' + NER.getMongoDBServer() + '/xdata/ner-cache',
            data: {
                file_hash: file_hash
            },
            dataType: "json",
            success: function (response) {
                var li;

                // Error checking.
                if (response.error !== null) {
                    appendInfo(response.error);
                }

                // Mark the appropriate list item as being processed.
                appendInfo(filename + " processing");

                // Check the response - if it is an empty list, or there was a
                // database error, launch the second AJAX call to directly
                // compute the NER set, and store it in the database.
                if (response.error !== null || response.result.length === 0) {
                    $.ajax({
                        type: 'POST',
                        url: 'service/ner',
                        data: {
                            text: text
                        },
                        dataType: 'json',
                        success: processFileContents(filename, id, file_hash),
                        error: function () {
                            appendInfo(filename + " processed");
                        }
                    });
                } else {
                    // TODO(choudhury): error checking.  Make sure that response
                    // has only a single element, etc.

                    // Convert the Mongo result into an NER result before
                    // sending it to be processed.  Because the nested list
                    // comes back from Mongo as a string, parse it into a
                    // JavaScript object as well.
                    //
                    // TODO(choudhury): do error checking - if the "error" field
                    // of the response is not null, something must be done.
                    response.result = $.parseJSON(response.result[0].data);

                    // The call to processFileContents() generates a function
                    // (in which the file_hash parameter is OMITTED); the second
                    // invocation calls that function to actually process the
                    // data.
                    processFileContents(filename, id)(response);
                }
            }
        });
    };
}

function generate_id(filename) {
    "use strict";

    // TODO(choudhury): technically, this can lead to identical ids (e.g.,
    // "letter_1.txt" and "letter 1.txt" will both wind up with
    // "letter_1-txt" as their id string).
    return filename.replace(/\./g, "-")
        .replace(/ /g, "_");
}

function handleFileSelect() {
    "use strict";

    var evt,
        files,
        output,
        i,
        f,
        filename,
        id,
        using,
        status,
        msg,
        li,
        reader;

    evt = d3.event;

    // Clear the graph.
    graph.reset();

    // Clear the data.
    clearAll();

    // Set the dataset selector element to show the "custom" item.
    d3.select("#dataset").node().value = NER.customdata;

    // Grab the list of files selected by the user.
    files = evt.target.files;

    // Compute how many of these files will actually be processed for named
    // entities (see comment below for explanation of how the files are vetted).
    NER.num_files = 0;
    $.each(files, function (k, v) {
        if (v.type === '(n/a)' || v.type.slice(0, 5) === 'text/') {
            NER.num_files += 1;
        }
    });

    // Now run through the files, using a callback to load the content from the
    // proper ones and pass it to an ajax call to perform named-entity
    // recognition.
    output = [];
    for (i = 0; i < files.length; i += 1) {
        f = files[i];

        // Create globally usable names to use to refer to the current file.
        filename = escape(f.name);

        // Get a unique id by which to refer to the this file in the html
        // document.
        id = generate_id(f.name);

        // Decide whether to process a selected file or not - accept everything
        // with a mime-type of text/*, as well as those with unspecified type
        // (assume the user knows what they are doing in such a case).
        using = null;
        status = null;
        msg = null;
        if (f.type === '(n/a)') {
            status = "accepted";
            msg = "ok, assuming text";
            using = true;
        } else if (f.type.slice(0, 5) === 'text/') {
            status = "accepted";
            msg = "ok";
            using = true;
        } else {
            status = "rejected";
            msg = "rejected";
            using = false;
        }

        // Create a list item element to represent the file.  Tag it with an id
        // so it can be updated later.
        li = d3.select("#file-info").append("li");
        NER.filenames[filename] = '<span class=filename>' + filename + '</span>';
        appendInfo(filename + " (" + (f.type || "n/a") + ") - " + f.size + " bytes " + (using ? "(ok)" : "(rejected)"));

        if (using) {
            reader = new FileReader();
            reader.onload = processFile(filename, id);
            reader.readAsText(f);
        }
    }
}

function freshFileInput() {
    "use strict";

    var holder;

    holder = d3.select("#file-input-holder");

    holder.selectAll("*")
        .remove();

    holder.append("input")
        .attr("multiple", "true")
        .attr("type", "file")
        .attr("id", "docs")
        .on("change", handleFileSelect);
}

function loaddata() {
    "use strict";

    var callback,
        dir,
        i,
        sel;

    // Determine which option was selected.
    //
    // NOTE: the index will be equal to the length of the available datasets
    // when it is pointing "beyond" all of the dataset choices, i.e., at the
    // custom item.
    sel = d3.select("#dataset").node();
    if (sel.selectedIndex === NER.datasets.length) {
        return;
    }

    // Clear the file input.
    freshFileInput();

    // Get the directory containing the files in the data set.
    /*jslint nomen:true */
    dir = sel.options[sel.selectedIndex].__data__.dir;
    /*jslint nomen:false */

    // Open the json file describing which files to load.
    d3.json(dir + "/control.json", function (data) {
        // Set the number of files to load.
        NER.num_files = data.files.length;

        // Write a callback generator that will construct an id, pass the
        // filename and id to processFile, then immediately invoke the resulting
        // function with a fake event object containing the text to process.
        callback = function (i) {
            return function (text) {
                var e;

                // Pack the text into a form the processFile function will
                // recognize.
                e = {};
                e.target = {};
                e.target.result = text;

                // Call the function.
                processFile(data.files[i], generate_id(data.files[i]))(e);
            };
        };

        // Fire off ajax calls to retrieve the text and pass it to processFile.
        for (i = 0; i < data.files.length; i = i + 1) {
            d3.text(dir + "/" + data.files[i], callback(i));
        }
    });
}

function init_views(view, elemId) {
  view.dataIF("NER");
  if (elemId === "graph") {
    NER.force_graph = view;
    NER.force_graph.setName("NER.ForceText")
      .setNodeDatasetName("Nodes")
      .setLinkDatasetName("Links")
      .setNodeSizeAttr("count")
      .setNodeNameAttr("name")
      .setNodeTypeAttr("type")
      .setLinkStartAttr("source")
      .setLinkEndAttr("target")
      .setLinkSizeAttr("count");
    
  } else if (elemId === "legend") {
    NER.legend = view;
    // NER.legend.setName("NER.legend")
    //   .setDatasetName("Links")
    //   .setDataAttr("type");
    NER.legend.name("NER.legend")
      .datasetName("Links")
      .dataAttr("type");
    p = Processing.getInstanceById("legend");
    NER.legend.setBackgroundColor(p.color(193,193,193));
  } else if (elemId === "sunburst") {
    NER.sunburst = view;
    // NER.sunburst.setName("NER.sunburst")
    //   .setNodeDatasetName("Nodes")
    //   .setLinkDatasetName("Links")
    //   .setNodeSizeAttr("count")
    //   .setNodeNameAttr("name")
    //   .setNodeTypeAttr("type")
    //   .setLinkStartAttr("source")
    //   .setLinkEndAttr("target")
    //   .setLinkSizeAttr("count");
    view.name("NER.sunburst");
    aboveDataset = view.createDataset("Links");
    aboveDataset.barStartAttr("count")
                .barTagAttr("source")
                .barTypeAttr("type")
                .units("count")
                .regionTypeAttr("target")
                .defaultBarHeight("1.0")
                .defaultBarLength("1");
    view.addDataset(aboveDataset, false);

  }
  view.reloadData("NER");
  delv.resizeAll();
}

window.onload = function () {
    "use strict";

    tangelo.requireCompatibleVersion("0.2");

    tangelo.defaults("defaults.json", function (defaults) {
        var popover_cfg;

        NER.cfgDefaults = defaults;

        // Capture the console element.
        NER.con = d3.select("#console");

        // Enable the popover help items.
        //
        // First create a config object with the common options present.
        popover_cfg = {
            html: true,
            container: "body",
            placement: "top",
            trigger: "hover",
            title: null,
            content: null,
            delay: {
                show: 100,
                hide: 100
            }
        };

        // Dataset pulldown help.
        popover_cfg.content = "A description of the included datasets:<br><br>" +
            "<b>Letters from Abbottabad</b>. " +
            "Correspondence written by Al Qaeda leadership, including Osama bin Laden, " +
            "discovered by the SEALs during the raid in which he was killed.<br><br>";
        $("#dataset-help").popover(popover_cfg);

        // Graph menu help.
        popover_cfg.content = "<b>Scale nodes by frequency</b>. Display the nodes, representing entities, " +
            "with size proportional to the <i>total number of mentions in all the documents</i>.<br><br>" +
            "<b>Thicken links by frequency</b>. Display the links, representing the mention of an entity " +
            "in a document, with thickness proportional to the <i>number of times that entity is mentioned " +
            "in that document</i>.<br><br>" +
            "<b>Render text labels</b>.  Instead of circles to represent entities, use a text placard with " +
            "the name of the entity displayed with text.";
        $("#graph-help").popover(popover_cfg);

        // Initialize the navbar.
        $("#navbar").navbar({
            onConfigSave: function () {
                NER.setMongoDBServer($("#mongodb-server").val());
            },

            onConfigDefault: function () {
                localStorage.removeItem("NER:mongodb-server");
                $("#mongodb-server").val(NER.getMongoDBServer());
            }
        });

        // Place the current Mongo DB server in the navbar contents.
        $("#mongodb-server").val(NER.getMongoDBServer());

        // Activate the dataset select tag, and fill it with entries.
        d3.select("#dataset")
            .on("change", loaddata)
            .data(NER.datasets)
            .append("option")
            .text(function (d) { return d.option; });

        d3.select("#dataset")
            .append("option")
            .text(NER.customdata);

        // Activate the clear button.
        d3.select("#clear")
            .on("click", function () {
                clearAll();
                graph.clear();

                // Clear the file selector, and set the dataset selector to
                // "custom".
                freshFileInput();
                d3.select("#dataset").node().value = NER.customdata;
            });

      graph = (function () {
            var config,
                color,
                canvas;

            color = d3.scale.category20();

            // Configuration parameters for graph rendering.
            config = {
                // Whether to make the radius of each node proportional to the number of
                // times it occurs in the corpus.
                nodeScale: false,

                // Whether to thicken a link proportionally to the number of times it
                // occurs in the corpus.
                linkScale: false,

                // Whether to use circles to represent nodes, or text objects.
                useTextLabels: false,

                // color map
                cmap_func: color

            };


          // delv.d3Chart("legend", "views/color_legend.js",
          //               "tangeloViews.color_legend_view",
          //               init_views);
          canvas = document.getElementById("legend");
          delv.processingSketch(canvas, 
                                 ["./views/Globals.pde",
					                        "./views/Attribute.pde",
					                        "./views/Delv.pde",
					                        "./views/ColorPickerLegend.pde"],
					                       "ColorPickerLegendView",
					                       init_views);
        
          // delv.d3Chart("sunburst", "views/partition_sunburst_zoom.js",
          //               "d3WrapperNS.partition_sunburst_zoom_view",
          //               init_views);
          // delv.d3Chart("sunburst", "views/hive_plot.js",
          //               "tangeloViews.hive_plot_view",
          //               init_views);
          canvas = document.getElementById("sunburst");
          delv.processingSketch(canvas, 
                                 ["./views/Globals.pde",
					                        "./views/Attribute.pde",
					                        "./views/Delv.pde",
					                        "./views/BasicRegion.pde", // currently only needed for the RegionView
					                        "./views/Region.pde"],
					                       "RegionView",
					                       init_views);
          delv.d3Chart("graph", "views/force_text.js",
                        "tangeloViews.force_text_view",
                        init_views);

        NER.joinView = new delv.joinView("JoinNodesLinks");
        NER.joinView.setDataset1Name("Nodes")
          .setDataset1Attr("type")
          .setDataset2Name("Links")
          .setDataset2Attr("type")
          .connectSignals();
        NER.joinView.dataIF("NER");
        delv.addView(NER.joinView, "JoinNodesLinks");

            return {
                assemble: function (dataIF, nodecount_threshold) {
                    var elemtext,
                  li;

                  //NER.sunburst.reloadData("NER");

                  NER.force_graph.setConfig(config);
                  //  .reloadData();
                  
                  // NER.legend.setConfig({
                  //   name: "legend",
                  //   cmap_func: color,
                  //   xoffset: 10,
                  //   yoffset: 10,
                  //   height_padding: 5,
                  //   width_padding: 7,
                  //   text_spacing: 19,
                  //   legend_margins: {top: 5, left: 5, bottom: 5, right: 5},
                  //   clear: true
                  // });
                    //.reloadData();

                  delv.reloadData();

                    // Read the current state of the option inputs (these might not
                    // be the default values if the user did a "soft" reload of the
                    // page after changing them).
                    this.updateConfig();
                },

                // recompute: function (nodecount_threshold) {
                //     var fixup;

                //     if (nodecount_threshold === undefined) {
                //         throw "recompute must be called with a threshold!";
                //     }

                //     // Copy the thresholded nodes over to the local array, and
                //     // record their index as we go.  Also make a local copy of the
                //     // original, unfiltered data.
                //     nodes.length = 0;
                //     fixup = {};
                //     $.each(orignodes, function (k, v) {
                //         if (v.count >= nodecount_threshold || v.type === "DOCUMENT") {
                //             fixup[v.id] = nodes.length;
                //             nodes.push(v);
                //         }
                //     });

                //     // Copy the link data to the local links array, first checking
                //     // to see that both ends of the link are actually present in the
                //     // fixup index translation array (i.e., that the node data is
                //     // actually present for this threshold value).  Also make a
                //     // local copy of the origlinks, unfiltered link data.
                //     links.length = 0;
                //     $.each(origlinks, function (k, vv) {
                //         var v,
                //             p;

                //         v = {};
                //         for (p in vv) {
                //             if (vv.hasOwnProperty(p)) {
                //                 v[p] = vv[p];
                //             }
                //         }

                //         if (fixup.hasOwnProperty(v.source) && fixup.hasOwnProperty(v.target)) {
                //             // Use the fixup array to edit the index location of the
                //             // source and target.
                //             v.source = fixup[v.source];
                //             v.target = fixup[v.target];
                //             links.push(v);
                //         }
                //     });
                // },

                reset: function () {
                    // Empty the node and link containers, so they can be recomputed
                    // from scratch.
                    NER.force_graph.reloadData("NER reset");

                    // Recompute the graph connectivity.
                    // TODO handle this
                    // this.recompute(NER.nodeSlider.slider("value"));

                    // Re-render.
                    this.render();
                },

                clear: function () {
                  NER.force_graph.clear();
                },

                render: function () {
                  NER.force_graph.reloadData("NER render");

                },

                updateConfig: function () {
                    var check;

                    // Sweep through the configuration elements and set the boolean
                    // flags appropriately.
                    check = $("#nodefreq")[0];
                    config.nodeScale = check.checked;

                    check = $("#linkfreq")[0];
                    config.linkScale = check.checked;

                    check = $("#usetext")[0];
                    config.useTextLabels = check.checked;
                }

                // applyConfig: function () {
                //     var scaler;

                //     // Reset the attributes on the nodes and links according to
                //     // the current config settings.
                //     svg.selectAll("g#links line.link")
                //         .transition()
                //         .duration(2000)
                //         .style("stroke-width", this.linkScalingFunction());

                //     if (config.useTextLabels) {
                //         scaler = this.nodeScalingFunction(); // Capture here because 'this' content is gone when we need to retrieve this function.
                //         svg.selectAll("g#nodes *.node")
                //             .transition()
                //             .duration(1000)
                //             .attr("scale", function (d) { return "scale(" + Math.sqrt(scaler(d)) + ")"; })
                //             .attr("transform", function () { return this.getAttribute("translate") + " " + this.getAttribute("scale"); });
                //         //.attr("transform", function() { return this.getAttribute("translate"); });
                //         //.attr("transform", function() { return this.getAttribute("scale"); });
                //     } else {
                //         svg.selectAll("g#nodes circle.node")
                //             .transition()
                //             .duration(1000)
                //             .attr("r", this.nodeScalingFunction());
                //     }
                // },

            };
        }());

        // Initialize the slider for use in filtering.
        //
        // Set the slider to "5" (to give a reasonable amount of data as the
        // default).
        NER.nodeSlider = $("#slider");
        NER.nodeSlider.slider({
            max: 10,
            value: 5,
            change: function (evt, ui) {
                //graph.recompute(ui.value);
                graph.render();
            },
            slide: (function () {
                var display = d3.select("#value");

                return function (evt, ui) {
                    display.html(ui.value);
                };
            }())
        });

        // Bootstrap showing the slider value here (none of the callbacks in the
        // slider API help).
        d3.select("#value").html(NER.nodeSlider.slider("value"));

        // Install a new file input.
        //
        // NOTE: this is done via a function so we have a way to "clear" the
        // filename appearing inside it, when the user uses the dropdown menu to
        // select a prepared dataset, etc.
        freshFileInput();

        // Trigger the loading of the default selected dataset from the dropdown.
        loaddata();
    });
};
