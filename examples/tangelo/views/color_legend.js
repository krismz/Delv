/* globals tangeloViews */
var tangeloViews = tangeloViews || {};

///////////////////////////////////
//              View             //
///////////////////////////////////

tangeloViews.color_legend_view = function(svgElem) {
  var bbox,
  bg,
  bottom,
  height,
  heightfunc,
  left,
  maxheight,
  maxwidth,
  right,
  text,
  top,
  totalheight,
  totalwidth,
  width,
  legend,
  cmap_func,
  xoffset,
  yoffset,
  categories,
  svg,
  height_padding,
  width_padding,
  text_spacing,
  legend_margins,
  clear;

  var newObj = new delv.d3View(svgElem);
  newObj.config = {};
  newObj.datasetName = "";
  newObj.dataAttr = "";
  this._name = "ColorLegend";

  newObj.init = function() {
  };
  newObj.init();

  newObj.setConfig = function(cfg) {
    this.config = cfg;
    return this;
  };

  newObj.getDatasetName = function() {
    return this.datasetName;
  };
  newObj.setDatasetName = function(name) {
    this.datasetName = name;
    return this;
  };

  newObj.getDataAttr = function() {
    return this.dataAttr;
  };
  newObj.setDataAttr = function(name) {
    this.dataAttr = name;
    return this;
  };

  newObj.colorChanged = function(selection, c) {
    var col = delv.unhex(c);
    var colorStr = [];
    colorStr[0] = "" + col[0];
    colorStr[1] = "" + col[1];
    colorStr[2] = "" + col[2];
    this._dataIF.updateCategoryColor(this._name, this.datasetName, this.dataAttr, selection, colorStr);
  }

  // not interactive, so no signals connected
  newObj.reloadData = function() {
    var items = this._dataIF.getAllCategories(this.datasetName, this.dataAttr);
    setItems(items);
    // TODO get colors from dataIF or from config?
  };

  svg = svgElem;

  newObj.defaultConfig = function() {
    cmap_func = d3.scale.category20();
    xoffset = 10;
    yoffset = 10;
    height_padding = 5;
    width_padding = 7;
    text_spacing = 19;
    legend_margins = {top: 5, left: 5, bottom: 5, right: 5};
    clear = true;
  }
  newObj.defaultConfig();

  newObj.setConfig = function(cfg) {
    // Extract arguments from the config argument.
    cmap_func = cfg.cmap_func;
    xoffset = cfg.xoffset;
    yoffset = cfg.yoffset;
    height_padding = cfg.height_padding;
    width_padding = cfg.width_padding;
    text_spacing = cfg.text_spacing;
    legend_margins = cfg.legend_margins;
    clear = cfg.clear;
  };

  // Create a d3 selection from the selection.
  legend = d3.select("#"+svg);

  // Clear the svg element, if requested.
  clear = clear || false;
  if (clear) {
    legend.selectAll("*").remove();
  }

  maxwidth = 0;
  maxheight = 0;

  // Place a rect that will serve as a container/background for the legend
  // list items.  Leave its dimensions undefined for now (they will be
  // computed from the size of all the elements later).
  bg = legend.append("rect")
  //.style("fill", "gray");
    .style("fill", "white")
    .style("opacity", 0.7);

  function reportColor(item) {
    newObj.colorChanged(item, cmap_func(item));
  }

  function setItems(items) {
    categories = items;

    $.each(categories, function (i, d) {
            reportColor(d);

            legend.append("rect")
                .classed("colorbox", true)
                .attr("x", xoffset)
                // "y", "width", and "height" intentionally left unset
                .style("fill", cmap_func(d));

            text = legend.append("text")
                .classed("legendtext", true)
                // "x" and "y" intentionally left unset
                .text(d);

            // Compute the max height and width out of all the text bgs.
            bbox = text[0][0].getBBox();

            if (bbox.width > maxwidth) {
                maxwidth = bbox.width;
            }

            if (bbox.height > maxheight) {
                maxheight = bbox.height;
            }
        });

        // Compute the height and width of each color swatch.
        height = maxheight + height_padding;
        width = height;

        // Compute the total height and width of all the legend items together.
        totalheight = height * categories.length;
        totalwidth = width + width_padding + maxwidth;

        // Get the user-supplied margin values.
        left = legend_margins.left || 0;
        top = legend_margins.top || 0;
        right = legend_margins.right || 0;
        bottom = legend_margins.bottom || 0;

        // Set the dimensions of the container rect, based on the height/width of
        // all the items, plus the user supplied margins.
        bg.attr("x", xoffset - left || 0)
            .attr("y", yoffset - top || 0)
            .attr("width", left + totalwidth + right)
            .attr("height", top + totalheight + bottom);

        heightfunc = function (d, i) {
            return yoffset + i * height;
        };

        legend.selectAll(".colorbox")
            .attr("width", height)
            .attr("height", height)
            .attr("y", heightfunc);

        legend.selectAll(".legendtext")
            .attr("x", xoffset + width + width_padding)
            .attr("y", function (d, i) {
                //return 19 + heightfunc(d, i);
                return text_spacing + heightfunc(d, i);
            });
    };
  return newObj;
};
