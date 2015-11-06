// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

// interfaces, implementations and classes used to talk back and forth between javascript and processing
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;
import java.util.Map.Entry;

interface Delv {
  void log(String msg);
  void emitEvent(String name, String detail);
  // TODO document these better
  // standard signals:
  // sortChanged, hoverChanged, selectChanged, filterChanged, colorChanged, encodingChanged, navChanged, lodChanged,
  // hoverColorChanged, selectColorChanged, filterColorChanged, likeColorChanged
  void emitSignal(String signal, String invoker, String dataset);
  void emitSignal(String signal, String invoker, String dataset, String detail);
  void emitSignal(String signal, String invoker, String dataset, String[] details);
  void emitSignal(String signal, String invoker, String dataset, String coordination, String detail);
  void connectToSignal(String signal, String name, String method);
  void disconnectFromSignal(String signal, String name);
  DelvView getView(String name);
  void addView(DelvView view);
  void runInThread(Object obj, String name);

  ////////////////////
  // data sets
  ////////////////////
  void addDataSet(String name, DelvDataSet dataset);
  DelvDataSet getDataSet(String name);  // returns a new data set if one doesn't exist
  boolean hasDataSet(String name);
  void removeDataSet(String name);

  ////////////////////
  // data attributes
  ////////////////////
  void addAttr(String dataset, DelvAttribute attribute);
  Boolean hasAttr(String dataset, String attribute);
  String[] getAttrs(String dataset);
  String[] getAllCats(String dataset, String attribute);
  String[] getCatColor(String dataset, String attribute, String category);
  String[][] getCatColors(String dataset, String attribute);
  String[][] getFilterCatColors(String dataset, String attribute);
  String[] getCatEncoding(String dataset, String attribute, String category);
  String[][] getCatEncodings(String dataset, String attribute);

  ////////////////////
  // data items
  ////////////////////
  // TODO should setting items be allowed here or only as part of dataset interface?
  // it seems like if set here, then a dataChanged signal would need to be emitted as well.
  void clearItems(String dataset);
  void setItem(String dataset, String attribute, String identifier, String item);
  void setItem(String dataset, String attribute, String[] coordinate, String item);
  void setFloatItem(String dataset, String attribute, String identifier, Float item);
  void setFloatItem(String dataset, String attribute, String[] coordinate, Float item);
  void setFloatArrayItem(String dataset, String attribute, String identifier, float[] item);
  void setFloatArrayItem(String dataset, String attribute, String[] coordinate, float[] item);
  void setStringArrayItem(String dataset, String attribute, String identifier, String[] item);
  void setStringArrayItem(String dataset, String attribute, String[] coordinate, String[] item);

  String getItem(String dataset, String attribute, String identifier);
  String getItem(String dataset, String attribute, String[] coordinate);
  Float getItemAsFloat(String dataset, String attribute, String identifier);
  Float getItemAsFloat(String dataset, String attribute, String[] coordinate);
  float[] getItemAsFloatArray(String dataset, String attribute, String identifier);
  float[] getItemAsFloatArray(String dataset, String attribute, String[] coordinate);
  String[] getItemAsStringArray(String dataset, String attribute, String identifier);
  String[] getItemAsStringArray(String dataset, String attribute, String[] coordinate);

  String[] getAllItems(String dataset, String attribute);
  // TODO Float, float, Double or double here?
  Float[] getAllItemsAsFloat(String dataset, String attribute);
  float[][] getAllItemsAsFloatArray(String dataset, String attribute);
  String[][] getAllItemsAsStringArray(String dataset, String attribute);

  String getMin(String dataset, String attribute);
  String getMax(String dataset, String attribute);

  String[] getHoverItems(String dataset, String attribute);
  Float[] getHoverItemsAsFloat(String dataset, String attribute);
  float[][] getHoverItemsAsFloatArray(String dataset, String attribute);
  String[][] getHoverItemsAsStringArray(String dataset, String attribute);

  String[] getSelectItems(String dataset, String attribute, String selectType);
  Float[] getSelectItemsAsFloat(String dataset, String attribute, String selectType);
  float[][] getSelectItemsAsFloatArray(String dataset, String attribute, String selectType);
  String[][] getSelectItemsAsStringArray(String dataset, String attribute, String selectType);

  String[] getFilterItems(String dataset, String attribute);
  Float[] getFilterItemsAsFloat(String dataset, String attribute);
  float[][] getFilterItemsAsFloatArray(String dataset, String attribute);
  String[][] getFilterItemsAsStringArray(String dataset, String attribute);

  String[] getNavItems(String dataset, String attribute);
  Float[] getNavItemsAsFloat(String dataset, String attribute);
  float[][] getNavItemsAsFloatArray(String dataset, String attribute);
  String[][] getNavItemsAsStringArray(String dataset, String attribute);

  // get color of item or items, applying precedence rules (highest to lowest precedence):
  // hover color, select color, like color, filter color, attribute color
  String[] getItemColor(String dataset, String colorByAttribute, String identifier);
  String[] getItemColor(String dataset, String colorByAttribute, String[] coordinate);
  String[][] getItemColors(String dataset, String colorByAttribute);
  String[] getItemEncoding(String dataset, String encodingByAttribute, String identifier);
  String[] getItemEncoding(String dataset, String encodingByAttribute, String[] coordinate);
  String[][] getItemEncodings(String dataset, String encodingByAttribute);
  // TODO add API for getting colors of just filtered items?

  // get color of item or items based on attribute color map, ignoring any selection-based coloring
  String[] getItemAttrColor(String dataset, String colorByAttribute, String identifier);
  String[] getItemAttrColor(String dataset, String colorByAttribute, String[] coordinate);
  String[][] getItemAttrColors(String dataset, String colorByAttribute);
  String[] getItemAttrEncoding(String dataset, String encodingByAttribute, String identifier);
  String[] getItemAttrEncoding(String dataset, String encodingByAttribute, String[] coordinate);
  String[][] getItemAttrEncodings(String dataset, String encodingByAttribute);

  ////////////////////
  // data coordinates
  ////////////////////
  String[] getAllIds(String dataset, String attribute);
  String[][] getAllCoords(String dataset, String attribute);
  boolean hasId(String dataset, String id);
  boolean hasCoord(String dataset, String[] coord);


  ////////////////////
  // data as graph
  ////////////////////

  // TODO put in graph-like interface

  ////////////////////
  // data operations
  ////////////////////
  // sort
  // possible values of sortType: ascending, descending
  void sortByVal(String invoker, String dataset, String attribute, String sortType);
  // possible values of similarity sortType: similarity, dissimilarity
  // TODO, this is vague, really need a way to define a similarity measure.
  void sortBySimilarity(String invoker, String dataset, String identifier, String sortType);
  void sortBySimilarity(String invoker, String dataset, String[] coordinate, String sortType);
  void clearSort(String invoker, String dataset);
  String[][] getSortCriteria(String dataset);

  // TODO transforms

  // TODO aggregates

  ////////////////////
  // set selections
  ////////////////////
  // TODO how should animations be included?  They are a property of the selection event, but how to define in a cross-platform way?
  // TODO is this the best way to do coordinates into multidimensional dataset?  Should there also be a specific interface for one-dimensional data sets?  How about an interface that takes an index instead of id?
  // TODO rename hover as probe? I got the term from Curran Kelleher's dissertation, but he said hovering was also known as probing, find another source to cite or cite his?
  void hoverItem(String invoker, String dataset, String identifier);
  void hoverItem(String invoker, String dataset, String[] coordinate);
  void hoverCat(String invoker, String dataset, String attribute, String category);
  void hoverRange(String invoker, String dataset, String attribute, String minVal, String maxVal);
  // TODO how to specify relationship LIKE this coordinate (ie find all points similar to this one)?
  // might need to be able to pass in arbitrary function ala colorfun which would then make this hard to support cross language (ie over QtBridge)
  void hoverLike(String invoker, String dataset, String identifier, String relationship);
  void hoverLike(String invoker, String dataset, String[] coordinate, String relationship);

  // selectType is one of Primary, Secondary, Tertiary.
  // TODO better to have it be primarySelectItems, secondarySelectItems?  selectType allows for extension and default to primary if not specified
  // TODO can OR across multiple calls to selectCats, but how to combine calls to selectItems with calls to selectCats or selectRanges?  OR or override?
  void selectItems(String invoker, String dataset, String[] identifiers, String selectType);
  void deselectItems(String invoker, String dataset, String[] identifiers, String selectType);
  void selectItems(String invoker, String dataset, String[][] coordinates, String selectType);
  void deselectItems(String invoker, String dataset, String[][] coordinates, String selectType);
  // TODO need way to pass arbitrary shape definition (ie function) not just rectangular?
  // TODO need one call of select per attribute?  Or allow multiple at once?  what about multiple ranges per attribute? think need single range per attribute since ANDing across attribute array here. to be able to OR across ranges for single attribute, would need multiple calls to select
  // TODO same question for filter
  void selectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType);
  void deselectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType);
  void selectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType);
  void deselectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType);
  void selectLike(String invoker, String dataset, String[] identifiers, String[] relationships, String selectType);
  void deselectLike(String invoker, String dataset, String[] identifiers, String[] relationships, String selectType);
  void selectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType);
  void deselectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType);
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String invoker, String dataset, String selectType);

  // TODO need filter clearing API too
  void filterCats(String invoker, String dataset, String attribute, String[] categories);
  void toggleCatFilter(String invoker, String dataset, String attribute, String category);
  void filterRanges(String invoker, String dataset, String attribute, String[] mins, String[] maxes);
  // TODO can we specify a coordinate in a multidimensional table as a single string?  Do we even want to?  Can we specify a generic data relationship as a string?  Is there some other representation we want to use here?
  void filterLike(String invoker, String dataset, String[] identifiers, String[] relationships);
  void filterLike(String invoker, String dataset, String[][] coordinates, String[] relationships);
  void clearFilter(String invoker, String dataset);

  // TODO need to figure out a way to specify a continuous color map (colorfun) in some cross-language way.  Some intermediate compromises might include a more generic checkpoints style interface where the colors get specified along with a value and then nicely lerped in between
  void colorCat(String invoker, String dataset, String attribute, String category, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String invoker, String dataset, String attribute, String category, String encoding);

  // nav changes center of window and size of window
  void navItem(String invoker, String dataset, String identifier, String numItems);
  void navItem(String invoker, String dataset, String[] coordinate, String numItems);
  // following works for ordered categorical attribute
  void navVal(String invoker, String dataset, String attribute, String value, String leftVal, String rightVal);
  // following works for unordered categorical attribute
  void navCat(String invoker, String dataset, String attribute, String category, String numCats);
  void navRange(String invoker, String dataset, String attribute, String center, String minVal, String maxVal);
  // width specified in data space
  void navRange(String invoker, String dataset, String attribute, String center, String width);
  void navLike(String invoker, String dataset, String identifier, String relationship, String numLikeItems);
  void navLike(String invoker, String dataset, String[] coordinate, String relationship, String numLikeItems);
  void clearNav(String invoker, String dataset);

  // pan changes center of window, leaves size the same as last nav
  void panItem(String invoker, String dataset, String identifier);
  void panItem(String invoker, String dataset, String[] coordinate);
  void panVal(String invoker, String dataset, String attribute, String value);
  void panCat(String invoker, String dataset, String attribute, String category);
  void panRange(String invoker, String dataset, String attribute, String center);
  void panLike(String invoker, String dataset, String identifier, String relationship);
  void panLike(String invoker, String dataset, String[] coordinate, String relationship);

  // zoom changes size of window, leaving the center at the previous spot
  // TODO add a zoomOut / zoomIn API that allows jumping back to previous zoom
  void zoomItem(String invoker, String dataset, String numItems);
  void zoomVal(String invoker, String dataset, String attribute, String leftVal, String rightVal);
  void zoomCat(String invoker, String dataset, String attribute, String numCats);
  void zoomRange(String invoker, String dataset, String attribute, String minVal, String maxVal);
  // width specified in data space
  void zoomRange(String invoker, String dataset, String attribute, String width);
  void zoomLike(String invoker, String dataset, String numLikeItems);

  void setLOD(String invoker, String dataset, String levelOfDetail);

  ////////////////////
  // get selections
  ////////////////////

  // can have more than one hover id / hover coord when a category has been hovered over
  String[] getHoverIds(String dataset);
  String[][] getHoverCoords(String dataset);
  String getHoverCat(String dataset, String attribute);
  String[] getHoverRange(String dataset, String attribute);
  // TODO how do we want this to work?  It returns the coordinate/relationship pair or just the relationship
  String[] getHoverLike(String dataset);

  String[] getSelectIds(String dataset, String selectType);
  String[][] getSelectCoords(String dataset, String selectType);
  String[] getSelectCats(String dataset, String attribute, String selectType);
  String[][] getSelectRanges(String dataset, String attribute, String selectType);
  String[][] getSelectLike(String dataset, String selectType);
  String[][][] getSelectCriteria(String dataset, String selectType);

  String[] getFilterIds(String dataset);
  String[][] getFilterCoords(String dataset);
  // TODO Doc: There are two uses here that are conflated
  // 1. get the filter specification for the particular attribute
  // 2. get the categories of the filtered data for the particular attribute
  // the first characterizes the possible filtered range for the attribute
  // the second characterizes the spread of the actual filtered data
  // views will need these at different times, so need to specify two interfaces
  // TODO for now, getFilterCats, getFilterRanges will return #1
  String[] getFilterCats(String dataset, String attribute);
  String[][] getFilterRanges(String dataset, String attribute);
  String[][] getFilterLike(String dataset);
  String[][] getFilterCriteria(String dataset);

  // nav changes center of window and size of window
  String getNavCenterId(String dataset);
  String[] getNavCenterCoord(String dataset);
  String[] getNavIds(String dataset);
  String[][] getNavCoords(String dataset);
  String getNumNavItems(String dataset);
  String getNavCenterVal(String dataset, String attribute);
  String getNavLeftVal(String dataset, String attribute);
  String getNavRightVal(String dataset, String attribute);
  String getNumNavCats(String dataset, String attribute);
  String getNavMinVal(String dataset, String attribute);
  String getNavMaxVal(String dataset, String attribute);
  String getNavWidth(String dataset, String attribute);
  String getNavLike(String dataset);
  String getNumNavLike(String dataset);

  String getLOD(String dataset);

  ////////////////////
  // selection colors
  ////////////////////
  // TODO allow for rgba everywhere
  // set hoverColor for ALL datasets
  void hoverColor(String invoker, String[] rgbaColor);
  void hoverColor(String invoker, String dataset, String[] rgbaColor);
  void selectColor(String invoker, String[] rgbaColor, String selectType);
  void selectColor(String invoker, String dataset, String[] rgbaColor, String selectType);
  void filterColor(String invoker, String[] rgbaColor);
  void filterColor(String invoker, String dataset, String[] rgbaColor);
  void likeColor(String invoker, String[] rgbaColor);
  void likeColor(String invoker, String dataset, String[] rgbaColor);
  
  void clearHoverColor(String invoker);
  void clearHoverColor(String invoker, String dataset);
  void clearSelectColor(String invoker, String selectType);
  void clearSelectColor(String invoker, String dataset, String selectType);
  void clearFilterColor(String invoker);
  void clearFilterColor(String invoker, String dataset);
  void clearLikeColor(String invoker);
  void clearLikeColor(String invoker, String dataset);

  String[] getHoverColor(String dataset);
  String[] getSelectColor(String dataset, String selectType);
  String[] getFilterColor(String dataset);
  String[] getLikeColor(String dataset);
  // TODO figure out interface for getting/setting other encodings (shape / size / etc).

  ////////////////////
  // validations
  ////////////////////
  String validateSelectType(String selectType);

} // end interface Delv

// A movie interface to wrap either a stub movie, or Movie from processing.video or something else eventually.  Mostly needed to hook up the movieEvent
interface DelvMovie {
  void read();
}

// DelvView is used to support having multiple processing sketches in both Processing and processing.js

interface DelvView {
  void bindDelv(Delv dlv);
  DelvView dataSet(String dataSetName);
  String name();
  DelvView name(String name);
  void connectSignals();
  void onDataChanged(String source);
  // TODO should resize be handled like other signals or treated specially?
  // for instance, should it be called sizeChanged?
  void resize(int w, int h);
  void resize(int w, int h, boolean doDraw);

  void draw();
  void setup();
  void mouseMoved();
  void mouseOut();
  void mouseClicked();
  void mouseDragged();
  void mousePressed();
  void mouseReleased();
  void mouseScrolled();
  void movieEvent(DelvMovie m);
}

interface DelvDataSet {
  String getName();
  void setName(String name);

  // bind Delv for adding interior datasets
  void bindDelv(Delv dlv);

  // operations
  // sort
  // possible values of sortType: ascending, descending
  void sortByVal(String attribute, String sortType);
  // possible values of similarity sortType: similarity, dissimilarity
  void sortBySimilarity(String identifier, String sortType);
  void sortBySimilarity(String[] coordinate, String sortType);
  void clearSort();
  String[][] getSortCriteria();

  // TODO transforms

  // TODO aggregates

  // TODO graph-like interface

  // identifiers / coordinates
  void addId(String id);
  boolean hasId(String id);
  void addCoord(String[] coord);
  boolean hasCoord(String[] coord);

  String[] getAllIds(String attr);
  String[][] getAllCoords(String attr);
  String[] getHoverIds();
  String[][] getHoverCoords();
  String[] getSelectIds(String selectType);
  String[][] getSelectCoords(String selectType);
  String[] getFilterIds();
  String[][] getFilterCoords();
  String getNavCenterId();
  String[] getNavCenterCoord();
  String[] getNavIds();
  String[][] getNavCoords();

  int getNumIds();
  int getNumCoords();
  String getNextId();
  // return a unique coordinate in nD multidimensional space where n is specified by numCoords
  String[] getNextCoord(int numCoords);
  void removeId(String id);
  void removeCoord(String[] coord);

  // items
  void clearItems();
  void setItem(String attr, String id, String item);
  void setItem(String attr, String[] coord, String item);
  void setFloatItem(String attr, String id, Float item);
  void setFloatItem(String attr, String[] coord, Float item);
  void setFloatArrayItem(String attr, String id, float[] item);
  void setFloatArrayItem(String attr, String[] coord, float[] item);
  void setStringArrayItem(String attr, String id, String[] item);
  void setStringArrayItem(String attr, String[] coord, String[] item);

  String getItem(String attr, String id);
  String getItem(String attr, String[] coord);
  Float getItemAsFloat(String attr, String id);
  Float getItemAsFloat(String attr, String[] coord);
  float[] getItemAsFloatArray(String attr, String id);
  float[] getItemAsFloatArray(String attr, String[] coord);
  String[] getItemAsStringArray(String attr, String id);
  String[] getItemAsStringArray(String attr, String[] coord);

  String[] getAllItems(String attr);
  Float[] getAllItemsAsFloat(String attr);
  float[][] getAllItemsAsFloatArray(String attr);
  String[][] getAllItemsAsStringArray(String attr);

  String getMin(String attr);
  String getMax(String attr);

  String[] getHoverItems(String attr);
  Float[] getHoverItemsAsFloat(String attr);
  float[][] getHoverItemsAsFloatArray(String attr);
  String[][] getHoverItemsAsStringArray(String attr);
  
  String[] getSelectItems(String attr, String selectType);
  Float[] getSelectItemsAsFloat(String attr, String selectType);
  float[][] getSelectItemsAsFloatArray(String attr, String selectType);
  String[][] getSelectItemsAsStringArray(String attr, String selectType);
  
  String[] getFilterItems(String attr);
  Float[] getFilterItemsAsFloat(String attr);
  float[][] getFilterItemsAsFloatArray(String attr);
  String[][] getFilterItemsAsStringArray(String attr);
  
  String[] getNavItems(String attr);
  Float[] getNavItemsAsFloat(String attr);
  float[][] getNavItemsAsFloatArray(String attr);
  String[][] getNavItemsAsStringArray(String attr);
  String getNumNavItems();

  String[] getItemColor(String colorByAttr, String id);
  String[] getItemColor(String colorByAttr, String[] coord);
  String[][] getItemColors(String colorByAttr);
  String[] getItemEncoding(String encodingByAttr, String id);
  String[] getItemEncoding(String encodingByAttr, String[] coord);
  String[][] getItemEncodings(String encodingByAttr);

  String[] getItemAttrColor(String colorByAttr, String id);
  String[] getItemAttrColor(String colorByAttr, String[] coord);
  String[][] getItemAttrColors(String colorByAttr);
  String[] getItemAttrEncoding(String encodingByAttr, String id);
  String[] getItemAttrEncoding(String encodingByAttr, String[] coord);
  String[][] getItemAttrEncodings(String encodingByAttr);

  void hoverItem(String id);
  void hoverItem(String[] coord);

  void selectItems(String[] ids, String selectType);
  void deselectItems(String[] ids, String selectType);
  void selectItems(String[][] coords, String selectType);
  void deselectItems(String[][] coords, String selectType);
  void navItem(String id, String numItems);
  void navItem(String[] coord, String numItems);
  void panItem(String id);
  void panItem(String[] coord);
  void zoomItem(String numItems);

  // attributes
  void clearAttributes();
  void addAttr(DelvAttribute attr);
  Boolean hasAttr(String attr);
  String[] getAttrs();
  String[] getAllCats(String attr);
  String[] getCatColor(String attr, String cat);
  String[][] getCatColors(String attr);
  String[][] getFilterCatColors(String attr);
  String[] getCatEncoding(String attr, String cat);
  String[][] getCatEncodings(String attr);

  void hoverCat(String attr, String cat);
  void hoverRange(String attr, String minVal, String maxVal);
  void selectCats(String[] attrs, String[] cats, String selectType);
  void deselectCats(String[] attrs, String[] cats, String selectType);
  void selectRanges(String[] attrs, String[] mins, String[] maxes, String selectType);
  void deselectRanges(String[] attrs, String[] mins, String[] maxes, String selectType);
  void filterCats(String attr, String[] cats);
  void toggleCatFilter(String attr, String cat);
  void filterRanges(String attr, String[] mins, String[] maxes);

  void colorCat(String attr, String cat, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String attr, String cat, String encoding);

  // following works for ordered categorical attribute
  void navVal(String attr, String value, String leftVal, String rightVal);
  // following works for unordered categorical attribute
  void navCat(String attr, String cat, String numCats);
  void navRange(String attr, String center, String minVal, String maxVal);
  // width specified in data space
  void navRange(String attr, String center, String width);

  void panVal(String attr, String val);
  void panCat(String attr, String cat);
  void panRange(String attr, String center);

  void zoomVal(String attr, String leftVal, String rightVal);
  void zoomCat(String attr, String numCats);
  void zoomRange(String attr, String minVal, String maxVal);
  // width specified in data space
  void zoomRange(String attr, String width);

  String getHoverCat(String attr);
  String[] getHoverRange(String attr);
  String[] getSelectCats(String attr, String selectType);
  String[][] getSelectRanges(String attr, String selectType);
  String[][][] getSelectCriteria(String selectType);
  String[] getFilterCats(String attr);
  String[][] getFilterRanges(String attr);
  String[][] getFilterCriteria();
  String getNavCenterVal(String attr);
  String getNavLeftVal(String attr);
  String getNavRightVal(String attr);
  String getNumNavCats(String attr);
  String getNavMinVal(String attr);
  String getNavMaxVal(String attr);
  String getNavWidth(String attr);

  // Relationships
  void hoverLike(String id, String relationship);
  void hoverLike(String[] coord, String relationship);
  void clearHover();
  
  void selectLike(String[] ids, String[] relationships, String selectType);
  void deselectLike(String[] ids, String[] relationships, String selectType);
  void selectLike(String[][] coords, String[] relationships, String selectType);
  void deselectLike(String[][] coords, String[] relationships, String selectType);
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String selectType);

  void filterLike(String[] ids, String[] relationships);
  void filterLike(String[][] coords, String[] relationships);
  void clearFilter();

  void navLike(String id, String relationship, String numLikeItems);
  void navLike(String[] coord, String relationship, String numLikeItems);
  void clearNav();

  void panLike(String id, String relationship);
  void panLike(String[] coord, String relationship);

  void zoomLike(String numLikeItems);

  void setLOD(String levelOfDetail);

  // TODO how do we want this to work?  It returns the coordinate/relationship pair or just the relationship
  String[] getHoverLike();
  String[][] getSelectLike(String selectType);
  String[][] getFilterLike();
  String getNavLike();
  String getNumNavLike();
  String getLOD();

  // color
  void hoverColor(String[] rgbaColor);
  void selectColor(String[] rgbaColor, String selectType);
  void filterColor(String[] rgbaColor);
  void likeColor(String[] rgbaColor);

  void clearHoverColor();
  void clearSelectColor(String selectType);
  void clearFilterColor();
  void clearLikeColor();

  String[] getHoverColor();
  String[] getSelectColor(String selectType);
  String[] getFilterColor();
  String[] getLikeColor();

} // end interface DelvDataSet

interface DelvAttribute {

  boolean isCategorical();

  String getName();
  void setName(String name);

  // items
  void removeItem(String id);
  void removeItem(String[] coord);
  void clearItems();

  void setItem(String id, String item);
  void setItem(String[] coord, String item);
  void setFloatItem(String id, Float item);
  void setFloatItem(String[] coord, Float item);
  void setFloatArrayItem(String id, float[] item);
  void setFloatArrayItem(String[] coord, float[] item);
  void setStringArrayItem(String id, String[] item);
  void setStringArrayItem(String[] coord, String[] item);

  String getItem(String id);
  String getItem(String[] coord);
  Float getItemAsFloat(String id);
  Float getItemAsFloat(String[] coord);
  float[] getItemAsFloatArray(String id);
  float[] getItemAsFloatArray(String[] coord);
  String[] getItemAsStringArray(String id);
  String[] getItemAsStringArray(String[] coord);

  String[] getAllItems();
  Float[] getAllItemsAsFloat();
  float[][] getAllItemsAsFloatArray();
  String[][] getAllItemsAsStringArray();

  String[] getItemAttrColor(String id);
  String[] getItemAttrColor(String[] coord);
  String[] getItemAttrEncoding(String id);
  String[] getItemAttrEncoding(String[] coord);

  String[] getAllCats();
  String[] getFilterCats();
  String[] getCatColor(String cat);
  String[][] getCatColors();
  String[] getCatEncoding(String cat);
  String[][] getCatEncodings();
  String getMinVal();
  String getMaxVal();

  void colorCat(String cat, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String cat, String encoding);

  // all items pass filter
  void filterAll();
  // all items fail filter
  void filterNone();
  void toggleCatFilter(String cat);
  boolean isFiltered(String id);
  boolean isFiltered(String[] coord);

} // end interface DelvAttribute

interface DelvColorMap {
  // TODO for now only assume RGB tuple, and work on defining interface needs later
  color getColor(String value);
  // TODO somewhat dangerous, decide if this method is even necessary
  // void setMap(DelvColorMap colorMap);
  void setColor(String value, color c);
  void setDefaultColor(color c);
  void drawToFile(String filename);
} // end interface ColorMap

///////////////////////////////////////////
//         BEGIN IMPLEMENTATIONS         //
///////////////////////////////////////////

void notImplemented(String obj, String method, String args) {
  println(""+obj+"."+method+"("+args+") not implemented");
}

public class DelvImpl implements Delv {
  HashMap< String, DelvDataSet > _datasets;
  HashMap< String, DelvView > _views;
  HashMap< String, HashMap< String, String > > _signalHandlers;
  HashMap< String, String[] > _selectColors;
  String[] _defaultColor;
  String[] _hoverColor;
  String[] _filterColor;
  String[] _likeColor;
  HashMap< String, Boolean > _selectColorsSet;
  boolean _hoverColorSet;
  boolean _filterColorSet;
  boolean _likeColorSet;

  public DelvImpl() {
    _datasets = new HashMap<String, DelvDataSet>();
    _views = new HashMap<String, DelvView>();
    _signalHandlers = new HashMap< String, HashMap<String, String> >();
    _defaultColor = toRGBAString( color_(220) );
    _hoverColor = toRGBAString( color_(223, 63, 66) );
    _selectColors = new HashMap< String, String[] >();
    _selectColors.put( "PRIMARY", toRGBAString( color_(109, 218, 114) ) );
    _selectColors.put( "SECONDARY", toRGBAString( color_(234, 153, 57) ) );
    _selectColors.put( "TERTIARY", toRGBAString( color_(234, 231, 57) ) );
    _filterColor = toRGBAString( color_(140, 200, 235) );
    _likeColor = toRGBAString( color_(180, 71, 241) );
    _selectColorsSet = new HashMap< String, Boolean >();
    _selectColorsSet.put( "PRIMARY", false );
    _selectColorsSet.put( "SECONDARY", false );
    _selectColorsSet.put( "TERTIARY", false );
    _hoverColorSet = false;
    _filterColorSet = false;
    _likeColorSet = false;
  }

  void log(String msg) {
    println(msg);
  }

  void emitEvent(String name, String detail) {
    notImplemented("DelvImpl","emitEvent", name +", " + detail);
  }

  void emitSignal(String signal, String invoker, String dataset) {
    log("Emitting " + signal + " sent from " + invoker + " for dataset " + dataset);
    Class[] params = new Class[2];
    params[0] = invoker.getClass();
    params[1] = dataset.getClass();
    Object[] args = new Object[2];
    args[0] = invoker;
    args[1] = dataset;
    // TODO Bug in Processing, following entrySet syntax doesn't compile.
    // iterating on just keys for now instead
    //for (Map.Entry<String, String> entry : signalHandlers.get(signal).entrySet()) {
    if (_signalHandlers.containsKey(signal)) {
      for (String key: _signalHandlers.get(signal).keySet()) {
        // since we don't have entrySet yet, do the following instead:
        // view = views.get(entry.getKey());
        DelvView view = _views.get(key);
        try {
          // since we don't have entrySet yet, do the following instead:
          //Method m = view.getClass().getMethod(entry.getValue(), params);
          Method m = view.getClass().getMethod(_signalHandlers.get(signal).get(key), params);
          m.invoke(view, args);
        } catch (IllegalArgumentException e) {
          e.printStackTrace();
        } catch (IllegalAccessException e) {
          e.printStackTrace();
        } catch (InvocationTargetException e) {
          e.getTargetException().printStackTrace();
        } catch (NoSuchMethodException nsme) {
          System.err.println("There is no public " + _signalHandlers.get(signal).get(key) + "() method " +
                             "in the class " + view.getClass().getName());
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
  }
  void emitSignal(String signal, String invoker, String dataset, String attribute) {
    log("Emitting " + signal + " sent from " + invoker + " for dataset " + dataset + " and attribute " + attribute);
    Class[] params = new Class[3];
    params[0] = invoker.getClass();
    params[1] = dataset.getClass();
    params[2] = attribute.getClass();
    Object[] args = new Object[3];
    args[0] = invoker;
    args[1] = dataset;
    args[2] = attribute;
    // TODO Bug in Processing, following entrySet syntax doesn't compile.
    // iterating on just keys for now instead
    //for (Map.Entry<String, String> entry : signalHandlers.get(signal).entrySet()) {
    if (_signalHandlers.containsKey(signal)) {
      for (String key: _signalHandlers.get(signal).keySet()) {
        // since we don't have entrySet yet, do the following instead:
        // view = views.get(entry.getKey());
        DelvView view = _views.get(key);
        try {
          if (view == null) {
            println("View is null, key: " + key);
          }
          // since we don't have entrySet yet, do the following instead:
          //Method m = view.getClass().getMethod(entry.getValue(), params);
          Method m = view.getClass().getMethod(_signalHandlers.get(signal).get(key), params);
          if (m == null) {
            println("Method is null for view " + view.name());
          }
          m.invoke(view, args);
        } catch (IllegalArgumentException e) {
          e.printStackTrace();
        } catch (IllegalAccessException e) {
          e.printStackTrace();
        } catch (InvocationTargetException e) {
          e.getTargetException().printStackTrace();
        } catch (NoSuchMethodException nsme) {
          System.err.println("There is no public " + _signalHandlers.get(signal).get(key) + "() method " +
                             "in the class " + view.getClass().getName());
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
  }
  void emitSignal(String signal, String invoker, String dataset, String[] attributes) {
    String attrMesg = "";
    for (int i = 0; i < attributes.length; i++) {
      if (i == 0) {
        attrMesg += ", " + attributes[i];
      } else {
         attrMesg = attributes[i];
      }
    }
    log("Emitting " + signal + " sent from " + invoker + " for dataset " + dataset + " and attributes " + attrMesg + " after " + (millis()/1000.0) + " seconds");
    Class[] params = new Class[3];
    params[0] = invoker.getClass();
    params[1] = dataset.getClass();
    params[2] = attributes.getClass();
    Object[] args = new Object[3];
    args[0] = invoker;
    args[1] = dataset;
    args[2] = attributes;
    // TODO Bug in Processing, following entrySet syntax doesn't compile.
    // iterating on just keys for now instead
    if (_signalHandlers.containsKey(signal)) {
      //for (Map.Entry<String, String> entry : signalHandlers.get(signal).entrySet()) {
      for (String key: _signalHandlers.get(signal).keySet()) {
        // since we don't have entrySet yet, do the following instead:
        // view = views.get(entry.getKey());
        DelvView view = _views.get(key);
        try {
          // since we don't have entrySet yet, do the following instead:
          //Method m = view.getClass().getMethod(entry.getValue(), params);
          Method m = view.getClass().getMethod(_signalHandlers.get(signal).get(key), params);
          m.invoke(view, args);
        } catch (IllegalArgumentException e) {
          e.printStackTrace();
        } catch (IllegalAccessException e) {
          e.printStackTrace();
        } catch (InvocationTargetException e) {
          e.getTargetException().printStackTrace();
        } catch (NoSuchMethodException nsme) {
          System.err.println("There is no public " + _signalHandlers.get(signal).get(key) + "() method " +
                             "in the class " + view.getClass().getName());
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
  }
  // TODO should be a more generic way to implement this using String ... var args syntax
  void emitSignal(String signal, String invoker, String dataset, String coordination, String detail) {
    log("Emitting " + signal + " sent from " + invoker + " for dataset " + dataset + ", coordination " + coordination + " and detail " + detail);
    Class[] params = new Class[4];
    params[0] = invoker.getClass();
    params[1] = dataset.getClass();
    params[2] = coordination.getClass();
    params[3] = detail.getClass();
    Object[] args = new Object[4];
    args[0] = invoker;
    args[1] = dataset;
    args[2] = coordination;
    args[3] = detail;
    // TODO Bug in Processing, following entrySet syntax doesn't compile.
    // iterating on just keys for now instead
    //for (Map.Entry<String, String> entry : signalHandlers.get(signal).entrySet()) {
    if (_signalHandlers.containsKey(signal)) {
      for (String key: _signalHandlers.get(signal).keySet()) {
        // since we don't have entrySet yet, do the following instead:
        // view = views.get(entry.getKey());
        DelvView view = _views.get(key);
        try {
          // since we don't have entrySet yet, do the following instead:
          //Method m = view.getClass().getMethod(entry.getValue(), params);
          Method m = view.getClass().getMethod(_signalHandlers.get(signal).get(key), params);
          m.invoke(view, args);
        } catch (IllegalArgumentException e) {
          e.printStackTrace();
        } catch (IllegalAccessException e) {
          e.printStackTrace();
        } catch (InvocationTargetException e) {
          e.getTargetException().printStackTrace();
        } catch (NoSuchMethodException nsme) {
          System.err.println("There is no public " + _signalHandlers.get(signal).get(key) + "() method " +
                             "in the class " + view.getClass().getName());
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
  }

  void connectToSignal(String signal, String name, String method) {
    // TODO figure out how to support callbacks in Java version of Processing (require a naming convention etc?)
    log("Connecting " + signal + " to " + name + "." + method);
    if (!_signalHandlers.containsKey(signal)) {
      _signalHandlers.put(signal, new HashMap<String, String>());
    }
    _signalHandlers.get(signal).put(name, method);
  }
  void disconnectFromSignal(String signal, String name) {
    log("Disconnecting " + signal + " from " + name);
    if (_signalHandlers.containsKey(signal) && _signalHandlers.get(signal).containsKey(name)) {
      _signalHandlers.get(signal).remove(name);
    }
  }

  DelvView getView(String name) {
    return _views.get(name);
  }
  void addView(DelvView view) {
    view.bindDelv(this);
    _views.put(view.name(), view);
  }

  void reloadData() {
    onDataChanged("Delv");
  }
  void onDataChanged(String source) {
    log("reloading data");
     for (DelvView view : _views.values()) {
       view.onDataChanged(source);
     }
     draw();
  }

  void runInThread(Object obj, String name) {
    try {
      Method m = obj.getClass().getMethod(name, new Class[] {});
      m.invoke(obj, new Object[] { });

    } catch (IllegalArgumentException e) {
      e.printStackTrace();
    } catch (IllegalAccessException e) {
      e.printStackTrace();
    } catch (InvocationTargetException e) {
      e.getTargetException().printStackTrace();
    } catch (NoSuchMethodException nsme) {
      System.err.println("There is no public " + name + "() method " +
                         "in the class " + obj.getClass().getName());
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  void addDataSet(String name, DelvDataSet dataset) {
    dataset.bindDelv(this);
    _datasets.put(name, dataset);
  }
  DelvDataSet getDataSet(String name) {
    return _datasets.get(name);
  }
  boolean hasDataSet(String name) {
    return _datasets.containsKey(name);
  }
  void removeDataSet(String name) {
    _datasets.remove(name);
  }

  ////////////////////
  // data attributes
  ////////////////////
  void addAttr(String dataset, DelvAttribute attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.addAttr(attribute);
    } else {
      log("Warning in addAttr! Dataset <"+dataset+"> does not exist.");
    }
  }
  Boolean hasAttr(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.hasAttr(attribute);
    } else {
      log("Warning in hasAttr! Dataset <"+dataset+"> does not exist.");
      return false;
    }
  }
  String[] getAttrs(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getAttrs();
    } else {
      log("Warning in getAttrs! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[] getAllCats(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getAllCats(attribute);
    } else {
      log("Warning in getAllCats! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[] getCatColor(String dataset, String attribute, String category) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getCatColor(attribute, category);
    } else {
      log("Warning in getCatColor! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getCatColors(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getCatColors(attribute);
    } else {
      log("Warning in getCatColors! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String[][] getFilterCatColors(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterCatColors(attribute);
    } else {
      log("Warning in getFilterCatColors! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String[] getCatEncoding(String dataset, String attribute, String category) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getCatEncoding(attribute, category);
    } else {
      log("Warning in getCatEncoding! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getCatEncodings(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getCatEncodings(attribute);
    } else {
      log("Warning in getCatEncodings! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }

  ////////////////////
  // data items
  ////////////////////
  void clearItems(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearItems();
    } else {
      log("Warning in clearItems! Dataset <"+dataset+"> does not exist.");
    }
  }
  void setItem(String dataset, String attribute, String identifier, String item) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.setItem(attribute, identifier, item);
    } else {
      log("Warning in setItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void setItem(String dataset, String attribute, String[] coordinate, String item) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.setItem(attribute, coordinate, item);
    } else {
      log("Warning in setItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void setFloatItem(String dataset, String attribute, String identifier, Float item) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.setFloatItem(attribute, identifier, item);
    } else {
      log("Warning in setFloatItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void setFloatItem(String dataset, String attribute, String[] coordinate, Float item) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.setFloatItem(attribute, coordinate, item);
    } else {
      log("Warning in setFloatItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void setFloatArrayItem(String dataset, String attribute, String identifier, float[] item) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.setFloatArrayItem(attribute, identifier, item);
    } else {
      log("Warning in setFloatArrayItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void setFloatArrayItem(String dataset, String attribute, String[] coordinate, float[] item) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.setFloatArrayItem(attribute, coordinate, item);
    } else {
      log("Warning in setFloatArrayItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void setStringArrayItem(String dataset, String attribute, String identifier, String[] item) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.setStringArrayItem(attribute, identifier, item);
    } else {
      log("Warning in setStringArrayItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void setStringArrayItem(String dataset, String attribute, String[] coordinate, String[] item) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.setStringArrayItem(attribute, coordinate, item);
    } else {
      log("Warning in setStringArrayItem! Dataset <"+dataset+"> does not exist.");
    }
  }

  String getItem(String dataset, String attribute, String identifier) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItem(attribute,identifier);
    } else {
      log("Warning in getItem! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getItem(String dataset, String attribute, String[] coordinate) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItem(attribute,coordinate);
    } else {
      log("Warning in getItem! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  Float getItemAsFloat(String dataset, String attribute, String identifier) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemAsFloat(attribute,identifier);
    } else {
      log("Warning in getItemAsFloat! Dataset <"+dataset+"> does not exist.");
      return null;
    }
  }
  Float getItemAsFloat(String dataset, String attribute, String[] coordinate) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemAsFloat(attribute,coordinate);
    } else {
      log("Warning in getItemAsFloat! Dataset <"+dataset+"> does not exist.");
      return null;
    }
  }
  float[] getItemAsFloatArray(String dataset, String attribute, String identifier) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemAsFloatArray(attribute,identifier);
    } else {
      log("Warning in getItemAsFloatArray! Dataset <"+dataset+"> does not exist.");
      return new float[0];
    }
  }
  float[] getItemAsFloatArray(String dataset, String attribute, String[] coordinate) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemAsFloatArray(attribute,coordinate);
    } else {
      log("Warning in getItemAsFloatArray! Dataset <"+dataset+"> does not exist.");
      return new float[0];
    }
  }
  String[] getItemAsStringArray(String dataset, String attribute, String identifier) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemAsStringArray(attribute,identifier);
    } else {
      log("Warning in getItemAsStringArray! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[] getItemAsStringArray(String dataset, String attribute, String[] coordinate) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemAsStringArray(attribute,coordinate);
    } else {
      log("Warning in getItemAsStringArray! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }

  String[] getAllItems(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getAllItems(attribute);
    } else {
      log("Warning in getAllItems! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  // TODO Float, float, Double or double here?
  Float[] getAllItemsAsFloat(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getAllItemsAsFloat(attribute);
    } else {
      log("Warning in getAllItemsAsFloat! Dataset <"+dataset+"> does not exist.");
      return new Float[0];
    }
  }
  float[][] getAllItemsAsFloatArray(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getAllItemsAsFloatArray(attribute);
    } else {
      log("Warning in getAllItemsAsFloatArray! Dataset <"+dataset+"> does not exist.");
      return new float[0][];
    }
  }
  String[][] getAllItemsAsStringArray(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getAllItemsAsStringArray(attribute);
    } else {
      log("Warning in getAllItemsAsStringArray! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }

  String getMin(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getMin(attribute);
    } else {
      log("Warning in getMin! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getMax(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getMax(attribute);
    } else {
      log("Warning in getMax! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }

  String[] getHoverItems(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverItems(attribute);
    } else {
      log("Warning in getHoverItems! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  Float[] getHoverItemsAsFloat(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverItemsAsFloat(attribute);
    } else {
      log("Warning in getHoverItemsAsFloat! Dataset <"+dataset+"> does not exist.");
      return new Float[0];
    }
  }
  
  float[][] getHoverItemsAsFloatArray(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverItemsAsFloatArray(attribute);
    } else {
      log("Warning in getHoverItemsAsFloatArray! Dataset <"+dataset+"> does not exist.");
      return new float[0][];
    }
  }
  String[][] getHoverItemsAsStringArray(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverItemsAsStringArray(attribute);
    } else {
      log("Warning in getHoverItemsAsStringArray! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }

  String[] getSelectItems(String dataset, String attribute, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectItems(attribute, selectType);
    } else {
      log("Warning in getSelectItems! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  Float[] getSelectItemsAsFloat(String dataset, String attribute, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectItemsAsFloat(attribute, selectType);
    } else {
      log("Warning in getSelectItemsAsFloat! Dataset <"+dataset+"> does not exist.");
      return new Float[0];
    }
  }
  float[][] getSelectItemsAsFloatArray(String dataset, String attribute, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectItemsAsFloatArray(attribute, selectType);
    } else {
      log("Warning in getSelectItemsAsFloatArray! Dataset <"+dataset+"> does not exist.");
      return new float[0][];
    }
  }
  String[][] getSelectItemsAsStringArray(String dataset, String attribute, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectItemsAsStringArray(attribute, selectType);
    } else {
      log("Warning in getSelectItemsAsStringArray! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }

  String[] getFilterItems(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterItems(attribute);
    } else {
      log("Warning in getFilterItems! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  Float[] getFilterItemsAsFloat(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterItemsAsFloat(attribute);
    } else {
      log("Warning in getFilterItemsAsFloat! Dataset <"+dataset+"> does not exist.");
      return new Float[0];
    }
  }
  float[][] getFilterItemsAsFloatArray(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterItemsAsFloatArray(attribute);
    } else {
      log("Warning in getFilterItemsAsFloatArray! Dataset <"+dataset+"> does not exist.");
      return new float[0][];
    }
  }
  String[][] getFilterItemsAsStringArray(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterItemsAsStringArray(attribute);
    } else {
      log("Warning in getFilterItemsAsStringArray! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }

  String[] getNavItems(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavItems(attribute);
    } else {
      log("Warning in getNavItems! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  Float[] getNavItemsAsFloat(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavItemsAsFloat(attribute);
    } else {
      log("Warning in getNavItemsAsFloat! Dataset <"+dataset+"> does not exist.");
      return new Float[0];
    }
  }
  float[][] getNavItemsAsFloatArray(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavItemsAsFloatArray(attribute);
    } else {
      log("Warning in getNavItemsAsFloatArray! Dataset <"+dataset+"> does not exist.");
      return new float[0][];
    }
  }
  String[][] getNavItemsAsStringArray(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavItemsAsStringArray(attribute);
    } else {
      log("Warning in getNavItemsAsStringArray! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }

  String[] getItemColor(String dataset, String colorByAttribute, String identifier) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemColor(colorByAttribute, identifier);
    } else {
      log("Warning in getItemColor! Dataset <"+dataset+"> does not exist.");
      return _defaultColor;
    }
  }
  String[] getItemColor(String dataset, String colorByAttribute, String[] coordinate) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemColor(colorByAttribute, coordinate);
    } else {
      log("Warning in getItemColor! Dataset <"+dataset+"> does not exist.");
      return _defaultColor;
    }
  }
  String[][] getItemColors(String dataset, String colorByAttribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemColors(colorByAttribute);
    } else {
      log("Warning in getItemColors! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String[] getItemEncoding(String dataset, String encodingByAttribute, String identifier) {
    notImplemented("DelvImpl","getItemEncoding", dataset + ", " + encodingByAttribute + ", " + identifier);
    return new String[0];
  }
  String[] getItemEncoding(String dataset, String encodingByAttribute, String[] coordinate) {
    notImplemented("DelvImpl","getItemEncoding", dataset + ", " + encodingByAttribute + ", <coordinates>");
    return new String[0];
  }
  String[][] getItemEncodings(String dataset, String encodingByAttribute) {
    notImplemented("DelvImpl","getItemEncodings", dataset + ", " + encodingByAttribute);
    return new String[0][];
  }
  
  String[] getItemAttrColor(String dataset, String colorByAttribute, String identifier) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemAttrColor(colorByAttribute, identifier);
    } else {
      log("Warning in getItemAttrColor! Dataset <"+dataset+"> does not exist.");
      return _defaultColor;
    }
  }
  String[] getItemAttrColor(String dataset, String colorByAttribute, String[] coordinate) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemAttrColor(colorByAttribute, coordinate);
    } else {
      log("Warning in getItemAttrColor! Dataset <"+dataset+"> does not exist.");
      return _defaultColor;
    }
  }
  String[][] getItemAttrColors(String dataset, String colorByAttribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getItemAttrColors(colorByAttribute);
    } else {
      log("Warning in getItemAttrColors! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String[] getItemAttrEncoding(String dataset, String encodingByAttribute, String identifier) {
    notImplemented("DelvImpl","getItemAttrEncoding", dataset + ", " + encodingByAttribute + ", " + identifier);
    return new String[0];
  }
  String[] getItemAttrEncoding(String dataset, String encodingByAttribute, String[] coordinate) {
    notImplemented("DelvImpl","getItemAttrEncoding", dataset + ", " + encodingByAttribute + ", <coordinates>");
    return new String[0];
  }
  String[][] getItemAttrEncodings(String dataset, String encodingByAttribute) {
    notImplemented("DelvImpl","getItemAttrEncodings", dataset + ", " + encodingByAttribute);
    return new String[0][];
  }

  ////////////////////
  // data coordinates
  ////////////////////
  String[] getAllIds(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getAllIds(attribute);
    } else {
      log("Warning in getAllIds! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getAllCoords(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getAllCoords(attribute);
    } else {
      log("Warning in getAllCoords! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }

  boolean hasId(String dataset, String id) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.hasId(id);
    } else {
      log("Warning in hasId! Dataset <"+dataset+"> does not exist.");
      return false;
    }
  }
  boolean hasCoord(String dataset, String[] coord) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.hasCoord(coord);
    } else {
      log("Warning in hasCoord! Dataset <"+dataset+"> does not exist.");
      return false;
    }
  }


  ////////////////////
  // data as graph
  ////////////////////

  // TODO put in graph-like interface

  ////////////////////
  // data operations
  ////////////////////
  // sort
  // possible values of sortType: ascending, descending
  void sortByVal(String invoker, String dataset, String attribute, String sortType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.sortByVal(attribute, sortType);
      emitSignal("sortChanged", invoker, dataset, attribute);
    } else {
      log("Warning in sortByVal! Dataset <"+dataset+"> does not exist.");
    }
  }
  // possible values of similarity sortType: similarity, dissimilarity
  // TODO, this is vague, really need a way to define a similarity measure.
  void sortBySimilarity(String invoker, String dataset, String identifier, String sortType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.sortBySimilarity(identifier, sortType);
      emitSignal("sortChanged", invoker, dataset, identifier);
    } else {
      log("Warning in sortBySimilarity! Dataset <"+dataset+"> does not exist.");
    }
  }
  void sortBySimilarity(String invoker, String dataset, String[] coordinate, String sortType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.sortBySimilarity(coordinate, sortType);
      emitSignal("sortChanged", invoker, dataset, coordinate);
    } else {
      log("Warning in sortBySimilarity! Dataset <"+dataset+"> does not exist.");
    }
  }
  void clearSort(String invoker, String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearSort();
      emitSignal("sortChanged", invoker, dataset, "");
    } else {
      log("Warning in clearSort! Dataset <"+dataset+"> does not exist.");
    }
  }
  String[][] getSortCriteria(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSortCriteria();
    } else {
      log("Warning in getSortCriteria! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }

  // TODO transforms

  // TODO aggregates

  ////////////////////
  // set selections
  ////////////////////
  // TODO is this the best way to do coordinates into multidimensional dataset?  Should there also be a specific interface for one-dimensional data sets?  How about an interface that takes an index instead of id?
  // TODO rename hover as probe? I got the term from Curran Kelleher's dissertation, but he said hovering was also known as probing, find another source to cite or cite his?
  void hoverItem(String invoker, String dataset, String identifier) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverItem(identifier);
      emitSignal("hoverChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in hoverItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void hoverItem(String invoker, String dataset, String[] coordinate) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverItem(coordinate);
      emitSignal("hoverChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in hoverItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void hoverCat(String invoker, String dataset, String attribute, String category) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverCat(attribute, category);
      emitSignal("hoverChanged", invoker, dataset, "CAT");
    } else {
      log("Warning in hoverCat! Dataset <"+dataset+"> does not exist.");
    }
  }
  void hoverRange(String invoker, String dataset, String attribute, String minVal, String maxVal) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverRange(attribute, minVal, maxVal);
      emitSignal("hoverChanged", invoker, dataset, "RANGE");
    } else {
      log("Warning in hoverRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  // TODO how to specify relationship LIKE this coordinate (ie find all points similar to this one)?
  // might need to be able to pass in arbitrary function ala colorfun which would then make this hard to support cross language (ie over QtBridge)
  void hoverLike(String invoker, String dataset, String identifier, String relationship) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverLike(identifier, relationship);
      emitSignal("hoverChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in hoverLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void hoverLike(String invoker, String dataset, String[] coordinate, String relationship) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverLike(coordinate, relationship);
      // TODO transmit coordinate or relationship or both?
      emitSignal("hoverChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in hoverLike! Dataset <"+dataset+"> does not exist.");
    }
  }

  // selectType is one of PRIMARY, SECONDARY, TERTIARY.
  String validateSelectType(String selectType) {
    // for now though, allow any select type, if empty, default to primary
    if (selectType.equals("")) {
      return "PRIMARY";
    } else {
      return selectType.toUpperCase();
    }
  }
  // TODO better to have it be primarySelectItems, secondarySelectItems?  selectType allows for extension and default to primary if not specified
  // TODO can OR across multiple calls to selectCats, but how to combine calls to selectItems with calls to selectCats or selectRanges?  OR or override?
  void selectItems(String invoker, String dataset, String[] identifiers, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectItems(identifiers, selectType);
      emitSignal("selectChanged", invoker, dataset, "ITEM", selectType);
    } else {
      log("Warning in selectItems! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectItems(String invoker, String dataset, String[] identifiers, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectItems(identifiers, selectType);
      emitSignal("selectChanged", invoker, dataset, "ITEM", selectType);
    } else {
      log("Warning in deselectItems! Dataset <"+dataset+"> does not exist.");
    }
  }
  void selectItems(String invoker, String dataset, String[][] coordinates, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectItems(coordinates, selectType);
      emitSignal("selectChanged", invoker, dataset, "ITEM", selectType);
    } else {
      log("Warning in selectItems! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectItems(String invoker, String dataset, String[][] coordinates, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectItems(coordinates, selectType);
      emitSignal("selectChanged", invoker, dataset, "ITEM", selectType);
    } else {
      log("Warning in deselectItems! Dataset <"+dataset+"> does not exist.");
    }
  }
  // TODO need way to pass arbitrary shape definition (ie function) not just rectangular?
  // TODO need one call of select per attribute?  Or allow multiple at once?  what about multiple ranges per attribute? think need single range per attribute since ANDing across attribute array here. to be able to OR across ranges for single attribute, would need multiple calls to select
  // TODO same question for filter
  void selectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectCats(attributes, categories, selectType);
      emitSignal("selectChanged", invoker, dataset, "CAT", selectType);
    } else {
      log("Warning in selectCats! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectCats(attributes, categories, selectType);
      emitSignal("selectChanged", invoker, dataset, "CAT", selectType);
    } else {
      log("Warning in deselectCats! Dataset <"+dataset+"> does not exist.");
    }
  }
  void selectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectRanges(attributes, mins, maxes, selectType);
      emitSignal("selectChanged", invoker, dataset, "RANGE", selectType);
    } else {
      log("Warning in selectRanges! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectRanges(attributes, mins, maxes, selectType);
      emitSignal("selectChanged", invoker, dataset, "RANGE", selectType);
    } else {
      log("Warning in deselectRanges! Dataset <"+dataset+"> does not exist.");
    }
  }
  void selectLike(String invoker, String dataset, String[] identifiers, String[] relationships, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectLike(identifiers, relationships, selectType);
      emitSignal("selectChanged", invoker, dataset, "LIKE", selectType);
    } else {
      log("Warning in selectLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectLike(String invoker, String dataset, String[] identifiers, String[] relationships, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectLike(identifiers, relationships, selectType);
      emitSignal("selectChanged", invoker, dataset, "LIKE", selectType);
    } else {
      log("Warning in deselectLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void selectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectLike(coordinates, relationships, selectType);
      emitSignal("selectChanged", invoker, dataset, "LIKE", selectType);
    } else {
      log("Warning in selectLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectLike(coordinates, relationships, selectType);
      emitSignal("selectChanged", invoker, dataset, "LIKE", selectType);
    } else {
      log("Warning in deselectLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String invoker, String dataset, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearSelect(selectType);
      emitSignal("selectChanged", invoker, dataset, "CLEAR", selectType);
    } else {
      log("Warning in clearSelect! Dataset <"+dataset+"> does not exist.");
    }
  }

  // TODO need filter clearing API too
  void filterCats(String invoker, String dataset, String attribute, String[] categories) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.filterCats(attribute, categories);
      emitSignal("filterChanged", invoker, dataset, "CAT");
    } else {
      log("Warning in filterCats! Dataset <"+dataset+"> does not exist.");
    }
  }
  void toggleCatFilter(String invoker, String dataset, String attribute, String category) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.toggleCatFilter(attribute, category);
      emitSignal("filterChanged", invoker, dataset, "CAT");
    } else {
      log("Warning in toggleCatFilter! Dataset <"+dataset+"> does not exist.");
    }
  }

  void filterRanges(String invoker, String dataset, String attribute, String[] mins, String[] maxes) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.filterRanges(attribute, mins, maxes);
      emitSignal("filterChanged", invoker, dataset, "RANGE");
    } else {
      log("Warning in filterRanges! Dataset <"+dataset+"> does not exist.");
    }
  }
  // TODO can we specify a coordinate in a multidimensional table as a single string?  Do we even want to?  Can we specify a generic data relationship as a string?  Is there some other representation we want to use here?
  void filterLike(String invoker, String dataset, String[] identifiers, String[] relationships) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.filterLike(identifiers, relationships);
      emitSignal("filterChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in filterLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void filterLike(String invoker, String dataset, String[][] coordinates, String[] relationships) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.filterLike(coordinates, relationships);
      emitSignal("filterChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in filterLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void clearFilter(String invoker, String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearFilter();
      emitSignal("filterChanged", invoker, dataset, "CLEAR");
    } else {
      log("Warning in clearFilter! Dataset <"+dataset+"> does not exist.");
    }
  }

  // TODO need to figure out a way to specify a continuous color map (colorfun) in some cross-language way.  Some intermediate compromises might include a more generic checkpoints style interface where the colors get specified along with a value and then nicely lerped in between
  void colorCat(String invoker, String dataset, String attribute, String category, String[] rgbaColor) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.colorCat(attribute, category, rgbaColor);
      emitSignal("colorChanged", invoker, dataset, attribute);
    } else {
      log("Warning in colorCat! Dataset <"+dataset+"> does not exist.");
    }
  }

  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String invoker, String dataset, String attribute, String category, String encoding) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.encodeCat(attribute, category, encoding);
      emitSignal("encodingChanged", invoker, dataset, attribute);
    } else {
      log("Warning in encodeCat! Dataset <"+dataset+"> does not exist.");
    }
  }

  // nav changes center of window and size of window
  void navItem(String invoker, String dataset, String identifier, String numItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navItem(identifier, numItems);
      emitSignal("navChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in navItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void navItem(String invoker, String dataset, String[] coordinate, String numItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navItem(coordinate, numItems);
      emitSignal("navChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in navItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  // following works for ordered categorical attribute
  void navVal(String invoker, String dataset, String attribute, String value, String leftVal, String rightVal) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navVal(attribute, value, leftVal, rightVal);
      emitSignal("navChanged", invoker, dataset, "VAL", attribute);
    } else {
      log("Warning in navVal! Dataset <"+dataset+"> does not exist.");
    }
  }
  // following works for unordered categorical attribute
  void navCat(String invoker, String dataset, String attribute, String category, String numCats) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navCat(attribute, category, numCats);
      emitSignal("navChanged", invoker, dataset, "CAT", attribute);
    } else {
      log("Warning in navCat! Dataset <"+dataset+"> does not exist.");
    }
  }
  void navRange(String invoker, String dataset, String attribute, String center, String minVal, String maxVal) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navRange(attribute, center, minVal, maxVal);
      emitSignal("navChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in navRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  // width specified in data space
  void navRange(String invoker, String dataset, String attribute, String center, String width) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navRange(attribute, center, width);
      emitSignal("navChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in navRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  void navLike(String invoker, String dataset, String identifier, String relationship, String numLikeItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navLike(identifier, relationship, numLikeItems);
      emitSignal("navChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in navLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void navLike(String invoker, String dataset, String[] coordinate, String relationship, String numLikeItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navLike(coordinate, relationship, numLikeItems);
      emitSignal("navChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in navLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void clearNav(String invoker, String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearNav();
      emitSignal("navChanged", invoker, dataset, "CLEAR");
    } else {
      log("Warning in clearNav! Dataset <"+dataset+"> does not exist.");
    }
  }

  // pan changes center of window, leaves size the same as last nav
  void panItem(String invoker, String dataset, String identifier) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panItem(identifier);
      emitSignal("navChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in panItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panItem(String invoker, String dataset, String[] coordinate) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panItem(coordinate);
      emitSignal("navChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in panItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panVal(String invoker, String dataset, String attribute, String value) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panVal(attribute, value);
      emitSignal("navChanged", invoker, dataset, "VAL", attribute);
    } else {
      log("Warning in panVal! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panCat(String invoker, String dataset, String attribute, String category) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panCat(attribute, category);
      emitSignal("navChanged", invoker, dataset, "CAT", attribute);
    } else {
      log("Warning in panCat! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panRange(String invoker, String dataset, String attribute, String center) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panRange(attribute, center);
      emitSignal("navChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in panRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panLike(String invoker, String dataset, String identifier, String relationship) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panLike(identifier, relationship);
      emitSignal("navChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in panLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panLike(String invoker, String dataset, String[] coordinate, String relationship) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panLike(coordinate, relationship);
      emitSignal("navChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in panLike! Dataset <"+dataset+"> does not exist.");
    }
  }

  // zoom changes size of window, leaving the center at the previous spot
  // TODO add a zoomOut / zoomIn API that allows jumping back to previous zoom
  void zoomItem(String invoker, String dataset, String numItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomItem(numItems);
      emitSignal("navChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in zoomItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void zoomVal(String invoker, String dataset, String attribute, String leftVal, String rightVal) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomVal(attribute, leftVal, rightVal);
      emitSignal("navChanged", invoker, dataset, "VAL", attribute);
    } else {
      log("Warning in zoomVal! Dataset <"+dataset+"> does not exist.");
    }
  }
  void zoomCat(String invoker, String dataset, String attribute, String numCats) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomCat(attribute, numCats);
      emitSignal("navChanged", invoker, dataset, "CAT", attribute);
    } else {
      log("Warning in zoomCat! Dataset <"+dataset+"> does not exist.");
    }
  }
  void zoomRange(String invoker, String dataset, String attribute, String minVal, String maxVal) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomRange(attribute, minVal, maxVal);
      emitSignal("navChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in zoomRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  // width specified in data space
  void zoomRange(String invoker, String dataset, String attribute, String width) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomRange(attribute, width);
      emitSignal("navChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in zoomRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  void zoomLike(String invoker, String dataset, String numLikeItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomLike(numLikeItems);
      emitSignal("navChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in zoomLike! Dataset <"+dataset+"> does not exist.");
    }
  }

  void setLOD(String invoker, String dataset, String levelOfDetail) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.setLOD(levelOfDetail);
      emitSignal("lodChanged", invoker, dataset);
    } else {
      log("Warning in setLOD! Dataset <"+dataset+"> does not exist.");
    }
  }

  ////////////////////
  // get selections
  ////////////////////

  String[] getHoverIds(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverIds();
    } else {
      log("Warning in getHoverIds! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getHoverCoords(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverCoords();
    } else {
      log("Warning in getHoverCoords! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String getHoverCat(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverCat(attribute);
    } else {
      log("Warning in getHoverCat! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String[] getHoverRange(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverRange(attribute);
    } else {
      log("Warning in getHoverRange! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  // TODO how do we want this to work?  It returns the coordinate/relationship pair or just the relationship
  String[] getHoverLike(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverLike();
    } else {
      log("Warning in getHoverLike! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }

  String[] getSelectIds(String dataset, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectIds(selectType);
    } else {
      log("Warning in getSelectIds! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getSelectCoords(String dataset, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectCoords(selectType);
    } else {
      log("Warning in getSelectCoords! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String[] getSelectCats(String dataset, String attribute, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectCats(attribute, selectType);
    } else {
      log("Warning in getSelectCats! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getSelectRanges(String dataset, String attribute, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectRanges(attribute, selectType);
    } else {
      log("Warning in getSelectRanges! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String[][] getSelectLike(String dataset, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectLike(selectType);
    } else {
      log("Warning in getSelectLike! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String[][][] getSelectCriteria(String dataset, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectCriteria(selectType);
    } else {
      log("Warning in getSelectCriteria! Dataset <"+dataset+"> does not exist.");
      return new String[0][][];
    }
  }

  String[] getFilterIds(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterIds();
    } else {
      log("Warning in getFilterIds! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getFilterCoords(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterCoords();
    } else {
      log("Warning in getFilterCoords! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String[] getFilterCats(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterCats(attribute);
    } else {
      log("Warning in getFilterCats! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getFilterRanges(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterRanges(attribute);
    } else {
      log("Warning in getFilterRanges! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String[][] getFilterLike(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterLike();
    } else {
      log("Warning in getFilterLike! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String[][] getFilterCriteria(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterCriteria();
    } else {
      log("Warning in getFilterCriteria! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }

  // nav changes center of window and size of window
  String getNavCenterId(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavCenterId();
    } else {
      log("Warning in getNavCenterId! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String[] getNavCenterCoord(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavCenterCoord();
    } else {
      log("Warning in getNavCenterCoord! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[] getNavIds(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavIds();
    } else {
      log("Warning in getNavIds! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getNavCoords(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavCoords();
    } else {
      log("Warning in getNavCoords! Dataset <"+dataset+"> does not exist.");
      return new String[0][];
    }
  }
  String getNumNavItems(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNumNavItems();
    } else {
      log("Warning in getNumNavItems! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavCenterVal(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavCenterVal(attribute);
    } else {
      log("Warning in getNavCenterVal! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavLeftVal(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavLeftVal(attribute);
    } else {
      log("Warning in getNavLeftVal! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavRightVal(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavRightVal(attribute);
    } else {
      log("Warning in getNavRightVal! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNumNavCats(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNumNavCats(attribute);
    } else {
      log("Warning in getNumNavCats! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavMinVal(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavMinVal(attribute);
    } else {
      log("Warning in getNavMinVal! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavMaxVal(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavMaxVal(attribute);
    } else {
      log("Warning in getNavMaxVal! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavWidth(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavWidth(attribute);
    } else {
      log("Warning in getNavWidth! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavLike(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavLike();
    } else {
      log("Warning in getNavLike! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNumNavLike(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNumNavLike();
    } else {
      log("Warning in getNumNavLike! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }

  String getLOD(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getLOD();
    } else {
      log("Warning in getLOD! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }

  ////////////////////
  // selection colors
  ////////////////////
  // TODO allow for rgba everywhere
  void hoverColor(String invoker, String[] rgbaColor) {
    _hoverColor = rgbaColor;
    _hoverColorSet = true;
    for (String dataset : _datasets.keySet()) {
      DelvDataSet ds = getDataSet(dataset);
      ds.hoverColor(rgbaColor);
      emitSignal("hoverColorChanged", invoker, dataset);
    }
  }
  void hoverColor(String invoker, String dataset, String[] rgbaColor) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverColor(rgbaColor);
      emitSignal("hoverColorChanged", invoker, dataset);
    } else {
      log("Warning in hoverColor! Dataset <"+dataset+"> does not exist.");
    }
  }
  void selectColor(String invoker, String[] rgbaColor, String selectType) {
    selectType = validateSelectType(selectType);
    if (_selectColors.containsKey(selectType)) {
      _selectColors.put(selectType, rgbaColor);
      _selectColorsSet.put(selectType, true);
    }
    for (String dataset : _datasets.keySet()) {
      DelvDataSet ds = getDataSet(dataset);
      ds.selectColor(rgbaColor, selectType);
      emitSignal("selectColorChanged", invoker, dataset, selectType);
    }
  }
  void selectColor(String invoker, String dataset, String[] rgbaColor, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectColor(rgbaColor, selectType);
      emitSignal("selectColorChanged", invoker, dataset, selectType);
    } else {
      log("Warning in selectColor! Dataset <"+dataset+"> does not exist.");
    }
  }
  void filterColor(String invoker, String[] rgbaColor) {
    _filterColor = rgbaColor;
    _filterColorSet = true;
    for (String dataset : _datasets.keySet()) {
      DelvDataSet ds = getDataSet(dataset);
      ds.filterColor(rgbaColor);
      emitSignal("filterColorChanged", invoker, dataset);
    }
  }
  void filterColor(String invoker, String dataset, String[] rgbaColor) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.filterColor(rgbaColor);
      emitSignal("filterColorChanged", invoker, dataset);
    } else {
      log("Warning in filterColor! Dataset <"+dataset+"> does not exist.");
    }
  }
  void likeColor(String invoker, String[] rgbaColor) {
    _likeColor = rgbaColor;
    _likeColorSet = true;
    for (String dataset : _datasets.keySet()) {
      DelvDataSet ds = getDataSet(dataset);
      ds.likeColor(rgbaColor);
      emitSignal("likeColorChanged", invoker, dataset);
    }
  }
  void likeColor(String invoker, String dataset, String[] rgbaColor) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.likeColor(rgbaColor);
      emitSignal("likeColorChanged", invoker, dataset);
    } else {
      log("Warning in likeColor! Dataset <"+dataset+"> does not exist.");
    }
  }
  void clearHoverColor(String invoker) {
    _hoverColorSet = false;
    for (String dataset : _datasets.keySet()) {
      DelvDataSet ds = getDataSet(dataset);
      ds.clearHoverColor();
      emitSignal("hoverColorChanged", invoker, dataset);
    }
  }
  void clearHoverColor(String invoker, String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearHoverColor();
      emitSignal("hoverColorChanged", invoker, dataset);
    } else {
      log("Warning in clearHoverColor! Dataset <"+dataset+"> does not exist.");
    }
  }
  void clearSelectColor(String invoker, String selectType) {
    selectType = validateSelectType(selectType);
    if (_selectColors.containsKey(selectType)) {
      _selectColorsSet.put(selectType, false);
    }
    for (String dataset : _datasets.keySet()) {
      DelvDataSet ds = getDataSet(dataset);
      ds.clearSelectColor(selectType);
      emitSignal("selectColorChanged", invoker, dataset, selectType);
    }
  }
  void clearSelectColor(String invoker, String dataset, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearSelectColor(selectType);
      emitSignal("selectColorChanged", invoker, dataset, selectType);
    } else {
      log("Warning in clearSelectColor! Dataset <"+dataset+"> does not exist.");
    }
  }
  void clearFilterColor(String invoker) {
    _filterColorSet = false;
    for (String dataset : _datasets.keySet()) {
      DelvDataSet ds = getDataSet(dataset);
      ds.clearFilterColor();
      emitSignal("filterColorChanged", invoker, dataset);
    }
  }
  void clearFilterColor(String invoker, String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearFilterColor();
      emitSignal("filterColorChanged", invoker, dataset);
    } else {
      log("Warning in clearFilterColor! Dataset <"+dataset+"> does not exist.");
    }
  }
  void clearLikeColor(String invoker) {
    _likeColorSet = true;
    for (String dataset : _datasets.keySet()) {
      DelvDataSet ds = getDataSet(dataset);
      ds.clearLikeColor();
      emitSignal("likeColorChanged", invoker, dataset);
    }
  }
  void clearLikeColor(String invoker, String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearLikeColor();
      emitSignal("likeColorChanged", invoker, dataset);
    } else {
      log("Warning in clearLikeColor! Dataset <"+dataset+"> does not exist.");
    }
  }

  String[] getHoverColor(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      String[] colStr = ds.getHoverColor();
      if (colStr.length < 1) {
        return _hoverColor;
      } else {
        return colStr;
      }
    } else {
      log("Warning in getHoverColor! Dataset <"+dataset+"> does not exist.");
      return _hoverColor;
    }
  }
  String[] getSelectColor(String dataset, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      String[] colStr = ds.getSelectColor(selectType);
      if (colStr.length < 1) {
        return _selectColors.get(selectType);
      } else {
        return colStr;
      }
    } else {
      log("Warning in getSelectColor! Dataset <"+dataset+"> does not exist.");
      return _selectColors.get(selectType);
    }
  }
  String[] getFilterColor(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      String[] colStr = ds.getFilterColor();
      if (colStr.length < 1) {
        return _filterColor;
      } else {
        return colStr;
      }
    } else {
      log("Warning in getFilterColor! Dataset <"+dataset+"> does not exist.");
      return _filterColor;
    }
  }
  String[] getLikeColor(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      String[] colStr = ds.getLikeColor();
      if (colStr.length < 1) {
        return _likeColor;
      } else {
        return colStr;
      }
    } else {
      log("Warning in getLikeColor! Dataset <"+dataset+"> does not exist.");
      return _likeColor;
    }
  }

} // end class DelvImpl

// DelvView is used to support having multiple processing sketches in both Processing and processing.js

public class DelvBasicView implements DelvView {
  // mouseScroll defined to keep Processing happy.
  // For Processing.js override by assigning processing instance to _p
  //  since _p == this in Processing
  // then always access mouseScroll through _p.mouseScroll
  int mouseScroll = 0;
  public DelvBasicView _p;
  int _w = 100;
  int _h = 100; // The width and height of the view
  int[] _origin;
  int _backgroundColor;
  boolean _drawBox;
  String[][] _coords;
  String[][] _hoverCoords;
  HashMap<String, String[][]> _selectCoords;
  String[][] _filterCoords;
  String[][] _likeCoords;
  String _label;
  int[] _hoveredIdx;
  HashMap<String, int[]> _selectedIdx;
  int[] _filteredIdx;
  int[] _navIdx;
  Delv _delv;
  String _name;
  String _datasetName;
  String _colorAttr;

       // * * * Constructors * * * //
  public DelvBasicView(String name, int [] origin, int w, int h){
    _p = this;
    _name = name;
    _datasetName = "";
    _label = "";
    _origin = origin;
    _w = w;
    _h = h;
    _backgroundColor = color_(255);
    _drawBox = true;
    // TODO how and when to get dimension of unique coordinates?
    _coords = new String[0][];
    _hoverCoords = new String[0][];
    _selectCoords = new HashMap<String, String[][]>();
    _selectCoords.put("PRIMARY", new String[0][]);
    _selectCoords.put("SECONDARY", new String[0][]);
    _selectCoords.put("TERTIARY", new String[0][]);
    _hoveredIdx = new int[0];
    _selectedIdx = new HashMap<String, int[]>();
    _selectedIdx.put("PRIMARY", new int[0]);
    _selectedIdx.put("SECONDARY", new int[0]);
    _selectedIdx.put("TERTIARY", new int[0]);
    _filteredIdx = new int[0];
    _navIdx = new int[0];
    _colorAttr = "";
  }
  public DelvBasicView() { this("BasicView", new int[2], 100, 100); }
  public DelvBasicView(String name) { this(name, new int[2], 100, 100); }

  public void bindDelv(Delv dlv) {
    _delv = dlv;
    // TODO explicitly call connectSignals here?
    connectSignals();
  }

  public String name() { return _name; }
  public DelvBasicView name(String name) {
    _name = name;
    return this;
  }

  public String dataSet() {
    return _datasetName;
  }
  public DelvBasicView dataSet(String name) {
    _datasetName = name;
    return this;
  }

  String colorAttr() {
    return _colorAttr;
  }
  DelvBasicView colorAttr(String attr) {
    _colorAttr = attr;
    return this;
  }

  void connectSignals() {
    if (_delv == null) {
      return;
    }
    _delv.connectToSignal("sortChanged", _name, "onSortChanged");

    _delv.connectToSignal("hoverChanged", _name, "onHoverChanged");
    _delv.connectToSignal("selectChanged", _name, "onSelectChanged");
    _delv.connectToSignal("filterChanged", _name, "onFilterChanged");
    _delv.connectToSignal("navChanged", _name, "onNavChanged");

    // TODO instead of connecting to colorChanged, hoverColorChanged, filterColorChanged etc,
    // just get the item color for each item from Delv at render time

    // TODO hook up encodingChanged?

  }

  // TODO distinguish between Item selection, Category selection, and Attribute selection
  // TODO allow multiple item selection, primary, secondary, tertiary selection
  void selectItem(String[] coord) {
    // see if need to add any other logic here
    String[][] selections = new String[1][];
    selections[0] = coord;
    _delv.selectItems(_name, _datasetName, selections, "PRIMARY");
  }
  public void colorChanged(String selection, color c) {}

  // TODO undo this hack for onDataUpdated
  void onDataUpdated(String invoker, String dataset, String attribute) {}
  void onDataUpdated(String invoker, String dataset, String[] attributes) {}

  void onHoverChanged(String invoker, String dataset, String coordination) {
    // only get the coordinates, not the relationship or val / ranges
    if ( !(invoker.equals(_name)) &&
         dataset.equals(_datasetName)) {
      setHoveredCoords( _delv.getHoverCoords(_datasetName) );
    }
  }
  void onSelectChanged(String invoker, String dataset, String coordination, String selectType) {
    // for all coordination types, just get the coords
    // TODO support secondary / tertiary selections
    if ( !(invoker.equals(_name)) &&
        dataset.equals(_datasetName) &&
        selectType.equals("PRIMARY") ) {
      setSelectedCoords(_delv.getSelectCoords(_datasetName, selectType));
      // TODO any redraw notification here?
    }
  }
  void onFilterChanged(String invoker, String dataset, String coordination) {
    // only get the coordinates, not the relationship or val / ranges
    if ( !(invoker.equals(_name)) &&
         dataset.equals(_datasetName) ) {
      setFilteredCoords( _delv.getFilterCoords(_datasetName) );
    }
  }
  void onNavChanged(String invoker, String dataset, String coordination) {
    // only get the coordinates, not the relationship or val / ranges
    if ( !(invoker.equals(_name)) &&
         dataset.equals(_datasetName) ) {
      setNavCoords( _delv.getNavCoords(_datasetName) );
    }
  }

  void updateSelections() {
    // TODO handle selection updates
    // String[] selections;
    // selections = _dataIF.getSelectedIds(_datasetName);
    setHoveredCoords( _delv.getHoverCoords(_datasetName) );
    setFilteredCoords( _delv.getFilterCoords(_datasetName) );
    setNavCoords( _delv.getNavCoords(_datasetName) );
    // TODO handle color / color map updates
  }

  public void onDataChanged(String source) { updateSelections(); }

  public String label() {
    return _label;
  }
  public void label(String aLabel) {
    _label = aLabel;
    labelUpdated();
    //redraw();
  }

  // * * * Set the origin * * * //
  public void setOrigin(int [] origin){ _origin[0] = origin[0]; _origin[1] = origin[1]; }
  public void setOrigin(int x, int y){ _origin[0] = x; _origin[1] = y; }

  // * * * Get the width & height * * * //
  public int getWidth() { return _w; }
  public int getHeight() { return _h; }

  // * * * Get origin and origin plus width/height * * * //
  public int [] getOrigin() { return _origin; }
  public int getOriginPlusWidth(){  return _origin[0] + _w; }
  public int getOriginPlusHeight(){ return _origin[1] + _h; }

  // * * * Get/Set the background color * * * //
  public int getBackgroundColor() { return _backgroundColor; }
  public DelvBasicView setBackgroundColor(int c) {
    _backgroundColor = c;
    return this;
  }

  public void drawBox(boolean doDraw) {
    _drawBox = doDraw;
  }

  // * * * Get/Set the ids * * * //
  public String[][] getCoords() { return _coords; }
  public DelvBasicView setCoords(String[][] coords) {
    _coords = coords;
    coordsUpdated();
    //redraw();
    return this;
  }
  public String[] getCoord(int idx) {
    return _coords[idx];
  }

  public void setHoveredCoords(String[][] coords) {
    // TODO actually pick a better data structure and algorithm
    _hoveredIdx = new int[coords.length];
    _hoverCoords = coords;
    for (int cc = 0; cc < coords.length; cc++) {
      for ( int idx = 0; idx < _coords.length; idx++ ) {
        if (coordsEqual(_coords[idx], coords[cc])) {
          _hoveredIdx[cc] = idx;
          break;
        }
      }
    }
    hoveredCoordsUpdated();
    //redraw();
  }
  public void setSelectedCoords(String[][] coords) {
    // TODO actually pick a better data structure and algorithm
    int[] indices = new int[coords.length];
    // TODO handle secondary, tertiary selections
    _selectCoords.put("PRIMARY", coords);
    for ( int ii = 0; ii < coords.length; ii++) {
      String[] coord = coords[ii];
      for ( int idx = 0; idx < _coords.length; idx++ ) {
        if (coordsEqual(_coords[idx], coord)) {
          indices[ii] = idx;
          break;
        }
      }
    }
    _selectedIdx.put("PRIMARY", indices);
    selectedCoordsUpdated();
    draw();
  }
  public void setFilteredCoords(String[][] coords) {
    _filteredIdx = new int[coords.length];
    _filterCoords = coords;
    for ( int ii = 0; ii < coords.length; ii++) {
      String[] coord = coords[ii];
      for ( int idx = 0; idx < _coords.length; idx++ ) {
        if (coordsEqual(_coords[idx], coord)) {
          _filteredIdx[ii] = idx;
          break;
        }
      }
    }
    filteredCoordsUpdated();
    //redraw();
  }
  public void setNavCoords(String[][] coords) {
    notImplemented("DelvBasicView", "setNavCoords", "<coords>");
    // _navIdx = new int[coords.length];
    // _navCoords = coords;
    // for ( int ii = 0; ii < coords.length; ii++) {
    //   String[] coord = coords[ii];
    //   for ( int idx = 0; idx < _coords.length; idx++ ) {
    //     if (coordsEqual(_coords[idx], coord)) {
    //       _navIdx[ii] = idx;
    //       break;
    //     }
    //   }
    // }
    // navCoordsUpdated();
    // //redraw();
  }

  public void hoverOn(int idx) {
    hoveredIdx(true, idx, true);
  }
  public void hoverOn(int idx, boolean doDraw) {
    hoveredIdx(true, idx, doDraw);
  }
  public void hoverOff() {
    hoveredIdx(false,-1,true);
  }
  public void hoverOff(boolean doDraw) {
    hoveredIdx(false, -1, doDraw);
  }

  public void renderBox() {
    // Render the box around the view
    noStroke();
    fill( _backgroundColor );
    rect(0, 0, _w, _h);
    noFill();
  }

  // * * * draw translates to the origin * * * //
  public void draw() {
    // Translate & render view
    pushMatrix();
    translate( _origin[0], _origin[1] );
    if (_drawBox) {
      renderBox();
    }
    render();
    popMatrix();
  }

  // * * * Check if the mouse is within this view - or its children * * * //
  public boolean mouseCapture(int mouseX, int mouseY) {
    // Check if mouse is within bounding box
    if(mouseX >= _origin[0] && mouseX <= _origin[0]+_w && 
       mouseY >= _origin[1] && mouseY <= _origin[1]+_h)
      return true;
    else
      return false;
  }

  public void resize(int w, int h) {
    resize(w, h, true);
  }
  public void resize(int w, int h, boolean doDraw) {
    if ((w != _w) || (h != _h)) {
      _w = w;
      _h = h;
      if (_p != this) {
        // in processing.js, so call size
        size(_w, _h);
      } // if in Processing do not call size!
      if (doDraw) {
        draw();
      }
    }
  }

  public void mouseMoved() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseMovedInView(mouseX - _origin[0], mouseY - _origin[1]);
    else
      mouseOutOfView();
    draw();
  }
  public void mouseOut() {
    mouseOutOfView();
  }
  public void mouseClicked() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseClickedInView(mouseX - _origin[0], mouseY - _origin[1]);
    else
      mouseOutOfView();
    draw();
 }
  public void mousePressed() {
    // TODO better to press mouseButton in directly?
    if ( mouseCapture(mouseX, mouseY) )
      mousePressedInView(mouseX - _origin[0], mouseY - _origin[1], mouseButton == RIGHT);
    else
      mouseOutOfView();
    draw();
  }
  public void mouseReleased() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseReleasedInView(mouseX - _origin[0], mouseY - _origin[1]);
    else
      mouseOutOfView();
    draw();
  }
  public void mouseDragged() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseDraggedInView(mouseX - _origin[0], mouseY - _origin[1]);
    else
      mouseOutOfView();
    draw();
  }
  public void mouseScrolled() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseScrolledInView(_p.mouseScroll);
    else
      mouseOutOfView();
    draw();
  }
  public void movieEvent(DelvMovie m) {}
  // * * * Render the view (default just sets the background of the view) * * * //
  // override by each subclass
  public void render(){}
  public void setup(){}
  public void mouseMovedInView(int mx, int my) {}
  public void mouseOutOfView() {}
  public void mouseClickedInView(int mx, int my) {}
  public void mousePressedInView(int mx, int my, boolean rightPressed) {}
  public void mouseReleasedInView(int mx, int my) {}
  public void mouseDraggedInView(int mx, int my) {}
  public void mouseScrolledInView(int wr) {}

  // override these if you need to do a one-time calculation or update when
  // one of these events happens
  public void labelUpdated() {}
  public void coordsUpdated() {}
  public void hoveredCoordsUpdated() {}
  public void selectedCoordsUpdated() {}
  public void filteredCoordsUpdated() {}
  public void likedCoordsUpdated() {}

  // To work in javascript as well, cannot have method overloading!! Pick different names!
  public void hoverItem(String[] coord) {
    hoverItem(coord, true);
  }
  public void hoverItem(String[] coord, boolean doDraw) {
    if (_hoverCoords.length != 1 ||
        !(coordsEqual(coord,_hoverCoords[0]))) {
      String[][] coords = new String[1][];
      coords[0] = coord;
      _hoverCoords = coords;
      _delv.hoverItem(_name, _datasetName, coord);
      if (doDraw) {
        //redraw();
      }
    }
  }
  public void hoverItem(String id) {
    hoverItem(id, true);
  }
  public void hoverItem(String id, boolean doDraw) {
    String[][] coords = new String[1][];
    coords[0] = idToCoord(id);
    if (_hoverCoords.length != 1 ||
        !(coordsEqual(coords[0],_hoverCoords[0]))) {
      _hoverCoords = coords;
      _delv.hoverItem(_name, _datasetName, coords[0]);
      if (doDraw) {
        //redraw();
      }
    }
  }
  public void hoveredIdx(boolean isHovered, int idx) {
    hoveredIdx(isHovered, idx, true);
  }
  public void hoveredIdx(boolean isHovered, int idx, boolean doDraw) {
    if (isHovered) {
      hoverItem(getCoord(idx), doDraw);
    } else {
      hoverItem(new String[0], doDraw);
    }
  }
} // end class DelvBasicView

public class DelvCompositeView extends DelvBasicView {
  ArrayList<DelvBasicView> _views;

       // * * * Constructors * * * //
  public DelvCompositeView(String name, int [] origin, int w, int h){
    super(name, origin, w, h);
    _views = new ArrayList<DelvBasicView>();
  }
  public DelvCompositeView() { this("CompositeView", new int[2], 100, 100); }
  public DelvCompositeView(String name) { this(name, new int[2], 100, 100); }

  public DelvCompositeView addView(DelvBasicView view) {
    // Set background to transparent here, view can override later if desired
    // TODO document this elsewhere
    color c = view.getBackgroundColor();
    c = color_(red_(c), green_(c), blue_(c), 0);
    view.setBackgroundColor(c);
    _views.add(view);
    return this;
  }

  public void bindDelv(Delv dlv) {
    for (DelvBasicView view: _views) {
      dlv.addView(view);
    }
    super.bindDelv(dlv);
  }

  public DelvBasicView dataSet(String name) {
    _datasetName = name;
    for (DelvBasicView view: _views) {
      view.dataSet(name);
    }
    return this;
  }

  public DelvBasicView colorAttr(String attr) {
    _colorAttr = attr;
    for (DelvBasicView view: _views) {
      view.colorAttr(attr);
    }
    return this;
  }

  public void label(String aLabel) {
    _label = aLabel;
    for (DelvBasicView view: _views) {
      view.label(aLabel);
    }
    labelUpdated();
  }

  public void onDataChanged(String source) {
    for (DelvBasicView view: _views) {
      view.onDataChanged(source);
    }
    super.onDataChanged(source);
  }

  // * * * Set the origin * * * //
  public void setOrigin(int [] origin){
    super.setOrigin(origin);
    for (DelvBasicView view: _views) {
      view.setOrigin(origin);
    }
  }
  public void setOrigin(int x, int y){
    super.setOrigin(x, y);
    for (DelvBasicView view: _views) {
      view.setOrigin(x, y);
    }
  }

  public void basicDraw(){
    super.draw();
  }

  public void draw(){
    super.draw();
    for (DelvBasicView view: _views) {
      view.draw();
    }
  }

  public void setup(){
    super.setup();
    for (DelvBasicView view: _views) {
      view.setup();
    }
  }

  public void resize(int w, int h) {
    super.resize(w, h);
    for (DelvBasicView view: _views) {
      view.resize(w, h);
    }
    //redraw();
  }
  public void resize(int w, int h, boolean doDraw) {
    super.resize(w, h, doDraw);
    for (DelvBasicView view: _views) {
      view.resize(w, h, doDraw);
    }
  }
  public void mouseMoved() {
    for (DelvBasicView view : _views) {
      view.mouseMoved();
    }
    super.mouseMoved();
  }
  public void mouseClicked() {
    for (DelvBasicView view : _views) {
      view.mouseClicked();
    }
    super.mouseClicked();
  }
  public void mousePressed() {
    // TODO better to press mouseButton in directly?
    for (DelvBasicView view : _views) {
      view.mousePressed();
    }
    super.mousePressed();
  }
  public void mouseReleased() {
    for (DelvBasicView view : _views) {
      view.mouseReleased();
    }
    super.mouseReleased();
  }
  public void mouseDragged() {
    for (DelvBasicView view : _views) {
      view.mouseDragged();
    }
    super.mouseDragged();
  }
  public void mouseScrolled() {
    for (DelvBasicView view : _views) {
      view.mouseScrolled();
    }
    super.mouseScrolled();
  }
  public void mouseOutOfView() {
    for (DelvBasicView view : _views) {
      view.mouseOutOfView();
    }
  }

  public void movieEvent(DelvMovie m) {
    for (DelvBasicView view : _views) {
      view.movieEvent(m);
    }
    super.movieEvent(m);
  }

} // end class DelvCompositeView

// DelvCategoryView
// A view that can render the categories for
// one dimension of data.  It converts category selections into
// data filtering messages.  For
// other behaviors of a category view, implement a different base view.
// Since it inherits from DelvBasicView, it also
// has access to the colorAttr

public class DelvCategoryView extends DelvBasicView {
  String _catAttr;
  String[] _cat;
  String[] _filterCats;
  color[] _catColors;
  color[] _filterCatColors;
  String _colorCat;
  HashMap<String, String[]> _selectCats;
  String _hoverCat;
  String _highlightCat;
  boolean _doSort;

  public DelvCategoryView() {
    this("DelvCategory");
  }

  public DelvCategoryView(String name) {
    super(name);
    _cat = new String[0];
    _filterCats = new String[0];
    _filterCatColors = new color[0];
    _colorCat = "";
    _selectCats = new HashMap<String, String[]>();
    _selectCats.put("PRIMARY", new String[0]);
    _selectCats.put("SECONDARY", new String[0]);
    _selectCats.put("TERTIARY", new String[0]);
    _hoverCat = "";
    _doSort = true;
  }

  public DelvCategoryView doSort(boolean sort) {
    _doSort = sort;
    return this;
  }

  public String catAttr() {
    return _catAttr;
  }
  public DelvCategoryView catAttr(String attr) {
    _catAttr = attr;
    return this;
  }

  public void setCats(String[] cats) {
    _cat = cats;
    catUpdated();
  }
  public void setFilterCats(String[] cats) {
    _filterCats = cats;
    filterCatsUpdated();
  }

  public void onDataChanged(String source) {
    if (_delv == null) {
      return;
    }

    if (!source.equals(_name)) {
      String[] cats;
      cats = _delv.getAllCats(_datasetName, _catAttr);
      if (_doSort) {
        cats = sort(cats);
      }
      setCats(cats);
      updateFilters();
    }
    super.onDataChanged(source);
  }

  public void updateFilters() {
    String[] selections;
    selections = _delv.getFilterCats(_datasetName, _catAttr);
    if (_doSort) {
      selections = sort(selections);
    }
    setFilterCats(selections);
    updateColors();
  }

  public void updateColors() {
    // assumes that all categories and visible categories have been set already
    if (!_colorAttr.equals("")) {
      _catColors = new color[_cat.length];
      String[] colorStr = new String[0];
      for (int i = 0; i < _cat.length; i++) {
        colorStr = _delv.getCatColor(_datasetName, _colorAttr, _cat[i]);
        _catColors[i] = toP5Color(colorStr);
      }
      catColorsUpdated();

      _filterCatColors = new color[_filterCats.length];
      for (int i = 0; i < _filterCats.length; i++) {
        colorStr = _delv.getCatColor(_datasetName, _colorAttr, _filterCats[i]);
        _filterCatColors[i] = toP5Color(colorStr);
      }
      filterCatColorsUpdated();
    }
  }

  public void connectSignals() {
    if (_delv == null) {
      return;
    }

    _delv.connectToSignal("filterChanged", _name, "onFilterChanged");
    _delv.connectToSignal("hoverChanged", _name, "onHoverChanged");
    _delv.connectToSignal("selectChanged", _name, "onSelectChanged");
    _delv.connectToSignal("colorChanged", _name, "onColorChanged");
  }

 public void onFilterChanged(String invoker, String dataset, String coordination) {
    if (invoker.equals(_name)) {
      _delv.log(_name + ".onFilterChanged(" + dataset + ", " + coordination + ") triggered by self");
    } else {
      _delv.log(_name + ".onFilterChanged(" + dataset + ", " + coordination + ") triggered by " + invoker);
      if (dataset.equals(_datasetName)) {
        updateFilters();
      }
    }
  }
  public void onHoverChanged(String invoker, String dataset, String coordination) {
    super.onHoverChanged(invoker, dataset, coordination);
    if (invoker.equals(_name)) {
      _delv.log(_name+".onHoverChanged(" + dataset + ", " + coordination + ") triggered by self");
    } else {
      _delv.log(_name+".onHoverChanged(" + dataset + ", " + coordination + ") triggered by " + invoker);
      if (dataset.equals(_datasetName)) {
        _hoverCat = _delv.getHoverCat(_datasetName, _catAttr);
        hoveredCatUpdated();
      }
    }
  }

  public void onSelectChanged(String invoker, String dataset, String coordination, String selectType) {
    if (invoker.equals(_name)) {
      _delv.log(_name + ".onSelectChanged(" + dataset + ", " + coordination + ", " + selectType + ") triggered by self");
    } else {
      _delv.log(_name + ".onSelectChanged(" + dataset + ", " + coordination + ", " + selectType + ") triggered by " + invoker);
      if (dataset.equals(_datasetName)) {
        // TODO any validation of selectType?
        _selectCats.put(selectType, _delv.getSelectCats(_datasetName, _catAttr, selectType));
        selectedCatsUpdated();
      }
    }
  }

  public void onColorChanged(String invoker, String dataset, String attribute) {
    if (!invoker.equals(_name) &&
        dataset.equals(_datasetName) &&
        attribute.equals(_catAttr)) {
      updateColors();
    }
  }

  // helper functions for views that only care about primary selection
  public void selectCat(String cat) {
    String[] cats = new String[1];
    cats[0] = cat;
    selectCats(cats, "PRIMARY", true);
  }
  public void selectCat(String cat, boolean doDraw) {
    // TODO decide whether selectionChanged should only be issued for different
    // selections vs repeats of the same.
    // if (!(cat.equals(_selectCat))) {
    String[] cats = new String[1];
    cats[0] = cat;
    selectCats(cats, "PRIMARY", doDraw);
  }
  public void selectCat(String cat, String selectType) {
    String[] cats = new String[1];
    cats[0] = cat;
    selectCats(cats, selectType, true);
  }
  public void selectCat(String cat, String selectType, boolean doDraw) {
    // TODO decide whether selectionChanged should only be issued for different
    // selections vs repeats of the same.
    // if (!(cat.equals(_selectCat))) {
    String[] cats = new String[1];
    cats[0] = cat;
    selectCats(cats, selectType, doDraw);
  }
  // more general selection helpers
  public void selectCats(String[] cats, String selectType) {
    selectCats(cats, selectType, true);
  }
  public void selectCats(String[] cats, String selectType, boolean doDraw) {
    _selectCats.put(selectType, cats);
    String[] attrs = new String[1];
    attrs[0] = _catAttr;
    _delv.selectCats(_name, _datasetName, attrs, cats, selectType);
    if (doDraw) {
      draw();
    }
  }

  public void hoverCat(String cat) {
    hoverCat(cat, true);
  }
  public void hoverCat(String cat, boolean doDraw) {
    if (!(cat.equals(_hoverCat))) {
      _hoverCat = cat;
      _delv.hoverCat(_name, _datasetName, _catAttr, cat);
      if (doDraw) {
        draw();
      }
    }
  }

  public void filterCat(String cat) {
    String[] cats = new String[1];
    cats[0] = cat;
    filterCats(cats, true);
  }
  public void filterCat(String cat, boolean doDraw) {
    String[] cats = new String[1];
    cats[0] = cat;
    filterCats(cats, doDraw);
  }
  public void filterCats(String[] cats) {
    filterCats(cats, true);
  }
  public void filterCats(String[] cats, boolean doDraw) {
    _filterCats = cats;
    _delv.filterCats(_name, _datasetName, _catAttr, cats);
    if (doDraw) {
      draw();
    }
  }
  public void toggleCatFilter(String cat) {
    toggleCatFilter(cat, true);
  }
  public void toggleCatFilter(String cat, boolean doDraw) {
    int foundIdx = -1;
    for (int idx = 0; idx < _filterCats.length; idx++) {
      if (_filterCats[idx].equals(cat)) {
        foundIdx = idx;
        break;
      }
    }
    if (foundIdx >= 0) {
      String[] tmpCats = new String[_filterCats.length-1];
      System.arraycopy(_filterCats, 0, tmpCats, 0, foundIdx);
      System.arraycopy(_filterCats, foundIdx+1, tmpCats, foundIdx, _filterCats.length - (foundIdx+1));
      _filterCats = tmpCats;
    } else {
      String[] tmpCats = new String[_filterCats.length+1];
      System.arraycopy(_filterCats, 0, tmpCats, 0, _filterCats.length);
      tmpCats[_filterCats.length] = cat;
      _filterCats = tmpCats;
    }

    _delv.toggleCatFilter(_name, _datasetName, _catAttr, cat);
    if (doDraw) {
      draw();
    }
  }
  public void coloredCat(String cat, color c) {
    coloredCat(cat, c, true);
  }
  public void coloredCat(String cat, color c, boolean doDraw) {
    _colorCat = cat;
    // TODO, how do we know when to updateCategoryColor
    // vs when to update item color or range color?
    // ANSWER (keep track of this for write-up): item colors will never be changed directly, so only ever updating categories or ranges.  So create two interfaces
    // colorCat for updating categoryColor, and colorRange for updating a continuous range w/ color.
    _delv.colorCat(_name, _datasetName, _colorAttr, _colorCat, toRGBAString(c));
    if (doDraw) {
      draw();
    }
  }

  // override these if you need to do a one-time calculation when these events happen
  public void catUpdated() {}
  public void filterCatsUpdated() {}
  public void hoveredCatUpdated() {}
  public void selectedCatsUpdated() {}
  public void catColorsUpdated() {}
  public void filterCatColorsUpdated() {}

} // end DelvCategoryView

// Delv1DView
// A view that can render one dimension of data
// Since it inherits from DelvCategoryView, it also
// has access to the colorAttr and the catAttr

class Delv1DView extends DelvCategoryView {
  String _dim1Attr;
  String[] _dim1;

  Delv1DView() {
    this("Delv1D");
  }

  Delv1DView(String name) {
    super(name);
    _dim1 = new String[0];
  }

  String dim1Attr() {
    return _dim1Attr;
  }
  Delv1DView dim1Attr(String attr) {
    _dim1Attr = attr;
    return this;
  }

  void setDim1(String[] dim) {
    _dim1 = dim;
    dim1Updated();
    //redraw();
  }

  void onDataChanged(String source) {
    if (_delv == null) {
      return;
    }

    if (!source.equals(_name)) {
      String[] data;
      // TODO need to get Visible Items or Filtered Items or something else
      data = _delv.getAllItems(_datasetName, _dim1Attr);
      setDim1(data);
      String[][] coords;
      coords = _delv.getAllCoords(_datasetName, _dim1Attr);
      setCoords(coords);
    }
    super.onDataChanged(source);
  }

  void dim1Updated() {}

} // end Delv1DView

// Delv2DView
// A view that can render two dimensions of data
// Since it inherits from DelvBasicView, it also
// has access to the colorAttr

class Delv2DView extends Delv1DView {
  String _dim2Attr;
  String[] _dim2;

  Delv2DView() {
    this("Delv2D");
  }
  Delv2DView(String name) {
    super(name);
    _dim2 = new String[0];
  }

  String dim2Attr() {
    return _dim2Attr;
  }

  Delv2DView dim2Attr(String attr) {
    _dim2Attr = attr;
    return this;
  }

  void setDim2(String[] dim) {
    _dim2 = dim;
    dim2Updated();
    //redraw();
  }

  void onDataChanged(String source) {
    if (_delv == null) {
      return;
    }

    if (!source.equals(_name)) {
      String[] data;
      // TODO need to get Visible Items or Filtered Items or something else
      data = _delv.getAllItems(_datasetName, _dim2Attr);
      setDim2(data);
    }
    super.onDataChanged(source);
  }

  void dim2Updated() {}

} // end Delv2DView

// Some classes to support implementation of DelvBasicDataSet

  class DelvPair<First, Second> {
// from http://stackoverflow.com/questions/5303539/didnt-java-once-have-a-pair-class
    private First first;
    private Second second;

    public DelvPair(First first, Second second) {
        this.first = first;
        this.second = second;
    }

    public void setFirst(First first) {
        this.first = first;
    }

    public void setSecond(Second second) {
        this.second = second;
    }

    public First getFirst() {
        return first;
    }

    public Second getSecond() {
        return second;
    }

    public void set(First first, Second second) {
        setFirst(first);
        setSecond(second);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        DelvPair pair = (DelvPair) o;

        if (first != null ? !first.equals(pair.first) : pair.first != null) return false;
        if (second != null ? !second.equals(pair.second) : pair.second != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = first != null ? first.hashCode() : 0;
        result = 31 * result + (second != null ? second.hashCode() : 0);
        return result;
    }
  } // end DelvPair

class DelvItemId {
  // want these all to be public
  String[] name;
  // TODO more space-efficient to store these all in a bitmask
  boolean hovered;
  boolean selectedPrimary;
  boolean selectedSecondary;
  boolean selectedTertiary;
  boolean filtered;
  boolean navigated;

  DelvItemId(String[] coord) {
    name = coord;
    hovered = false;
    selectedPrimary = false;
    selectedSecondary = false;
    selectedTertiary = false;
    filtered = true;
    navigated = true;
  }

  void toggleHovered() {
    hovered = !hovered;
  }

  void togglePrimarySelection() {
    selectedPrimary = !selectedPrimary;
  }
  void toggleSecondarySelection() {
    selectedSecondary = !selectedSecondary;
  }
  void toggleTertiarySelection() {
    selectedTertiary = !selectedTertiary;
  }

  void toggleFiltered() {
    filtered = !filtered;
  }
  void toggleNavigated() {
    navigated = !navigated;
  }


} // end class DelvItemId

interface DelvRange {
  boolean isInRange(String val);
}

class DelvCategoricalRange implements DelvRange {
  ArrayList<String> _categories;
  HashMap<String, Boolean> _filtered;

  DelvCategoricalRange() {
    // keeping this separate because _categories needs to be in the correct sorted order
    // (or does it, not sure this is true).
    // ( TODO maybe a sorted hash map would be better?)
    _categories = new ArrayList<String>();
    _filtered = new HashMap<String, Boolean>();
  }

  void addCategory(String cat) {
    boolean found = false;
    for (String c : _categories) {
      if (c.equals(cat)) {
        found = true;
        break;
      }
    }
    if (!found) {
      _categories.add(cat);
    }
    _filtered.put(cat, true);
  }

  void filterAll() {
    for (String c: _filtered.keySet()) {
      _filtered.put(c, true);
    }
  }

  void filterNone() {
    for (String c: _filtered.keySet()) {
      _filtered.put(c, false);
    }
  }

  String[] getCategories() {
    return _categories.toArray(new String[_categories.size()]);
  }

  String[] getFilteredCategories() {
    ArrayList<String> filt = new ArrayList<String>();
    for (String cat : _categories) {
      if (_filtered.get(cat)) {
        filt.add(cat);
      }
    }
    return filt.toArray(new String[filt.size()]);
  }

  void toggleFiltered(String cat) {
    _filtered.put(cat, !_filtered.get(cat));
  }

  boolean isInRange(String val) {
    return isCategoryFiltered(val);
  }

  boolean isCategoryFiltered(String cat) {
    Boolean isFiltered = _filtered.get(cat);
    if (isFiltered == null) {
      isFiltered = false;
    }
    return isFiltered;
  }

} // end class DelvCategoricalRange

class DelvContinuousRange implements DelvRange {
  float _min;
  float _max;
  boolean _hasMin;
  boolean _hasMax;

  DelvContinuousRange() {
    _hasMin = false;
    _hasMax = false;
  }

  boolean hasMin() {
    return _hasMin;
  }
  boolean hasMax() {
    return _hasMax;
  }

  float getMin() {
    return _min;
  }
  float getMax() {
    return _max;
  }

  void setMin(float val) {
    _min = val;
    _hasMin = true;
  }
  void setMax(float val) {
    _max = val;
    _hasMax = true;
  }

  void updateMin(float val) {
    if (!_hasMin || val < _min) {
      _min = val;
      _hasMin = true;
    }
  }
  void updateMax(float val) {
    if (!_hasMax || val < _max) {
      _max = val;
      _hasMax = true;
    }
  }

  void update(float val) {
    updateMin(val);
    updateMax(val);
  }

  boolean isInRange(String val) {
    return isInRange(parseFloat(val));
  }

  boolean isInRange(float val) {
    if (!_hasMin) {
      if (!_hasMax) {
        return true;
      } else {
        return (val <= _max);
      }
    } else if (!_hasMax) {
      return (_min <= val);
    } else {
      return (_min <= val && val <= _max);
    }
  }

} // end class DelvContinuousRange

// implement AttributeType enum as a straight class since processing.js doesn't like enums.  Need the public static final class incantation to allow for static final members in an inner class
public static final class AttributeType {
  public static final String[] _types = new String[] { "UNSTRUCTURED", "CATEGORICAL", "CATEGORICAL_LIST", "CONTINUOUS", "DATETIME", "FLOAT_ARRAY" };
    public static final AttributeType UNSTRUCTURED = new AttributeType(_types[0]);
    public static final AttributeType CATEGORICAL = new AttributeType(_types[1]);
    public static final AttributeType CATEGORICAL_LIST = new AttributeType(_types[2]);
    public static final AttributeType CONTINUOUS = new AttributeType(_types[3]);
    public static final AttributeType DATETIME = new AttributeType(_types[4]);
    public static final AttributeType FLOAT_ARRAY = new AttributeType(_types[5]);

    String _val;

    AttributeType() {
        this(UNSTRUCTURED);
    }

    AttributeType(AttributeType val) {
        _val = val._val;
    }

    AttributeType(String val) {
        boolean found = false;
        for (int i = 0; i < _types.length; i++) {
            if (val.equals(_types[i])) {
                found = true;
                break;
            }
        }
        if (!found) {
            throw new IllegalArgumentException(val+" is not a valid AttributeType");
        }
        _val = val;
    }

    boolean equals(AttributeType other) {
        if (_val.equals(other._val)) {
            return true;
        } else {
            return false;
        }
    }
}

public class DelvBasicDataSet implements DelvDataSet {
  String _name;
  Delv _delv;
  ArrayList<DelvItemId> _itemIds;
  HashMap<String, Integer> _itemIdHash;
  HashMap<String, DelvBasicAttribute> _attributes;
  int _lod;
  // TODO what is correct structure for encoding?  Just use a css style string?
  String[] _defaultEncoding;
  String[] _defaultColor;
  HashMap<String, String[]> _selectColors;
  String[] _hoverColor;
  String[] _filterColor;
  String[] _likeColor;
  boolean _defaultEncodingSet;
  boolean _defaultColorSet;
  HashMap< String, Boolean > _selectColorsSet;
  boolean _hoverColorSet;
  boolean _filterColorSet;
  boolean _likeColorSet;
  String[] _hoverCoord;
  DelvPair< String, DelvRange > _hoverRange;
  HashMap< String, ArrayList< HashMap< String, DelvRange > > > _selectRanges;
  HashMap< String, ArrayList< DelvRange > > _filterRanges;
  // TODO what data structure to manage navigation?
  // TODO what data structure to manage relationships / structure brushes?

  DelvBasicDataSet(String name) {
    _name = name;
    _itemIds = new ArrayList<DelvItemId>();
    _itemIdHash = new HashMap<String, Integer>();
    _attributes = new HashMap<String, DelvBasicAttribute>();
    _lod = -1;
    // TODO provide methods to set/get the default?
    _defaultEncoding = new String[0];
    _defaultEncodingSet = false;
    _defaultColor = toRGBAString(color_(220));
    _hoverColor = toRGBAString( color_(223, 63, 66) );
    _selectColors = new HashMap< String, String[] >();
    _selectColors.put( "PRIMARY", toRGBAString( color_(109, 218, 114) ) );
    _selectColors.put( "SECONDARY", toRGBAString( color_(234, 153, 57) ) );
    _selectColors.put( "TERTIARY", toRGBAString( color_(234, 231, 57) ) );
    _filterColor = toRGBAString( color_(140, 200, 235) );
    _likeColor = toRGBAString( color_(180, 71, 241) );
    _defaultColorSet = false;
    _selectColorsSet = new HashMap< String, Boolean >();
    _selectColorsSet.put( "PRIMARY", false );
    _selectColorsSet.put( "SECONDARY", false );
    _selectColorsSet.put( "TERTIARY", false );
    _hoverColorSet = false;
    _filterColorSet = false;
    _likeColorSet = false;
    _hoverCoord = new String[0];
    _hoverRange = new DelvPair< String, DelvRange >("", new DelvCategoricalRange());
    _selectRanges = new HashMap< String, ArrayList< HashMap< String, DelvRange > > >();
    _selectRanges.put("PRIMARY", new ArrayList< HashMap< String, DelvRange > >());
    _selectRanges.put("SECONDARY", new ArrayList< HashMap< String, DelvRange > >());
    _selectRanges.put("TERTIARY", new ArrayList< HashMap< String, DelvRange > >());
    _filterRanges = new HashMap<String, ArrayList< DelvRange > >();
 }


  String getName() {
    return _name;
  }
  void setName(String name) {
    _name = name;
  }

  void bindDelv(Delv dlv) {
    _delv = dlv;
  }

  // operations
  // sort
  // possible values of sortType: ascending, descending
  void sortByVal(String attribute, String sortType) {
    notImplemented("DelvBasicDataSet", "sortByVal", attribute +", " + sortType);
  }
  // possible values of similarity sortType: similarity, dissimilarity
  void sortBySimilarity(String identifier, String sortType) {
    notImplemented("DelvBasicDataSet", "sortBySimilarity", identifier +", " + sortType);
  }
  void sortBySimilarity(String[] coordinate, String sortType) {
    notImplemented("DelvBasicDataSet", "sortBySimilarity", coordinate +", " + sortType);
  }
  void clearSort() {
    notImplemented("DelvBasicDataSet", "clearSort", "");
  }
  String[][] getSortCriteria() {
    notImplemented("DelvBasicDataSet", "getSortCriteria", "");
    return new String[0][];
  }

  // TODO transforms

  // TODO aggregates

  // TODO graph-like interface

  // identifiers / coordinates
  void addId(String id) {
    DelvItemId newId = new DelvItemId(idToCoord(id));
    _itemIdHash.put(id, _itemIds.size());
    _itemIds.add(newId);
  }
  boolean hasId(String id) {
    return (_itemIdHash.get(id) != null);
  }
  void addCoord(String[] coord) {
    DelvItemId newId = new DelvItemId(coord);
    _itemIdHash.put(coordToId(coord), _itemIds.size());
    _itemIds.add(newId);
  }

  boolean hasCoord(String[] coord) {
    return (_itemIdHash.get( coordToId(coord) ) != null);
  }


  String[] getAllIds(String attr) {
    String[] ids = new String[_itemIds.size()];
    for (int i = 0; i < _itemIds.size(); i++) {
      ids[i] = coordToId(_itemIds.get(i).name);
    }
    return ids;
  }

  String[][] getAllCoords(String attr) {
    String[][] coords = new String[_itemIds.size()][];
    for (int i = 0; i < _itemIds.size(); i++) {
      coords[i] = _itemIds.get(i).name;
    }
    return coords;
  }
  String[] getHoverIds() {
    ArrayList<String> hovered = new ArrayList<String>();
    for (DelvItemId id : _itemIds) {
      if (id.hovered) {
        hovered.add(coordToId( id.name ));
      }
    }
    return hovered.toArray(new String[hovered.size()]);
  }
  String[][] getHoverCoords() {
    ArrayList<String[]> hovered = new ArrayList<String[]>();
    for (DelvItemId id : _itemIds) {
      if (id.hovered) {
        hovered.add( id.name );
      }
    }
    return hovered.toArray(new String[hovered.size()][]);
  }
  String[] getSelectIds(String selectType) {
    // assumes selectType has already been validated
    String[] ids = new String[0];
    if (selectType.equals("PRIMARY")) {
      ids = getPrimaryIds();
    } else if (selectType.equals("SECONDARY")) {
      ids = getSecondaryIds();
    } else if (selectType.equals("TERTIARY")) {
      ids = getTertiaryIds();
    }
    return ids;
  }
  String[] getPrimaryIds() {
    ArrayList<String> selected = new ArrayList<String>();
    for (DelvItemId id : _itemIds) {
      if (id.selectedPrimary) {
        selected.add(coordToId( id.name ));
      }
    }
    return selected.toArray(new String[selected.size()]);
  }
  String[] getSecondaryIds() {
    ArrayList<String> selected = new ArrayList<String>();
    for (DelvItemId id : _itemIds) {
      if (id.selectedSecondary) {
        selected.add(coordToId( id.name ));
      }
    }
    return selected.toArray(new String[selected.size()]);
  }
  String[] getTertiaryIds() {
    ArrayList<String> selected = new ArrayList<String>();
    for (DelvItemId id : _itemIds) {
      if (id.selectedTertiary) {
        selected.add(coordToId( id.name ));
      }
    }
    return selected.toArray(new String[selected.size()]);
  }

  String[][] getSelectCoords(String selectType) {
    // assumes selectType has already been validated
    String[][] coords = new String[0][];
    if (selectType.equals("PRIMARY")) {
      coords = getPrimaryCoords();
    } else if (selectType.equals("SECONDARY")) {
      coords = getSecondaryCoords();
    } else if (selectType.equals("TERTIARY")) {
      coords = getTertiaryCoords();
    }
    return coords;
  }
  String[][] getPrimaryCoords() {
    ArrayList<String[]> selected = new ArrayList<String[]>();
    for (DelvItemId id : _itemIds) {
      if (id.selectedPrimary) {
        selected.add(id.name);
      }
    }
    return selected.toArray(new String[selected.size()][]);
  }
  String[][] getSecondaryCoords() {
    ArrayList<String[]> selected = new ArrayList<String[]>();
    for (DelvItemId id : _itemIds) {
      if (id.selectedSecondary) {
        selected.add(id.name);
      }
    }
    return selected.toArray(new String[selected.size()][]);
  }
  String[][] getTertiaryCoords() {
    ArrayList<String[]> selected = new ArrayList<String[]>();
    for (DelvItemId id : _itemIds) {
      if (id.selectedTertiary) {
        selected.add(id.name);
      }
    }
    return selected.toArray(new String[selected.size()][]);
  }

  String[] getFilterIds() {
    ArrayList<String> filtered = new ArrayList<String>();
    for (DelvItemId id : _itemIds) {
      if (id.filtered) {
        filtered.add(coordToId( id.name ));
      }
    }
    return filtered.toArray(new String[filtered.size()]);
  }
  String[][] getFilterCoords() {
    ArrayList<String[]> filtered = new ArrayList<String[]>();
    for (DelvItemId id : _itemIds) {
      if (id.filtered) {
        filtered.add(id.name);
      }
    }
    return filtered.toArray(new String[filtered.size()][]);
  }
  String getNavCenterId() {
    notImplemented("DelvBasicDataSet", "getNavCenterId", "");
    return "";
  }
  String[] getNavCenterCoord() {
    notImplemented("DelvBasicDataSet", "getNavCenterCoord", "");
    return new String[0];
  }
  String[] getNavIds() {
    ArrayList<String> navigated = new ArrayList<String>();
    for (DelvItemId id : _itemIds) {
      if (id.navigated) {
        navigated.add(coordToId( id.name ));
      }
    }
    return navigated.toArray(new String[navigated.size()]);
  }
  String[][] getNavCoords() {
    ArrayList<String[]> navigated = new ArrayList<String[]>();
    for (DelvItemId id : _itemIds) {
      if (id.navigated) {
        navigated.add(id.name);
      }
    }
    return navigated.toArray(new String[navigated.size()][]);
  }

  int getNumIds() {
    return _itemIds.size();
  }
  int getNumCoords() {
    return _itemIds.size();
  }
  String getNextId() {
    return "" + _itemIds.size();
  }
  // return a unique coordinate in nD multidimensional space where n is specified by numCoords
  String[] getNextCoord(int numCoords)  {
    String[] coord = new String[numCoords];
    String sz = "" + _itemIds.size();
    for (int cc = 0; cc < numCoords; cc++) {
      coord[cc] = sz;
    }
    return coord;
  }
  void removeId(String id) {
    // TODO switch to entrySet once working in Processing
    for (String attr : _attributes.keySet()) {
      _attributes.get(attr).removeItem(id);
    }
    int idx = _itemIdHash.remove(id);
    _itemIds.remove(idx);
  }

  void removeCoord(String[] coord) {
    // TODO switch to entrySet once working in Processing
    for (String attr : _attributes.keySet()) {
      _attributes.get(attr).removeItem(coord);
    }
    int idx = _itemIdHash.remove( coordToId(coord) );
    _itemIds.remove(idx);
  }

  // items
  void clearItems() {
    // TODO switch to entrySet once working in Processing
    for (String attr : _attributes.keySet()) {
      _attributes.get(attr).clearItems();
    }
    _itemIds = new ArrayList<DelvItemId>();
    _itemIdHash = new HashMap<String, Integer>();
  }
  void setItem(String attr, String id, String item) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      if (!hasId(id)) {
        addId(id);
      }
      at.setItem(id, item);
    } else {
      println("Warning in setItem! Attribute <"+attr+"> does not exist.");
    }
  }
  void setItem(String attr, String[] coord, String item) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      if (!hasCoord(coord)) {
        addCoord(coord);
      }
      at.setItem(coord, item);
    } else {
      println("Warning in setItem! Attribute <"+attr+"> does not exist.");
    }
  }
  void setFloatItem(String attr, String id, Float item) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      if (!hasId(id)) {
        addId(id);
      }
      at.setFloatItem(id, item);
    } else {
      println("Warning in setFloatItem! Attribute <"+attr+"> does not exist.");
    }
  }
  void setFloatItem(String attr, String[] coord, Float item) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      if (!hasCoord(coord)) {
        addCoord(coord);
      }
      at.setFloatItem(coord, item);
    } else {
      println("Warning in setFloatItem! Attribute <"+attr+"> does not exist.");
    }
  }
  void setFloatArrayItem(String attr, String id, float[] item) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      if (!hasId(id)) {
        addId(id);
      }
      at.setFloatArrayItem(id, item);
    } else {
      println("Warning in setFloatArrayItem! Attribute <"+attr+"> does not exist.");
    }
  }
  void setFloatArrayItem(String attr, String[] coord, float[] item) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      if (!hasCoord(coord)) {
        addCoord(coord);
      }
      at.setFloatArrayItem(coord, item);
    } else {
      println("Warning in setFloatArrayItem! Attribute <"+attr+"> does not exist.");
    }
  }
  void setStringArrayItem(String attr, String id, String[] item) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      if (!hasId(id)) {
        addId(id);
      }
      at.setStringArrayItem(id, item);
    } else {
      println("Warning in setStringArrayItem! Attribute <"+attr+"> does not exist.");
    }
  }
  void setStringArrayItem(String attr, String[] coord, String[] item) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      if (!hasCoord(coord)) {
        addCoord(coord);
      }
     at.setStringArrayItem(coord, item);
    } else {
      println("Warning in setStringArrayItem! Attribute <"+attr+"> does not exist.");
    }
  }

  String getItem(String attr, String id) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getItem(id);
    } else {
      println("Warning in getItem! Attribute <"+attr+"> does not exist.");
      return "";
    }
  }
  String getItem(String attr, String[] coord) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getItem(coord);
    } else {
      println("Warning in getItem! Attribute <"+attr+"> does not exist.");
      return "";
    }
  }
  Float getItemAsFloat(String attr, String id) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getItemAsFloat(id);
    } else {
      println("Warning in getItemAsFloat! Attribute <"+attr+"> does not exist.");
      return null;
    }
  }
  Float getItemAsFloat(String attr, String[] coord) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getItemAsFloat(coord);
    } else {
      println("Warning in getItemAsFloat! Attribute <"+attr+"> does not exist.");
      return null;
    }
  }
  float[] getItemAsFloatArray(String attr, String id) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getItemAsFloatArray(id);
    } else {
      println("Warning in getItemAsFloatArray! Attribute <"+attr+"> does not exist.");
      return new float[0];
    }
  }
  float[] getItemAsFloatArray(String attr, String[] coord) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getItemAsFloatArray(coord);
    } else {
      println("Warning in getItemAsFloatArray! Attribute <"+attr+"> does not exist.");
      return new float[0];
    }
  }
  String[] getItemAsStringArray(String attr, String id) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getItemAsStringArray(id);
    } else {
      println("Warning in getItemAsStringArray! Attribute <"+attr+"> does not exist.");
      return new String[0];
    }
  }
  String[] getItemAsStringArray(String attr, String[] coord) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getItemAsStringArray(coord);
    } else {
      println("Warning in getItemAsStringArray! Attribute <"+attr+"> does not exist.");
      return new String[0];
    }
  };

  String[] getAllItems(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      int numItems = _itemIds.size();
      String[] items = new String[numItems];
      for (int i = 0; i < numItems; i++) {
        // TODO here is a place to use sorted items, not just items in insertion order
        items[i] = at.getItem(_itemIds.get(i).name);
      }
      return items;
    } else {
       println("Warning in getAllItems! Attribute <"+attr+"> does not exist.");
      return new String[0];
    }
  }
  Float[] getAllItemsAsFloat(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      int numItems = _itemIds.size();
      Float[] items = new Float[numItems];
      for (int i = 0; i < numItems; i++) {
        // TODO here is a place to use sorted items, not just items in insertion order
        items[i] = at.getItemAsFloat(_itemIds.get(i).name);
      }
      return items;
    } else {
       println("Warning in getAllItemsAsFloat! Attribute <"+attr+"> does not exist.");
      return new Float[0];
    }
  }
  float[][] getAllItemsAsFloatArray(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      int numItems = _itemIds.size();
      float[][] items = new float[numItems][];
      for (int i = 0; i < numItems; i++) {
        // TODO here is a place to use sorted items, not just items in insertion order
        items[i] = at.getItemAsFloatArray(_itemIds.get(i).name);
      }
      return items;
    } else {
       println("Warning in getAllItemsAsFloatArray! Attribute <"+attr+"> does not exist.");
      return new float[0][];
    }
  }
  String[][] getAllItemsAsStringArray(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      int numItems = _itemIds.size();
      String[][] items = new String[numItems][];
      for (int i = 0; i < numItems; i++) {
        // TODO here is a place to use sorted items, not just items in insertion order
        items[i] = at.getItemAsStringArray(_itemIds.get(i).name);
      }
      return items;
    } else {
       println("Warning in getAllItemsAsStringArray! Attribute <"+attr+"> does not exist.");
      return new String[0][];
    }
  }

  String getMin(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getMinVal();
    } else {
       println("Warning in getMin! Attribute <"+attr+"> does not exist.");
      return "";
    }
  }
  String getMax(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getMaxVal();
    } else {
       println("Warning in getMax! Attribute <"+attr+"> does not exist.");
      return "";
    }
  }

  String[] getHoverItems(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<String> hovered = new ArrayList<String>();
      for (DelvItemId id : _itemIds) {
        if (id.hovered) {
          hovered.add( at.getItem(id.name) );
        }
      }
      return hovered.toArray(new String[hovered.size()]);
    } else {
       println("Warning in getHoverItems! Attribute <"+attr+"> does not exist.");
      return new String[0];
    }
  }
  Float[] getHoverItemsAsFloat(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<Float> hovered = new ArrayList<Float>();
      for (DelvItemId id : _itemIds) {
        if (id.hovered) {
          hovered.add( at.getItemAsFloat(id.name) );
        }
      }
      return hovered.toArray(new Float[hovered.size()]);
    } else {
       println("Warning in getHoverItemsAsFloat! Attribute <"+attr+"> does not exist.");
      return new Float[0];
    }
  }
  float[][] getHoverItemsAsFloatArray(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<float[]> hovered = new ArrayList<float[]>();
      for (DelvItemId id : _itemIds) {
        if (id.hovered) {
          hovered.add( at.getItemAsFloatArray(id.name) );
        }
      }
      return hovered.toArray(new float[hovered.size()][]);
    } else {
       println("Warning in getHoverItemsAsFloatArray! Attribute <"+attr+"> does not exist.");
      return new float[0][];
    }
  }
  String[][] getHoverItemsAsStringArray(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<String[]> hovered = new ArrayList<String[]>();
      for (DelvItemId id : _itemIds) {
        if (id.hovered) {
          hovered.add( at.getItemAsStringArray(id.name) );
        }
      }
      return hovered.toArray(new String[hovered.size()][]);
    } else {
       println("Warning in getHoverItemsAsStringArray! Attribute <"+attr+"> does not exist.");
      return new String[0][];
    }
  }
  String[] getSelectItems(String attr, String selectType) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      String[][] coords = getSelectCoords(selectType);
      String[] selected = new String[coords.length];
      for (int ii = 0; ii < coords.length; ii++) {
        selected[ii] = at.getItem(coords[ii]);
    }
      return selected;
    } else {
      println("Warning in getSelectItems! Attribute <"+attr+"> does not exist.");
      return new String[0];
    }
  }
  Float[] getSelectItemsAsFloat(String attr, String selectType) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      String[][] coords = getSelectCoords(selectType);
      Float[] selected = new Float[coords.length];
      for (int ii = 0; ii < coords.length; ii++) {
        selected[ii] = at.getItemAsFloat(coords[ii]);
    }
      return selected;
    } else {
       println("Warning in getSelectItemsAsFloat! Attribute <"+attr+"> does not exist.");
      return new Float[0];
    }
  }
  float[][] getSelectItemsAsFloatArray(String attr, String selectType) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      String[][] coords = getSelectCoords(selectType);
      float[][] selected = new float[coords.length][];
      for (int ii = 0; ii < coords.length; ii++) {
        selected[ii] = at.getItemAsFloatArray(coords[ii]);
    }
      return selected;
    } else {
       println("Warning in getSelectItemsAsFloatArray! Attribute <"+attr+"> does not exist.");
      return new float[0][];
    }
  }
  String[][] getSelectItemsAsStringArray(String attr, String selectType) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      String[][] coords = getSelectCoords(selectType);
      String[][] selected = new String[coords.length][];
      for (int ii = 0; ii < coords.length; ii++) {
        selected[ii] = at.getItemAsStringArray(coords[ii]);
    }
      return selected;
    } else {
       println("Warning in getSelectItemsAsStringArray! Attribute <"+attr+"> does not exist.");
      return new String[0][];
    }
  }

  String[] getFilterItems(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<String> filtered = new ArrayList<String>();
      for (DelvItemId id : _itemIds) {
        if (id.filtered) {
          filtered.add( at.getItem(id.name) );
        }
      }
      return filtered.toArray(new String[filtered.size()]);
    } else {
       println("Warning in getFilterItems! Attribute <"+attr+"> does not exist.");
      return new String[0];
    }
  }
  Float[] getFilterItemsAsFloat(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<Float> filtered = new ArrayList<Float>();
      for (DelvItemId id : _itemIds) {
        if (id.filtered) {
          filtered.add( at.getItemAsFloat(id.name) );
        }
      }
      return filtered.toArray(new Float[filtered.size()]);
    } else {
       println("Warning in getFilterItemsAsFloat! Attribute <"+attr+"> does not exist.");
      return new Float[0];
    }
  }
  float[][] getFilterItemsAsFloatArray(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<float[]> filtered = new ArrayList<float[]>();
      for (DelvItemId id : _itemIds) {
        if (id.filtered) {
          filtered.add( at.getItemAsFloatArray(id.name) );
        }
      }
      return filtered.toArray(new float[filtered.size()][]);
    } else {
       println("Warning in getFilterItemsAsFloatArray! Attribute <"+attr+"> does not exist.");
      return new float[0][];
    }
  }
  String[][] getFilterItemsAsStringArray(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<String[]> filtered = new ArrayList<String[]>();
      for (DelvItemId id : _itemIds) {
        if (id.filtered) {
          filtered.add( at.getItemAsStringArray(id.name) );
        }
      }
      return filtered.toArray(new String[filtered.size()][]);
    } else {
       println("Warning in getFilterItemsAsStringArray! Attribute <"+attr+"> does not exist.");
      return new String[0][];
    }
  }
  String[] getNavItems(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<String> navigated = new ArrayList<String>();
      for (DelvItemId id : _itemIds) {
        if (id.navigated) {
          navigated.add( at.getItem(id.name) );
        }
      }
      return navigated.toArray(new String[navigated.size()]);
    } else {
       println("Warning in getNavItems! Attribute <"+attr+"> does not exist.");
      return new String[0];
    }
  }
  Float[] getNavItemsAsFloat(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<Float> navigated = new ArrayList<Float>();
      for (DelvItemId id : _itemIds) {
        if (id.navigated) {
          navigated.add( at.getItemAsFloat(id.name) );
        }
      }
      return navigated.toArray(new Float[navigated.size()]);
    } else {
       println("Warning in getNavItemsAsFloat! Attribute <"+attr+"> does not exist.");
      return new Float[0];
    }
  }
  float[][] getNavItemsAsFloatArray(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<float[]> navigated = new ArrayList<float[]>();
      for (DelvItemId id : _itemIds) {
        if (id.navigated) {
          navigated.add( at.getItemAsFloatArray(id.name) );
        }
      }
      return navigated.toArray(new float[navigated.size()][]);
    } else {
       println("Warning in getNavItemsAsFloatArray! Attribute <"+attr+"> does not exist.");
      return new float[0][];
    }
  }
  String[][] getNavItemsAsStringArray(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      ArrayList<String[]> navigated = new ArrayList<String[]>();
      for (DelvItemId id : _itemIds) {
        if (id.navigated) {
          navigated.add( at.getItemAsStringArray(id.name) );
        }
      }
      return navigated.toArray(new String[navigated.size()][]);
    } else {
       println("Warning in getNavItemsAsStringArray! Attribute <"+attr+"> does not exist.");
      return new String[0][];
    }
  }

  String[] getItemColor(String colorByAttr, String id) {
    Integer idx = _itemIdHash.get(id);
    if (idx == null) {
      return _defaultColor;
    }
    DelvItemId item = _itemIds.get(idx);
    if ( item.hovered && _hoverColorSet  ) {
      return _hoverColor;
    } else if ( item.selectedPrimary && _selectColorsSet.get("PRIMARY") ) {
      return _selectColors.get("PRIMARY");
    } else if ( item.selectedSecondary && _selectColorsSet.get("SECONDARY") ) {
      return _selectColors.get("SECONDARY");
    } else if ( item.selectedTertiary && _selectColorsSet.get("TERTIARY") ) {
      return _selectColors.get("TERTIARY");
    } else if ( item.filtered && _filterColorSet ) {
      return _filterColor;
      // TODO mismatch between navigation and like here!!! 
    } else if ( item.navigated && _likeColorSet ) {
      return _likeColor;
    } else {
      return getItemAttrColor(colorByAttr, id);
    }
  }
  String[] getItemColor(String colorByAttr, String[] coord) {
    Integer idx = _itemIdHash.get( coordToId(coord) );
    if (idx == null) {
      return _defaultColor;
    }
    DelvItemId item = _itemIds.get(idx);
    if ( _hoverColorSet && item.hovered ) {
      return _hoverColor;
    } else if ( _selectColorsSet.get("PRIMARY") && item.selectedPrimary ) {
      return _selectColors.get("PRIMARY");
    } else if ( _selectColorsSet.get("SECONDARY") && item.selectedSecondary ) {
      return _selectColors.get("SECONDARY");
    } else if ( _selectColorsSet.get("TERTIARY") && item.selectedTertiary ) {
      return _selectColors.get("TERTIARY");
    } else if ( _filterColorSet && item.filtered ) {
      return _filterColor;
    } else if ( _likeColorSet && item.navigated ) {
      return _likeColor;
    } else {
      return getItemAttrColor(colorByAttr, coord);
    }
  }
  String[][] getItemColors(String colorByAttr) {
    String[][] colors = new String[_itemIds.size()][];
    int idx = 0;
    for (DelvItemId item : _itemIds) {
      if ( _hoverColorSet && item.hovered ) {
        colors[idx] = _hoverColor;
      } else if ( _selectColorsSet.get("PRIMARY") && item.selectedPrimary ) {
        colors[idx] = _selectColors.get("PRIMARY");
      } else if ( _selectColorsSet.get("SECONDARY") && item.selectedSecondary ) {
        colors[idx] = _selectColors.get("SECONDARY");
      } else if ( _selectColorsSet.get("TERTIARY") && item.selectedTertiary ) {
        colors[idx] = _selectColors.get("TERTIARY");
      } else if ( _filterColorSet && item.filtered ) {
        colors[idx] = _filterColor;
      } else if ( _likeColorSet && item.navigated ) {
        colors[idx] = _likeColor;
      } else {
        colors[idx] = getItemAttrColor(colorByAttr, item.name);
      }
      idx++;
    }
    return colors;
  }
  String[] getItemEncoding(String encodingByAttr, String id) {
    notImplemented("DelvBasicDataSet", "getItemEncoding", encodingByAttr + ", " + id);
    return new String[0];
  }
  String[] getItemEncoding(String encodingByAttr, String[] coord) {
    notImplemented("DelvBasicDataSet", "getItemEncoding", encodingByAttr + ", " + coord);
    return new String[0];
  }
  String[][] getItemEncodings(String encodingByAttr) {
    notImplemented("DelvBasicDataSet", "getItemEncodings", encodingByAttr);
    return new String[0][];
  }


  String[] getItemAttrColor(String colorByAttr, String id) {
    DelvAttribute at = _attributes.get(colorByAttr);
    if (at != null) {
      return at.getItemAttrColor(id);
    } else {
       println("Warning in getItemAttrColor! Attribute <"+colorByAttr+"> does not exist.");
      return _defaultColor;
    }
  }

  String[] getItemAttrColor(String colorByAttr, String[] coord) {
    DelvAttribute at = _attributes.get(colorByAttr);
    if (at != null) {
      return at.getItemAttrColor(coord);
    } else {
       println("Warning in getItemAttrColor! Attribute <"+colorByAttr+"> does not exist.");
      return _defaultColor;
    }
  }
  String[][] getItemAttrColors(String colorByAttr) {
    DelvAttribute at = _attributes.get(colorByAttr);
    if (at != null) {
      int numItems = _itemIds.size();
      String[][] colors = new String[numItems][];
      for (int i = 0; i < numItems; i++) {
        // TODO here is a place to use sorted items, not just items in insertion order
        colors[i] = at.getItemAttrColor(_itemIds.get(i).name);
      }
      return colors;
    } else {
       println("Warning in getItemAttrColors! Attribute <"+colorByAttr+"> does not exist.");
      return new String[0][];
    }
  }

  String[] getItemAttrEncoding(String encodingByAttr, String id) {
    DelvAttribute at = _attributes.get(encodingByAttr);
    if (at != null) {
      return at.getItemAttrEncoding(id);
    } else {
       println("Warning in getItemAttrEncoding! Attribute <"+encodingByAttr+"> does not exist.");
      return _defaultEncoding;
    }
  }
  String[] getItemAttrEncoding(String encodingByAttr, String[] coord) {
    DelvAttribute at = _attributes.get(encodingByAttr);
    if (at != null) {
      return at.getItemAttrEncoding(coord);
    } else {
       println("Warning in getItemAttrEncoding! Attribute <"+encodingByAttr+"> does not exist.");
      return _defaultEncoding;
    }
  }
  String[][] getItemAttrEncodings(String encodingByAttr) {
    DelvAttribute at = _attributes.get(encodingByAttr);
    if (at != null) {
      int numItems = _itemIds.size();
      String[][] encodings = new String[numItems][];
      for (int i = 0; i < numItems; i++) {
        // TODO here is a place to use sorted items, not just items in insertion order
        encodings[i] = at.getItemAttrEncoding(_itemIds.get(i).name);
      }
      return encodings;
    } else {
       println("Warning in getItemAttrEncodings! Attribute <"+encodingByAttr+"> does not exist.");
      return new String[0][];
    }
  }

  void hoverItem(String id) {
    clearHover();
    Integer idx = _itemIdHash.get(id);
    if (idx != null) {
      _itemIds.get(idx).hovered = true;
      _hoverCoord = idToCoord(id);
    }
  }
  void hoverItem(String[] coord) {
    clearHover();
    Integer idx = _itemIdHash.get( coordToId(coord) );
    if (idx != null) {
      _itemIds.get(idx).hovered = true;
      _hoverCoord = coord;
    }
  }

  void selectPrimaryItems(String[] ids, boolean doSelect) {
    DelvCategoricalRange range = new DelvCategoricalRange();
    for (int ii = 0; ii < ids.length; ii++) {
      Integer idx = _itemIdHash.get(ids[ii]);
      if (idx != null) {
        _itemIds.get(idx).selectedPrimary = doSelect;
        // TODO should this be added to the range if select is false?  Probably need to toggleFiltered based on that.  until this is dealt with, deselect is probably broken
        range.addCategory(ids[ii]);
      }
    }
    HashMap< String, DelvRange > selectMap = new HashMap< String, DelvRange >();
    selectMap.put("__id__", range);
    _selectRanges.get("PRIMARY").add(selectMap);
  }
  void selectSecondaryItems(String[] ids, boolean doSelect) {
    DelvCategoricalRange range = new DelvCategoricalRange();
    for (int ii = 0; ii < ids.length; ii++) {
      Integer idx = _itemIdHash.get(ids[ii]);
      if (idx != null) {
        _itemIds.get(idx).selectedSecondary = doSelect;
        range.addCategory(ids[ii]);
      }
    }
    HashMap< String, DelvRange > selectMap = new HashMap< String, DelvRange >();
    selectMap.put("__id__", range);
    _selectRanges.get("SECONDARY").add(selectMap);
  }
  void selectTertiaryItems(String[] ids, boolean doSelect) {
    DelvCategoricalRange range = new DelvCategoricalRange();
    for (int ii = 0; ii < ids.length; ii++) {
      Integer idx = _itemIdHash.get(ids[ii]);
      if (idx != null) {
        _itemIds.get(idx).selectedTertiary = doSelect;
        range.addCategory(ids[ii]);
      }
    }
    HashMap< String, DelvRange > selectMap = new HashMap< String, DelvRange >();
    selectMap.put("__id__", range);
    _selectRanges.get("TERTIARY").add(selectMap);
  }

  void selectItems(String[] ids, String selectType, boolean doSelect) {
    // TODO switches on String for Java 1.7 or greater
    if (selectType.equals("PRIMARY")) {
      selectPrimaryItems(ids, doSelect);
    } else if (selectType.equals("SECONDARY")) {
      selectSecondaryItems(ids, doSelect);
    } else if (selectType.equals("TERTIARY")) {
      selectTertiaryItems(ids, doSelect);
    }
  }

  void selectItems(String[] ids, String selectType) {
    selectItems(ids, selectType, true);
  }
  void deselectItems(String[] ids, String selectType) {
    notImplemented("DelvBasicDataSet", "deselectItems", "<ids>, " + selectType);
    //selectItems(ids, selectType, false);
  }
  void selectItems(String[][] coords, String selectType) {
    String[] ids = new String[coords.length];
    for (int ii = 0; ii < coords.length; ii++) {
      ids[ii] = coordToId(coords[ii]);
    }
    selectItems(ids, selectType, true);
  }
  void deselectItems(String[][] coords, String selectType) {
    notImplemented("DelvBasicDataSet", "deselectItems", "<coords>, " + selectType);
    //String[] ids = new String[coords.length][];
    //for (int ii = 0; ii < coords.length; ii++) {
    //  ids[ii] = coordToId(coords[ii]);
    //}
    //selectItems(ids, selectType, false);
  }

  void navItem(String id, String numItems) {
    notImplemented("DelvBasicDataSet", "navItem", id + ", " + numItems);
  }
  void navItem(String[] coord, String numItems) {
    notImplemented("DelvBasicDataSet", "navItem", "<coord> , " + numItems);
  }
  void panItem(String id) {
    notImplemented("DelvBasicDataSet", "panItem", id);
  }
  void panItem(String[] coord) {
    notImplemented("DelvBasicDataSet", "panItem", "<coord>");
  }
  void zoomItem(String numItems) {
    notImplemented("DelvBasicDataSet", "zoomItem", numItems);
  }

  String getNumNavItems() {
    int numItems = 0;
    for (DelvItemId id : _itemIds) {
      if (id.navigated) {
        numItems++;
      }
    }
    return ""+numItems;
  }

  // attributes
  void clearAttributes() {
    _attributes = new HashMap<String, DelvBasicAttribute>();
  }
  void addAttr(DelvAttribute attr) {
    _attributes.put(attr.getName(), attr);
  }
  Boolean hasAttr(String attr) {
    return _attributes.containsKey(attr);
  }
  String[] getAttrs() {
    return _attributes.keySet().toArray(new String[0]);
  }
  String[] getAllCats(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getAllCats();
    } else {
      println("Warning in getAllCats! Attribute <"+attr+"> does not exist.");
      return new String[0];
    }
  }
  String[] getCatColor(String attr, String cat) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getCatColor(cat);
    } else {
      println("Warning in getCatColor! Attribute <"+attr+"> does not exist.");
    }
    return _defaultColor;
  }
  String[][] getCatColors(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      return at.getCatColors();
    } else {
      println("Warning in getCatColors! Attribute <"+attr+"> does not exist.");
    }
    return new String[0][];
  }
  String[][] getFilterCatColors(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      String[] cats = getFilterCats(attr);
      String[][] colors = new String[cats.length][];
      for (int cat = 0; cat < cats.length; cat++) {
        colors[cat] = at.getCatColor(cats[cat]);
      }
      return colors;
    } else {
      println("Warning in getFilterCatColors! Attribute <"+attr+"> does not exist.");
    }
    return new String[0][];
  }
  String[] getCatEncoding(String attr, String cat) {
    notImplemented("DelvBasicDataSet", "getCatEncoding", attr + ", " + cat);
    return _defaultEncoding;
  }
  String[][] getCatEncodings(String attr) {
    notImplemented("DelvBasicDataSet", "getCatEncodings", attr);
    return new String[0][];
  }

  void hoverCat(String attr, String cat) {
    clearHover();
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      DelvRange range;
      if (at.isCategorical()) {
        range = new DelvCategoricalRange();
        ((DelvCategoricalRange)range).addCategory(cat);
      } else {
        range = new DelvContinuousRange();
        ((DelvContinuousRange)range).update(parseFloat(cat));
      }
      _hoverRange.set(attr, range);
      determineHoveredItems();
    } else {
      println("Warning in hoverCat! Attribute <"+attr+"> does not exist.");
      DelvRange range = new DelvCategoricalRange();
      _hoverRange.set("", range);
    }
  }
  void hoverRange(String attr, String minVal, String maxVal) {
    clearHover();
    DelvAttribute at = _attributes.get(attr);
    // TODO validate that attr is continuous type?
    if (at != null) {
       DelvRange range = new DelvContinuousRange();
       ((DelvContinuousRange)range).setMin(parseFloat(minVal));
       ((DelvContinuousRange)range).setMax(parseFloat(maxVal));
      _hoverRange.set(attr, range);
      determineHoveredItems();
    } else {
      println("Warning in hoverRange! Attribute <"+attr+"> does not exist.");
      DelvRange range = new DelvContinuousRange();
      _hoverRange.set("", range);
    }
  }

  // TOO How to apply selection logic ANDS during single call, ORed across multiple calls
  void selectCats(String[] attrs, String[] cats, String selectType) {
    if (attrs.length != cats.length) {
      println("Warning in selectCats!  length of attrs and cats don't match!");
      return;
    }
    ArrayList< HashMap< String, DelvRange > > selectList = _selectRanges.get(selectType);
    HashMap< String, DelvRange > selectMap = new HashMap<String, DelvRange>();
    DelvRange range = new DelvCategoricalRange();
    for (int ii = 0; ii < attrs.length; ii++) {
      DelvAttribute at = _attributes.get(attrs[ii]);
      if (at != null) {
        range = selectMap.get(attrs[ii]);
        if (at.isCategorical()) {
          if (range == null) {
            range = new DelvCategoricalRange();
          }
          ((DelvCategoricalRange)range).addCategory(cats[ii]);
        } else {
          if (range == null) {
            range = new DelvContinuousRange();
          }
          ((DelvContinuousRange)range).update(parseFloat(cats[ii]));
        }
      } else {
      println("Warning in selectCats!  Attr< " + attrs[ii] + " not found!");
      }
      selectMap.put(attrs[ii], range);
    }
    selectList.add(selectMap);
    determineSelectedItems(selectType);
  }
  void deselectCats(String[] attrs, String[] cats, String selectType) {
    // TODO not sure how to implement this right now
    notImplemented("DelvBasicDataSet", "deselectCats", "<attrs>, <cats>, "+selectType);
  }
  void selectRanges(String[] attrs, String[] mins, String[] maxes, String selectType) {
    if (attrs.length != mins.length) {
      println("Warning in selectRanges!  length of attrs and mins don't match!");
      return;
    }
    if (attrs.length != maxes.length) {
      println("Warning in selectRanges!  length of attrs and maxes don't match!");
      return;
    }
    ArrayList< HashMap< String, DelvRange > > selectList = _selectRanges.get(selectType);
    HashMap< String, DelvRange > selectMap = new HashMap<String, DelvRange>();
    DelvRange range = new DelvContinuousRange();
    for (int ii = 0; ii < attrs.length; ii++) {
      DelvAttribute at = _attributes.get(attrs[ii]);
      if (at != null) {
        range = selectMap.get(attrs[ii]);
        if (range == null) {
          range = new DelvContinuousRange();
        }
        ((DelvContinuousRange)range).setMin(parseFloat(mins[ii]));
        ((DelvContinuousRange)range).setMax(parseFloat(maxes[ii]));
        selectMap.put(attrs[ii], range);
      } else {
        println("Warning in selectRanges!  Attr< " + attrs[ii] + " not found!");
      }
    }
    selectList.add(selectMap);
    determineSelectedItems(selectType);
  }
  void deselectRanges(String[] attrs, String[] mins, String[] maxes, String selectType) {
    // TODO not sure how to implement this right now
    notImplemented("DelvBasicDataSet", "deselectRanges", "<attrs>, <mins>, <maxes>, "+selectType);
  }
  // TOO How to apply filter logic ORS during single call, ANDed across multiple calls
  void filterCats(String attr, String[] cats) {
    ArrayList<DelvRange> ranges = new ArrayList<DelvRange>();
    DelvRange range;
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      if (at.isCategorical()) {
        at.filterNone();
      }
      for (int ii = 0; ii < cats.length; ii++) {
        if (at.isCategorical()) {
          at.toggleCatFilter(cats[ii]);
        } else {
          range = new DelvContinuousRange();
          ((DelvContinuousRange)range).update(parseFloat(cats[ii]));
          ranges.add(range);
        }
      }
      _filterRanges.put(attr, ranges);
      determineFilteredItems();
    } else {
      println("Warning in filterCats!  Attr <" +attr+"> not found!");
    }
  }
  void toggleCatFilter(String attr, String cat) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null && at.isCategorical()) {
      at.toggleCatFilter(cat);
      _filterRanges.put(attr, new ArrayList<DelvRange>());
      determineFilteredItems();
    } else {
      println("Warning in toggleCatFilter!  Attr <" +attr+"> not found or is not categorical!");
    }
  }
  void filterRanges(String attr, String[] mins, String[] maxes) {
    if (mins.length != maxes.length) {
      println("Warning in filterRanges!  length of mins and maxes don't match!");
      return;
    }
    ArrayList<DelvRange> ranges = new ArrayList<DelvRange>();
    DelvRange range;
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      for (int ii = 0; ii < mins.length; ii++) {
        range = new DelvContinuousRange();
        ((DelvContinuousRange)range).updateMin(parseFloat(mins[ii]));
        ((DelvContinuousRange)range).updateMax(parseFloat(maxes[ii]));
        ranges.add(range);
      }
      _filterRanges.put(attr, ranges);
      determineFilteredItems();
    } else {
      println("Warning in filterRanges!  Attr <" +attr+"> not found!");
    }
  }

  void colorCat(String attr, String cat, String[] rgbaColor)  {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      at.colorCat(cat, rgbaColor);
    } else {
      println("Warning in colorCat! Attribute <"+attr+"> does not exist.");
    }
  }
  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String attr, String cat, String encoding)  {
    DelvAttribute at = _attributes.get(attr);
    if (at != null) {
      at.encodeCat(cat, encoding);
    } else {
      println("Warning in encodeCat! Attribute <"+attr+"> does not exist.");
    }
  }

  // following works for ordered categorical attribute
  void navVal(String attr, String value, String leftVal, String rightVal) {
    notImplemented("DelvBasicDataSet","navVal", attr+", "+value+", "+leftVal+", "+rightVal);
  }

  // following works for unordered categorical attribute
  void navCat(String attr, String cat, String numCats) {
    notImplemented("DelvBasicDataSet","navCat", attr+", "+cat+", "+numCats);
  }

  void navRange(String attr, String center, String minVal, String maxVal) {
    notImplemented("DelvBasicDataSet","navRange", attr+", "+center+", "+minVal+", "+maxVal);
  }

  // width specified in data space
  void navRange(String attr, String center, String width) {
    notImplemented("DelvBasicDataSet","navRange", attr+", "+center+", "+width);
  }


  void panVal(String attr, String val) {
    notImplemented("DelvBasicDataSet","panVal", attr+", "+val);
  }

  void panCat(String attr, String cat) {
    notImplemented("DelvBasicDataSet","panCat", attr+", "+cat);
  }

  void panRange(String attr, String center) {
    notImplemented("DelvBasicDataSet","pnaRange", attr+", "+center);
  }

  void zoomVal(String attr, String leftVal, String rightVal) {
    notImplemented("DelvBasicDataSet", "zoomVal", attr+", "+leftVal+", "+rightVal);
  }
  void zoomCat(String attr, String numCats) {
    notImplemented("DelvBasicDataSet","zoomCat", attr+", "+numCats);
  }

  void zoomRange(String attr, String minVal, String maxVal) {
    notImplemented("DelvBasicDataSet","zoomRange", attr+", "+minVal+", "+maxVal);
  }

  // width specified in data space
  void zoomRange(String attr, String width) {
    notImplemented("DelvBasicDataSet","zoomRange", attr+", "+width);
  }

  void determineHoveredItems() {
    DelvAttribute at = _attributes.get(_hoverRange.getFirst());
    if (at != null) {
      DelvRange range = _hoverRange.getSecond();
      if (range != null) {
        for (DelvItemId id: _itemIds) {
          if (range.isInRange(at.getItem(id.name))) {
            id.hovered = true;
          } else {
            id.hovered = false;
          }
        }
      }
    }
  }
  void determineSelectedItems(String selectType) {
    if (selectType.equals("PRIMARY")) {
      determinePrimarySelection(_selectRanges.get(selectType));
    } else if (selectType.equals("SECONDARY")) {
      determineSecondarySelection(_selectRanges.get(selectType));
    } else if (selectType.equals("TERTIARY")) {
      determineTertiarySelection(_selectRanges.get(selectType));
    }
  }
  void determinePrimarySelection(ArrayList< HashMap< String, DelvRange > > selectList) {
    // assumes many more items than selection specs
    for (DelvItemId id: _itemIds) {
      for (HashMap< String, DelvRange > selectMap: selectList) {
        boolean select = true;
        // to be selected by this expression, must be true for all attributes in this map (AND)
        for (String attr: selectMap.keySet()) {
          DelvAttribute at = _attributes.get(attr);
          if (at != null) {
            DelvRange range = selectMap.get(attr);
            if (!range.isInRange(at.getItem(id.name))) {
              select = false;
              break;
            }
          }
        }
        // to be selected, OR the above result with the previous selection state for this item
        if (select) {
          id.selectedPrimary = true;
        }
      }
    }
  }
  void determineSecondarySelection(ArrayList< HashMap< String, DelvRange > > selectList) {
    // assumes many more items than selection specs
    for (DelvItemId id: _itemIds) {
      for (HashMap< String, DelvRange > selectMap: selectList) {
        boolean select = true;
        // to be selected by this expression, must be true for all attributes in this map (AND)
        for (String attr: selectMap.keySet()) {
          DelvAttribute at = _attributes.get(attr);
          if (at != null) {
            DelvRange range = selectMap.get(attr);
            if (!range.isInRange(at.getItem(id.name))) {
              select = false;
              break;
            }
          }
        }
        // to be selected, OR the above result with the previous selection state for this item
        if (select) {
          id.selectedSecondary = true;
        }
      }
    }
  }
  void determineTertiarySelection(ArrayList< HashMap< String, DelvRange > > selectList) {
    // assumes many more items than selection specs
    for (DelvItemId id: _itemIds) {
      for (HashMap< String, DelvRange > selectMap: selectList) {
        boolean select = true;
        // to be selected by this expression, must be true for all attributes in this map (AND)
        for (String attr: selectMap.keySet()) {
          DelvAttribute at = _attributes.get(attr);
          if (at != null) {
            DelvRange range = selectMap.get(attr);
            if (!range.isInRange(at.getItem(id.name))) {
              select = false;
              break;
            }
          }
        }
        // to be selected, OR the above result with the previous selection state for this item
        if (select) {
          id.selectedTertiary = true;
        }
      }
    }
  }
  void determineFilteredItems() {
    for (DelvItemId id: _itemIds) {
      boolean filter = true;
      for (String filterAttr: _filterRanges.keySet()) {
        boolean attrFiltered = false;
        // to be filtered by this expression, must be true for one of the ranges for this attribute (OR)
        DelvAttribute at = _attributes.get(filterAttr);
        if (at != null) {
          if (at.isCategorical() && at.isFiltered(id.name)) {
            attrFiltered = true;
          } else {
            ArrayList< DelvRange > ranges = _filterRanges.get(filterAttr);
            if (ranges != null) {
              for (DelvRange range: ranges) {
                if (range.isInRange(at.getItem(id.name))) {
                  attrFiltered = true;
                  break;
                }
              }
            }
          }
        }
        // to be filtered, AND the above result with the previous filter state for this item
        if (!attrFiltered) {
          filter = false;
          break;
        }
      }
      id.filtered = filter;
    }

  }
  void determineNavItems() {
    notImplemented("DelvBasicDataSet","determineNavItems", "");
  }

  String getHoverCat(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null && at.isCategorical()) {
      if (_hoverCoord.length > 0) {
        return at.getItem(_hoverCoord);
      } else {
        if (!attr.equals(_hoverRange.getFirst())) {
          // not the hovered attribute, so can't return the assoc cat
          return "";
        }
        DelvRange range = _hoverRange.getSecond();
        String[] cats = ((DelvCategoricalRange)range).getFilteredCategories();
        if (cats.length > 0) {
          return cats[0]; // TODO should never be more than one category here
        } else {
          return "";
        }
      }
    } else {
      return "";
    }
  }
  String[] getHoverRange(String attr) {
    DelvAttribute at = _attributes.get(attr);
    if (at != null && !at.isCategorical()) {
      if (_hoverCoord.length > 0) {
        String[] vals = new String[2];
        vals[0] = at.getItem(_hoverCoord);
        vals[1] = vals[0];
        return vals;
      } else {
        if (!attr.equals(_hoverRange.getFirst())) {
          // not the hovered attribute, so can't return the assoc range
          return new String[0];
        }
        DelvRange range = _hoverRange.getSecond();
        String[] vals = new String[2];
        vals[0] = ""+((DelvContinuousRange)range).getMin(); // TODO should be guaranteed to have both here, enforce/check?
        vals[1] = ""+((DelvContinuousRange)range).getMax();
        return vals;
      }
    } else {
      return new String[0];
    }
  }
  String[] getSelectCats(String attr, String selectType) {
    DelvCategoricalRange cats = new DelvCategoricalRange();
    ArrayList< HashMap< String, DelvRange > > selectList = _selectRanges.get(selectType);
    DelvAttribute at = _attributes.get(attr);
    if (at != null && at.isCategorical()) {
      for (HashMap< String, DelvRange > selectMap: selectList) {
        DelvRange range = selectMap.get(attr);
        if (range != null) {
          String[] cts = ((DelvCategoricalRange)range).getFilteredCategories();
          for (int cat = 0; cat < cts.length; cat++) {
            cats.addCategory(cts[cat]);
          }
        }
        range = selectMap.get("__id__");
        if (range != null) {
          String[] ids = ((DelvCategoricalRange)range).getFilteredCategories();
          for (int id = 0; id < ids.length; id++) {
            cats.addCategory(at.getItem(ids[id]));
          }
        }
      }
    }
    // Since this is returning categories for a particular attribute, cats can only be ORed together
    return cats.getFilteredCategories();
  }

  String[][] getSelectRanges(String attr, String selectType) {
    ArrayList<String[]> selectRanges = new ArrayList<String []>();
    ArrayList< HashMap< String, DelvRange > > selectList = _selectRanges.get(selectType);
    DelvAttribute at = _attributes.get(attr);
    if (at != null && !at.isCategorical()) {
      for (HashMap< String, DelvRange > selectMap: selectList) {
        DelvRange range = selectMap.get(attr);
        if (range != null) {
          String[] vals = new String[2];
          vals[0] = ""+((DelvContinuousRange)range).getMin();
          vals[1] = ""+((DelvContinuousRange)range).getMax();
          selectRanges.add(vals);
        }
        range = selectMap.get("__id__");
        if (range != null) {
          String[] ids = ((DelvCategoricalRange)range).getFilteredCategories();
          DelvContinuousRange idrange = new DelvContinuousRange();
          for (int id = 0; id < ids.length; id++) {
            idrange.update(at.getItemAsFloat(ids[id]));
          }
          String[] vals = new String[2];
          vals[0] = ""+idrange.getMin();
          vals[1] = ""+idrange.getMax();
          selectRanges.add(vals);
        }
      }
    }
    // TODO not collapsing because the ranges should be ORed appropriately based on dimension
    return selectRanges.toArray(new String[selectRanges.size()][]);
  }
  String[][][] getSelectCriteria(String selectType) {
    // TODO document that attr is first entry in return value
    ArrayList< HashMap< String, DelvRange > > selectList = _selectRanges.get(selectType);
    String[][][] selectCrits = new String[selectList.size()][][];
    int numMaps = 0;
    for (HashMap< String, DelvRange > selectMap: selectList) {
      selectCrits[numMaps] = new String[selectMap.size()][];
      int numKeys = 0;
      for (String attr: selectMap.keySet()) {
        DelvRange range = selectMap.get(attr);
        if (attr.equals("__id__")) {
          if (range != null) {
            String[] cats = ((DelvCategoricalRange)range).getFilteredCategories();
            String[] vals = new String[cats.length+1];
            System.arraycopy(cats, 0, vals, 1, cats.length);
            vals[0] = "__id__";
            selectCrits[numMaps][numKeys] = vals;
          } else {
            selectCrits[numMaps][numKeys] = new String[0];
          }
        } else {
          DelvAttribute at = _attributes.get(attr);
          if (range != null && at != null) {
            if (at.isCategorical()) {
              String[] cats = ((DelvCategoricalRange)range).getFilteredCategories();
              String[] vals = new String[cats.length+1];
              System.arraycopy(cats, 0, vals, 1, cats.length);
              vals[0] = attr;
              selectCrits[numMaps][numKeys] = vals;
            } else {
              String[] vals = new String[3];
              vals[0] = attr;
              vals[1] = ""+((DelvContinuousRange)range).getMin();
              vals[2] = ""+((DelvContinuousRange)range).getMax();
              selectCrits[numMaps][numKeys] = vals;
            }
          } else {
            selectCrits[numMaps][numKeys] = new String[0];
          }
        }
        numKeys++;
      }
      numMaps++;
    }
    // TODO not collapsing because the categories should be ANDed and ORed appropriately based on dimension
    return selectCrits;
  }

  String[] getFilterCats(String attr) {
    // TODO Doc how getting filtered categories for an attribute means getting all the categories
    // that are present in the filtered data.  To get the criteria specifically, use getFilterCriteria
    // TODO have an attribute-specific version of getFilterCriteria?
    DelvAttribute at = _attributes.get(attr);
    if (at != null && at.isCategorical()) {
      return at.getFilterCats();
    } else {
      return new String[0];
    }
  }
  String[][] getFilterRanges(String attr) {
    ArrayList<String[]> filterVals = new ArrayList<String[]>();
    DelvAttribute at = _attributes.get(attr);
    ArrayList<DelvRange> ranges = _filterRanges.get(attr);
    if (at != null && !at.isCategorical()) {
      if (ranges != null) {
        for (DelvRange range: ranges) {
          if (range != null) {
            String[] vals = new String[2];
            vals[0] = ""+((DelvContinuousRange)range).getMin();
            vals[1] = ""+((DelvContinuousRange)range).getMax();
            filterVals.add(vals);
          }
        }
      } else {
        // ranges not specified so return range of the data
        String[] vals = new String[2];
        vals[0] = at.getMinVal();
        vals[1] = at.getMaxVal();
        filterVals.add(vals);
      }
    }
    // TODO not collapsing because the ranges should be ORED appropriately based on dimension
    return filterVals.toArray(new String[filterVals.size()][]);
  }

  String[][] getFilterCriteria() {
    ArrayList<String[]> filterCrits = new ArrayList<String[]>();
    for (String attr: _filterRanges.keySet()) {
      DelvAttribute at = _attributes.get(attr);
      if (at != null) {
        if (at.isCategorical()) {
          String[] cats = at.getFilterCats();
          String[] vals = new String[cats.length+1];
          System.arraycopy(cats, 0, vals, 1, cats.length);
          vals[0] = attr;
          filterCrits.add(vals);
        } else {
          ArrayList< DelvRange > ranges = _filterRanges.get(attr);
          if (ranges != null) {
            for (DelvRange range: ranges) {
              String[] vals = new String[3];
              vals[0] = attr;
              vals[1] = ""+((DelvContinuousRange)range).getMin();
              vals[2] = ""+((DelvContinuousRange)range).getMax();
              filterCrits.add(vals);
            }
          }
        }
      }
    }
    // TODO not collapsing because the ranges should be ANDed and ORed appropriately based on dimension
    return filterCrits.toArray(new String[filterCrits.size()][]);
  }
  String getNavCenterVal(String attr) {
    notImplemented("DelvBasicDataSet","getNavCenterVal", attr);
    return "";
  }
  String getNavLeftVal(String attr) {
    notImplemented("DelvBasicDataSet","getNavLeftVal", attr);
    return "";
  }
  String getNavRightVal(String attr) {
    notImplemented("DelvBasicDataSet","getNavRightVal", attr);
    return "";
  }
  String getNumNavCats(String attr) {
    notImplemented("DelvBasicDataSet","getNumNavCats", attr);
    return "";
  }
  String getNavMinVal(String attr) {
    notImplemented("DelvBasicDataSet","getNavMinVal", attr);
    return "";
  }
  String getNavMaxVal(String attr) {
    notImplemented("DelvBasicDataSet","getNavMaxVal", attr);
    return "";
  }
  String getNavWidth(String attr) {
    notImplemented("DelvBasicDataSet","getNavWidth", attr);
    return "";
  }

  // Relationships
  void hoverLike(String id, String relationship) {
    notImplemented("DelvBasicDataSet","hoverLike", id+", "+relationship);
  }
  void hoverLike(String[] coord, String relationship) {
    notImplemented("DelvBasicDataSet","hoverLike", "<coord>, "+relationship);
  }
  void clearHover() {
    _hoverCoord = new String[0];
    _hoverRange = new DelvPair<String, DelvRange>("", new DelvCategoricalRange());
    for (DelvItemId id : _itemIds) {
      id.hovered = false;
    }
  }

  void selectLike(String[] ids, String[] relationships, String selectType) {
    notImplemented("DelvBasicDataSet","selectLike", "<ids>, <relationships>, "+selectType);
  }
  void deselectLike(String[] ids, String[] relationships, String selectType) {
    notImplemented("DelvBasicDataSet","deselectLike", "<ids>, <relationships>, "+selectType);
  }
  void selectLike(String[][] coords, String[] relationships, String selectType) {
    notImplemented("DelvBasicDataSet","selectLike", "<coords>, <relationships>, "+selectType);
  }
  void deselectLike(String[][] coords, String[] relationships, String selectType) {
    notImplemented("DelvBasicDataSet","deselectLike", "<coords>, <relationships>, "+selectType);
  }
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String selectType) {
    _selectRanges.put(selectType, new ArrayList< HashMap< String, DelvRange > >());
    if (selectType.equals("PRIMARY")) {
      for (DelvItemId id : _itemIds) {
        id.selectedPrimary = false;
      }
    } else if (selectType.equals("SECONDARY")) {
      for (DelvItemId id : _itemIds) {
        id.selectedSecondary = false;
      }
    } else if (selectType.equals("TERTIARY")) {
      for (DelvItemId id : _itemIds) {
        id.selectedTertiary = false;
      }
    }
    // TODO clear relationship select structure
  }

  void filterLike(String[] ids, String[] relationships) {
    notImplemented("DelvBasicDataSet","filterLike", "<ids>, <relationships>");
  }
  void filterLike(String[][] coords, String[] relationships) {
    notImplemented("DelvBasicDataSet","filterLike", "<coords>, <relationships>");
  }
  void clearFilter() {
    _filterRanges = new HashMap< String, ArrayList< DelvRange > >();
    for (DelvItemId id : _itemIds) {
      id.filtered = true;
    }
    // TODO better to just loop through categorical attributes actually in filterRanges?
    for (DelvAttribute at: _attributes.values()) {
      if (at.isCategorical()) {
        at.filterAll();
      }
    }
    // TODO clear relationship filter structure
  }

  void navLike(String id, String relationship, String numLikeItems) {
    notImplemented("DelvBasicDataSet","navLike", id+", "+ relationship+", "+numLikeItems);
  }
  void navLike(String[] coord, String relationship, String numLikeItems) {
    notImplemented("DelvBasicDataSet","navLike", "<coord>, "+ relationship+", "+numLikeItems);
  }
  void clearNav() {
    notImplemented("DelvBasicDataSet","clearNav","");
  }

  void panLike(String id, String relationship) {
    notImplemented("DelvBasicDataSet","panLike", id+", "+ relationship);
  }
  void panLike(String[] coord, String relationship) {
    notImplemented("DelvBasicDataSet","panLike", "<coord>, "+ relationship);
  }

  void zoomLike(String numLikeItems) {
    notImplemented("DelvBasicDataSet","zoomLike", numLikeItems);
  }

  void setLOD(String levelOfDetail) {
    notImplemented("DelvBasicDataSet","setLOD", levelOfDetail);
  }
  // TODO how do we want this to work?  It returns the coordinate/relationship pair or just the relationship
  String[] getHoverLike() {
    notImplemented("DelvBasicDataSet","getHoverLike", "");
    return new String[0];
  }
  String[][] getSelectLike(String selectType) {
    notImplemented("DelvBasicDataSet","getSelectLike", selectType);
    return new String[0][];
  }
  String[][] getFilterLike() {
    notImplemented("DelvBasicDataSet","getFilterLike", "");
    return new String[0][];
  }
  String getNavLike() {
    notImplemented("DelvBasicDataSet","getNavLike", "");
    return "";
  }
  String getNumNavLike() {
    notImplemented("DelvBasicDataSet","getNumNavLike", "");
    return "";
  }
  String getLOD() {
    notImplemented("DelvBasicDataSet","getLOD", "");
    return "";
  }

  // color
  void hoverColor(String[] rgbaColor) {
    _hoverColor = rgbaColor;
    _hoverColorSet = true;
  }
  void selectColor(String[] rgbaColor, String selectType) {
    _selectColors.put(selectType, rgbaColor);
    _selectColorsSet.put(selectType, true);
  }
  void filterColor(String[] rgbaColor) {
    _filterColor = rgbaColor;
    _filterColorSet = true;
  }
  void likeColor(String[] rgbaColor) {
    _likeColor = rgbaColor;
    _likeColorSet = true;
  }

  void clearHoverColor() {
    _hoverColorSet = false;
  }
  void clearSelectColor(String selectType) {
    _selectColorsSet.put(selectType, false);
  }
  void clearFilterColor() {
    _filterColorSet = false;
  }
  void clearLikeColor() {
    _likeColorSet = false;
  }

  String[] getHoverColor() {
    return _hoverColorSet ? _hoverColor : _defaultColor;
  }
  String[] getSelectColor(String selectType) {
    return _selectColorsSet.get(selectType) ? _selectColors.get(selectType) : _defaultColor;
  }
  String[] getFilterColor() {
    return _filterColorSet ? _filterColor : _defaultColor;
  }
  String[] getLikeColor() {
    return _likeColorSet ? _likeColor : _defaultColor;
  }

} // end class DelvBasicDataSet

public class DelvBasicAttribute implements DelvAttribute {
  String _name;
  HashMap<String, String> _items;
  // TODO should decide a better name and probably store as double
  // And really this is a horrible hack.  Storage should be based on Attribute type, create some actual classes here
  //TreeMap<String, Float[] > _floatArrayItems;
  // float array is to more efficiently store a long list of items
  // whereas string array is to store an array of strings for each item
  HashMap<String, Integer> _floatArrayMap;
  float[][] _floatArrayItems;
  HashMap<String, String[]> _stringArrayItems;
  HashMap<String, Float>  _floatItems;
  AttributeType _type;
  // TODO color map
  DelvColorMap _colorMap;
  DelvRange _fullRange;

  DelvBasicAttribute(String name, AttributeType type, DelvColorMap color_map, DelvRange data_range) {
    _name = name;
    _items = new HashMap<String, String>((int)Math.ceil(100000/.75)); // 75% of required capacity
    _floatArrayMap = new HashMap<String, Integer>((int)Math.ceil(100000/.75));
    _floatArrayItems = new float[0][];
    _stringArrayItems = new HashMap<String, String[]>();
    _floatItems = new HashMap<String, Float>((int)Math.ceil(100000/.75));
    _type = type;
    _colorMap = color_map;
    _fullRange = data_range;
  }

  boolean isCategorical() {
    return (_type.equals(AttributeType.CATEGORICAL) || _type.equals(AttributeType.CATEGORICAL_LIST));
  }

  String getName() {
    return _name;
  }
  void setName(String name) {
    _name = name;
  }

  // items
  void removeItem(String id) {
    _items.remove(id);
    _floatItems.remove(id);
    _stringArrayItems.remove(id);
    if (_type.equals(AttributeType.FLOAT_ARRAY)) {
      Integer idx = _floatArrayMap.get(id);
      int old_size = _floatArrayItems.length;
      float[][] tmpArray = new float[old_size-1][];
      System.arraycopy(_floatArrayItems, 0, tmpArray, 0, idx);
      System.arraycopy(_floatArrayItems, idx+1, tmpArray, idx, old_size-idx-1);
      _floatArrayItems = tmpArray;
      _floatArrayMap.remove(id);
      // and now update the indexes in the map
      // TODO Bug in Processing, following entrySet syntax doesn't compile.
      // iterating on just keys for now instead
      //for (Map.Entry<String, Integer> entry : _floatArrayMap.entrySet()) {
      for (String anId : _floatArrayMap.keySet()) {
        // since we don't have entrySet yet, do the following instead:
        // String anId = entry.getKey();
        // Integer anIdx = entry.getValue();
        Integer anIdx = _floatArrayMap.get(anId);
        if (anIdx > idx) {
          _floatArrayMap.put(anId, anIdx-1);
        }
      }
    }
  }
  void removeItem(String[] coord) {
    removeItem(coordToId(coord));
  }
  void clearItems() {
    _items = new HashMap<String, String>((int)Math.ceil(100000/.75));
    _floatArrayMap = new HashMap<String, Integer>((int)Math.ceil(100000/.75));
    _floatArrayItems = new float[0][];
    _stringArrayItems = new HashMap<String, String[]>();
    _floatItems = new HashMap<String, Float>((int)Math.ceil(100000/.75));
    _fullRange.clear();
  }

  void setItem(String id, String item) {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      _items.put(id, item);
      ((DelvCategoricalRange)_fullRange).addCategory(item);
    } else if (_type.equals(AttributeType.CONTINUOUS)) {
      Float val = parseFloat(item);
      _floatItems.put(id, val);
      ((DelvContinuousRange)_fullRange).update(val);
    } else if (_type.equals(AttributeType.FLOAT_ARRAY)) {
      // TODO fix this
      println("Cannot set a FLOAT_ARRAY from String");
    } else if (_type.equals(AttributeType.CATEGORICAL_LIST)) {
      // TODO fix this
      println("Cannot set a CATEGORICAL_LIST from String");
    }
  }
  void setItem(String[] coord, String item) {
    setItem(coordToId(coord), item);
  }
  void setFloatItem(String id, Float item) {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      _floatItems.put(id, item);
      ((DelvContinuousRange)_fullRange).update(item);
    }
  }
  void setFloatItem(String[] coord, Float item) {
    setFloatItem(coordToId(coord), item);
  }
  void setFloatArrayItem(String id, float[] item) {
    if (_type.equals(AttributeType.FLOAT_ARRAY)) {
      Integer idx;
      if (!_floatArrayMap.containsKey(id)) {
        int old_size = _floatArrayItems.length;
        float[][] tmpArray = new float[old_size+1][];
        System.arraycopy(_floatArrayItems, 0, tmpArray, 0, old_size);
        _floatArrayItems = tmpArray;
        _floatArrayMap.put(id, old_size);
        idx = old_size;
      }
      else {
      idx = _floatArrayMap.get(id);
      }
      _floatArrayItems[idx] = item;
    }
  }
  void setFloatArrayItem(String[] coord, float[] item) {
    setFloatArrayItem(coordToId(coord), item);
  }
  void setStringArrayItem(String id, String[] item) {
    if (_type.equals(AttributeType.CATEGORICAL_LIST)) {
      _stringArrayItems.put(id, item);
      for (int ii = 0; ii < item.length; ii++) {
        ((DelvCategoricalRange)_fullRange).addCategory(item[ii]);
      }
    }
  }
  void setStringArrayItem(String[] coord, String[] item) {
    setStringArrayItem(coordToId(coord), item);
  }

  String getItem(String id) {
    if (_items.containsKey(id)) {
      return "" + _items.get(id);
    } else if (_floatItems.containsKey(id)) {
      return "" + _floatItems.get(id);
    } else {
      return "";
    }
  }
  String getItem(String[] coord) {
    return getItem(coordToId(coord));
  }
  Float getItemAsFloat(String id) {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      return _floatItems.get(id);
    } else if (_type.equals(AttributeType.CATEGORICAL)) {
      if (_items.containsKey(id)) {
        return parseFloat(_items.get(id));
      } else {
        return 0.0f;
      }
    } else {
      return 0.0f;
    }
  }
  Float getItemAsFloat(String[] coord) {
    return getItemAsFloat(coordToId(coord));
  }
  float[] getItemAsFloatArray(String id) {
    if (_type.equals(AttributeType.FLOAT_ARRAY)) {
      Integer idx = _floatArrayMap.get(id);
      return _floatArrayItems[idx];
      // TODO does this make sense for any other type?
    } else if (_type.equals(AttributeType.CONTINUOUS)) {
      if (_items.containsKey(id)) {
        String item = _items.get(id);
        String[] vals = splitTokens( item, "," );
        float[] nums = new float[vals.length];
        for (int i = 0; i < vals.length; i++) {
          nums[i] = parseFloat(vals[i]);
        }
        return nums;
      } else {
        return new float[0];
      }
    } else {
      return new float[0];
    }
  }
  float[] getItemAsFloatArray(String[] coord) {
    return getItemAsFloatArray(coordToId(coord));
  }
  String[] getItemAsStringArray(String id) {
    if (_type.equals(AttributeType.CATEGORICAL_LIST)) {
      return _stringArrayItems.get(id);
    } else if (_type.equals(AttributeType.CATEGORICAL)) {
      // TODO split item into elements separated by , or just return item
      // in a 1-element array?
      String[] item_array = new String[1];
      item_array[0] = _items.get(id);
      return item_array;
    } else {
      return new String[0];
    }
  }
  String[] getItemAsStringArray(String[] coord) {
    return getItemAsStringArray(coordToId(coord));
  }

  String[] getAllItems() {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      String[] items = new String [_floatItems.size()];
      int cnt = 0;
      for (Float item : _floatItems.values()) {
        items[cnt++] = "" + item;
      }
      return (items);
    } else if (_type.equals(AttributeType.CATEGORICAL)) {
      String[] items = new String[_items.size()];
      int cnt = 0;
      for (String item : _items.values()) {
        items[cnt++] = item;
      }
      return (items);
    }
    return new String[0];
  }
  Float[] getAllItemsAsFloat() {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      Float[] items = new Float[_floatItems.size()];
      int cnt = 0;
      for (Float item : _floatItems.values()) {
        items[cnt++] = item;
      }
      return (items);
    } else if (_type.equals(AttributeType.CATEGORICAL)) {
      // TODO handle case where type doesn't convert well better
      Float[] items = new Float[_items.size()];
      int cnt = 0;
      for (String item : _items.values()) {
        items[cnt++] = parseFloat(item);
      }
      return (items);
    }
    return (new Float[0]);
  }
  float[][] getAllItemsAsFloatArray() {
    if (_type.equals(AttributeType.FLOAT_ARRAY)) {
      return _floatArrayItems;
      // TODO does this make sense for any other type?
    } else if (_type.equals(AttributeType.CONTINUOUS)) {
      float[][] items = new float[_items.size()][];
      int cnt = 0;
      for (String item : _items.values()) {
        String[] vals = splitTokens( item, "," );
        float[] nums = new float[vals.length];
        for (int i = 0; i < vals.length; i++) {
          nums[i] = parseFloat(vals[i]);
        }
        items[cnt++] = nums;
      }
      return (items);
    }
    return (new float[0][0]);
  }
  String[][] getAllItemsAsStringArray() {
    // TODO Warning!!! all getAllItems* methods in Attributes are dangerous because they don't return values in a consistent order!!!  Use care when calling this method directly or even get rid of it entirely or reimplement it to return a guaranteed order.
    if (_type.equals(AttributeType.CATEGORICAL_LIST)) {
      String[][] items = new String[_stringArrayItems.size()][];
      int cnt = 0;
      for (String[] item: _stringArrayItems.values()) {
        items[cnt++] = item;
      }
      return items;
    } else if (_type.equals(AttributeType.CATEGORICAL)) {
      String[][] items = new String[_items.size()][];
      int cnt = 0;
      for (String item : _items.values()) {
        String[] val = new String[1];
        val[0] = item;
        items[cnt++] = val;
      }
      return (items);
    }
    return (new String[0][0]);
  }

  String[] getItemAttrColor(String id) {
    color c = _colorMap.getColor(getItem(id));
    return toRGBAString(c);
  }
  String[] getItemAttrColor(String[] coord) {
    return getItemAttrColor(coordToId(coord));
  }
  String[] getItemAttrEncoding(String id) {
    notImplemented("DelvBasicAttribute", "getItemAttrEncoding", id);
    return new String[0];
  }
  String[] getItemAttrEncoding(String[] coord) {
    return getItemAttrEncoding(coordToId(coord));
  }

  String[] getAllCats() {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      return ((DelvCategoricalRange)_fullRange).getCategories();
    } else {
      return new String[0];
    }
  }
  String[] getFilterCats() {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      return ((DelvCategoricalRange)_fullRange).getFilteredCategories();
    } else {
      return new String[0];
    }
  }
  String[] getCatColor(String cat) {
    color c = _colorMap.getColor(cat);
    return toRGBAString(c);
  }
  String[][] getCatColors(){
    String[] cats = getAllCats();
    String[][] colors = new String[cats.length][];
    for (int i = 0; i < cats.length; i++) {
      colors[i] = getCatColor(cats[i]);
    }
    return colors;
  }
  String[] getCatEncoding(String cat) {
    notImplemented("DelvBasicAttribute", "getCatEncoding", cat);
    return new String[0];
  }
  String[][] getCatEncodings() {
    String[] cats = getAllCats();
    String[][] encs = new String[cats.length][];
    for (int i = 0; i < cats.length; i++) {
      encs[i] = getCatEncoding(cats[i]);
    }
    return encs;
  }
  String getMinVal() {
    if (!isCategorical()) {
      // TODO how to handle ordered categories?
      return ""+((DelvContinuousRange)_fullRange).getMin();
    } else {
      return "";
    }
  }
  String getMaxVal() {
    if (!isCategorical()) {
      // TODO how to handle ordered categories?
      return ""+((DelvContinuousRange)_fullRange).getMax();
    } else {
      return "";
    }
  }

  void colorCat(String cat, String[] rgbaColor) {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      _colorMap.setColor(cat, toP5Color(rgbaColor));
    }
  }
  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String cat, String encoding) {
    notImplemented("DelvBasicAttribute","encodeCat", cat+", "+encoding);
  }

  // all items pass filter
  void filterAll() {
    ((DelvCategoricalRange)_fullRange).filterAll();
  }
  // all items fail filter
  void filterNone() {
    ((DelvCategoricalRange)_fullRange).filterNone();
  }
  void toggleCatFilter(String cat) {
    ((DelvCategoricalRange)_fullRange).toggleFiltered(cat);
  }
  boolean isFiltered(String id) {
    return ((DelvCategoricalRange)_fullRange).isCategoryFiltered(getItem(id));
  }
  boolean isFiltered(String[] coord) {
    return ((DelvCategoricalRange)_fullRange).isCategoryFiltered(getItem(coord));
  }

} // end class DelvBasicAttribute

public class DelvCSVDataSet extends DelvBasicDataSet {
  String _filename;
  String _dataset;
  String _old_dataset;
  String _delim;
  String _comment;

  public DelvCSVDataSet(String name) {
    this("", "", name);
  }

  public DelvCSVDataSet(String filename, String dataset, String name) {
    super(name);
    _filename = filename;
    _dataset = dataset;
    if (_filename.equals("")) {
      _filename = "./test_data/cars.csv";
    }
    if (_dataset.equals("")) {
      _dataset = "csv";
    }
    _old_dataset = _dataset;
    _delim = ",";
    _comment = "#";
  }

  public DelvDataSet delim(String aDelim) {
    _delim = aDelim;
    return this;
  }

  public String delim() {
    return _delim;
  }

  public DelvDataSet comment(String aComment) {
    _comment = aComment;
    return this;
  }

  public String comment() {
    return _comment;
  }

  public DelvDataSet newDataSetFromFile(String filename, String dataset) {
    _old_dataset = _dataset;
    _dataset = dataset;
    _filename = filename;
    return this;
  }

  public void loadData() {
    load_from_file(_filename);
  }

  public void load_from_file(String filename) {
    clearData();
    createDataset();
    populateDataset();
  }

  public void clearData() {
    // TODO right way to do this?  Better to have caller remove from Delv?
    if (_delv != null) {
      _delv.removeDataSet(_old_dataset);
    }
  }

  public void createDataset() {
    // set up dataset
    color def_col = color_( 210 );
    // read in the first 50 rows and count the number of unique values for each column whose data can be transformed into a float or int.  If more than 12 unique values in each column, then consider that column to be CONTINUOUS.  Otherwise it's CATEGORICAL

    BufferedReader reader = createReader(_filename);
    String line;
    String[] header = new String[0];
    HashMap<Float, Float>[] attrs = new HashMap[0]; // TODO float vs double(parseDouble available?), also HashSets not in Processing.js
    int numcols = 0;
    int maxlines = 50;
    for (int lineno = 0; lineno < maxlines; lineno++) {
      try {
        line = reader.readLine();
      } catch (IOException e) {
        e.printStackTrace();
        line = null;
      }
      if (line == null) {
        break;
      } else {
        String[] cols = split( line, _delim); // TODO TAB too?
        if (lineno == 0) {
          // TODO ALWAYS assume header?  Yes, otherwise need another way to specify attribute names.
          header = cols;
          numcols = header.length;
          attrs = new HashMap[numcols];
          for (int ii=0; ii < numcols; ii++) {
            attrs[ii] = new HashMap<Float, Float>();
          }
        } else {
          if (cols.length != numcols) {
            // TODO invalid row, ignore for now
            println("Invalid row, expected " + numcols + " columns, found " + cols.length + " instead for row " + lineno + ": " + line);
          } else {
            // valid row, do some figuring
            for (int ii = 0; ii < numcols; ii++) {
              // first check if it's a float or not, only put it in the set if it is convertible to a number
              Float val = parseFloat(cols[ii]);
              if (!(Float.isNaN(val))) {
                attrs[ii].put(val,val);
              }
            }
          }
        }
      }
    }

    for (int ii = 0; ii < numcols; ii++) {
      // now choose CONTINUOUS if length of attrs[ii] > 12
      if (attrs[ii].size() > 12) {
        println("Adding CONTINUOUS attribute " + header[ii].trim());
        addAttr(new DelvBasicAttribute(header[ii].trim(), AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
      } else {
        println("Adding CATEGORICAL attribute " + header[ii].trim());
        addAttr(new DelvBasicAttribute(header[ii].trim(), AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
      }
    }
  }

  public void populateDataset( ) {
    String[] rows = loadStrings( _filename );
    int counter = 0;
    String[] cols;
    String[] header = new String[0];

    String name = "";
    String totLength = "";
    String pheno = "";
    while ( counter < rows.length )
    {
      cols = split( rows[counter++], _delim); // TODO TAB too?

      if ( cols.length == 0 ) {
        continue;
      } else if ( cols[0].trim().substring(0,_comment.length()).equals(_comment) ) {
        continue;
      } else if (counter == 1) {
        header = cols;
      } else {
        String id = getNextId();

        addId(id);
        for (int ii = 0; ii < header.length; ii++) {
          setItem(header[ii].trim(), id, cols[ii].trim());
        }
      }
    }
  }

} // end class DelvCSVDataSet


public class DelvDiscreteColorMap implements DelvColorMap {
  color _defaultColor;
  HashMap<String, Integer> _colors;

  DelvDiscreteColorMap() {
    this( color_( 220 ) );
  }

  DelvDiscreteColorMap(color default_color) {
    _defaultColor = default_color;
    _colors = new HashMap<String, Integer>();
  }

  color getColor(String value) {
    if (_colors.containsKey(value)) {
      return _colors.get(value);
    } else {
      return _defaultColor;
    }
  }

  void setColor(String value, color c) {
    // sets color map for entry value to color color
    // overrides existing color if that value already exists
    _colors.put(value, c);
  }

  void setDefaultColor(color c) {
    _defaultColor = c;
  }

  // way to visualize color map
  void drawToFile(String filename) {
    background(color_(255,255,255));
    //size(_colors.size() * 50, 50);
    noStroke();
    int i = 0;
    for (color c : _colors.values()) {
      fill(red_(c),green_(c),blue_(c));
      rect(i * 50, 0, 50, 50);
      i++;
    }
    save(filename);
  }
} // end class DelvDiscreteColorMap

  class HalfOpenRange {
    float _lower;
    float _upper;
    boolean _hasLower;
    boolean _hasUpper;

    // implements a half-open range [lower, upper)
    // TODO be sure to enforce condition that both lb and ub can't be None for the same entry
    HalfOpenRange() {
      _lower = 0;
      _upper = 1;
      _hasLower = false;
      _hasUpper = false;
    }

    void setLower(float val) {
      _hasLower = true;
      _lower = val;
    }
    void setUpper(float val) {
      _hasUpper = true;
      _upper = val;
    }

    boolean overlapped(HalfOpenRange other) {
      boolean status = false;
      if ((other._hasLower && this.contains(other._lower)) || (other._hasUpper && this.contains(other._upper))) {
        status = true;
      }
      return status;
    }

    boolean contains(float value) {
      boolean status = false;
      // TODO python version had this wrapped in an if value != None check.  Is that necessary still?
      if (!_hasLower && value < _upper) {
            status = true;
      } else if (!_hasUpper && value >= _lower) {
        status = true;
      } else if (_lower <= value && value < _upper) {
        status = true;
      }
      return status;
    }
  } // end class HalfOpenRange

class DelvContinuousColorMap implements DelvColorMap {
  ArrayList<HalfOpenRange> _bounds;
  ArrayList<DelvColorFun> _colors;
  color _defaultColor;

  DelvContinuousColorMap() {
    this( color_( 220 ) );
  }

  DelvContinuousColorMap(color default_color) {
    _defaultColor = default_color;
    _bounds = new ArrayList<HalfOpenRange>();
    _colors = new ArrayList<DelvColorFun>();
  }

  color getColor(String value) {
    int idx = -1;
    float val = parseFloat(value);
    for (int i = 0; i < _bounds.size(); i++) {
      if (_bounds.get(i).contains(val)) {
        idx = i;
        break;
      }
    }
    if (idx < 0) {
      return _defaultColor;
    } else {
      DelvColorFun colorfun = _colors.get(idx);
      if (colorfun != null) {
        HalfOpenRange bound = _bounds.get(idx);
        float lb = bound._lower;
        float ub = bound._upper;
        float relval = 0;
        // TODO how to handle case when _hasUpper or _hasLower is false
        if (!bound._hasLower) {
          relval = (Float)(val) / ub;
        } else if (!bound._hasUpper) {
          relval = 1 - (lb / (Float)(val));
        } else {
          relval = ((Float)(val) - lb) / (ub - lb);
        }
        return colorfun.getColor((Float)(relval));
      } else {
        return _defaultColor;
      }
    }
  }

  void setColor(String value, color c) {
  // not provided
  }

  void setColor(HalfOpenRange contRange, DelvColorFun colorfun) {
    // if the input range overlaps an existing range, the new input range takes precedence
    int numBounds = _bounds.size();
    int insertLoc;

    if (!contRange._hasLower) {
      insertLoc = 0;
    } else {
      insertLoc = numBounds;
      for (int i = 0; i < numBounds; i++) {
        if (_bounds.get(i)._lower == contRange._lower) {
          insertLoc = i;
          break;
        } else if (contRange._lower < _bounds.get(i)._lower) {
          insertLoc = i;
          break;
        }
      }
    }

    if (insertLoc == numBounds) {
      _bounds.add(contRange);
      _colors.add(colorfun);
      return;
    }

    int finalLoc;
    if (!contRange._hasUpper) {
      finalLoc = numBounds-1;
    } else {
      finalLoc = 0;
      for (int i = 0; i < numBounds; i++) {
        if (_bounds.get(i)._upper == contRange._upper) {
          finalLoc = i+1;
          break;
        } else if (_bounds.get(i)._upper > contRange._upper) {
          finalLoc = i-1;
          break;
        }
      }
    }

    if (insertLoc < finalLoc) {
      ArrayList<HalfOpenRange> newBounds = new ArrayList<HalfOpenRange>(_bounds.subList(0,insertLoc));
      newBounds.addAll(_bounds.subList(finalLoc,_bounds.size()));
      _bounds = newBounds;

      ArrayList<DelvColorFun> newColors = new ArrayList<DelvColorFun>(_colors.subList(0,insertLoc));
      newColors.addAll(_colors.subList(finalLoc,_colors.size()));
      _colors = newColors;
    }
    if (insertLoc > 0) {
      if (_bounds.get(insertLoc-1)._upper > contRange._lower) {
        _bounds.get(insertLoc-1)._upper = contRange._lower;
      }
    }
    if (insertLoc + 1 < _bounds.size()) {
      if (_bounds.get(insertLoc+1)._lower < contRange._upper) {
        _bounds.get(insertLoc+1)._lower = contRange._upper;
      }
    }
    _bounds.add(insertLoc, contRange);
    _colors.add(insertLoc, colorfun);
  }

  void setDefaultColor(color c) {
    _defaultColor = c;
  }

  void drawToFile(String filename) {
    if (_bounds.size() == 0) {
      return;
    }
    int numsamp = 1000;
    int numbounds = _bounds.size();
    int numsampperbound = numsamp / numbounds;
    numsamp = numsampperbound * numbounds;
    ArrayList<Float> samps = new ArrayList<Float>();

    float lb;
    float ub;
    HalfOpenRange b = _bounds.get(0);
    if (!b._hasLower) {
      lb = b._upper / 10;
    } else {
      lb = b._lower;
    }

    b = _bounds.get(numbounds - 1);
    if (!b._hasUpper) {
      ub = b._lower * 10;
    } else {
      ub = b._upper;
    }

    for (int i = 0; i < numsamp; i++) {
      samps.add(lb + i * (ub-lb) / numsamp);
    }

    background(color_(255,255,255));
    //size(numsamp, 50);
    noStroke();
    int i = 0;
    for (Float val : samps) {
      color c = getColor(""+val);
      fill(red_(c),green_(c),blue_(c));
      rect(i * 50, 0, 50, 50);
      i++;
    }
    save(filename);
  }
} //end class DelvContinuousColorMap

// some Id/Coord helper utilities
boolean coordsEqual(String[] coord1, String[] coord2) {
  if (coord1.length != coord2.length) {
    return false;
  }
  boolean matches = true;
  for (int cc=0; cc < coord1.length; cc++) {
    if (!coord1[cc].equals(coord2[cc])) {
      matches = false;
      break;
    }
  }
  return matches;
}

String coordToId(String[] coord) {
  if (coord.length == 0) {
    return "";
  } else {
    String id = coord[0];
    for (int cc = 1; cc < coord.length; cc++) {
      id = id + ";" + coord[cc];
    }
    return id;
  }
}

  String[] idToCoord(String id) {
    // TODO perhaps unhardcode separator
    return id.split(";");
  }

// some helper color utilities
String[] toRGBAString(color c) {
      String[] colorStr = new String[4];
    colorStr[0] = "" + red_(c);
    colorStr[1] = "" + green_(c);
    colorStr[2] = "" + blue_(c);
    colorStr[3] = "" + alpha_(c);
    return colorStr;
}
String[] toRGBString(color c) {
      String[] colorStr = new String[3];
    colorStr[0] = "" + red_(c);
    colorStr[1] = "" + green_(c);
    colorStr[2] = "" + blue_(c);
    return colorStr;
}

color toP5Color(String[] rgbaColor) {
  int alpha = 255;
  if (rgbaColor.length > 3) {
    alpha = int(rgbaColor[3]);
  }
  return color_(int(rgbaColor[0]), int(rgbaColor[1]), int(rgbaColor[2]), alpha);
}

float interp1(float start, float end, float value, float maximum) {
  return start + (end - start) * value / maximum;
}

float[] interp3(float[] start, float[] end, float value, float maximum) {
  float[] r = new float[3];
  r[0] = interp1(start[0], end[0], value, maximum);
  r[1] = interp1(start[1], end[1], value, maximum);
  r[2] = interp1(start[2], end[2], value, maximum);
  return r;
}
float[] interp4(float[] start, float[] end, float value, float maximum) {
  float[] r = new float[4];
  r[0] = interp1(start[0], end[0], value, maximum);
  r[1] = interp1(start[1], end[1], value, maximum);
  r[2] = interp1(start[2], end[2], value, maximum);
  r[3] = interp1(start[3], end[3], value, maximum);
  return r;
}

float[] rgb2hsv(float r, float g, float b) {
  // takes r, g, b in range 0 to 1
  // returns hsv in range 0 to 1
  float minrgb = Math.min( r, Math.min(g, b) );
  float maxrgb = Math.max( r, Math.max(g, b) );
  float diff = maxrgb - minrgb;

  float[] hsv = new float[3];
  hsv[2] = maxrgb;

  if ( diff == 0 ) {
    // grayscale
    hsv[0] = 0;
    hsv[1] = 0;
  } else {
    // has color
    hsv[1] = diff / maxrgb;

    float diffR = ( ( ( maxrgb - r ) / 6 ) + ( diff / 2 ) ) / diff;
    float diffG = ( ( ( maxrgb - g ) / 6 ) + ( diff / 2 ) ) / diff;
    float diffB = ( ( ( maxrgb - b ) / 6 ) + ( diff / 2 ) ) / diff;

    if      ( r == maxrgb ) { hsv[0] = diffB - diffG; }
    else if ( g == maxrgb ) { hsv[0] = ( 1 / 3 ) + diffR - diffB; }
    else if ( b == maxrgb ) { hsv[0] = ( 2 / 3 ) + diffG - diffR; }

    if ( hsv[0] < 0 ) { hsv[0] += 1; }
    if ( hsv[0] > 1 ) { hsv[0] -= 1; }
  }
  return hsv;
}

float[] hsv2rgb(float h, float s, float v) {
  // takes h, s, v from range 0 to 1
  // returns rgb in range 0 to 1
  float[] rgb = new float[3];
  if ( s == 0 ) {
    rgb[0] = v;
    rgb[1] = v;
    rgb[2] = v;
  } else {
    float scaleH;
    float i;
    float p;
    float q;
    float t;
    scaleH = h * 6;
    if ( scaleH == 6 ) {
      //scaleH must be < 1
      scaleH = 0;
    }
    i = (float) Math.floor( scaleH );             //Or ... var_i = floor( var_h )
    p = v * ( 1 - s );
    q = v * ( 1 - s * ( scaleH - i ) );
    t = v * ( 1 - s * ( 1 - ( scaleH - i ) ) );

    if      ( i == 0 ) { rgb[0] = v ; rgb[1] = t ; rgb[2] = p; }
    else if ( i == 1 ) { rgb[0] = q ; rgb[1] = v ; rgb[2] = p; }
    else if ( i == 2 ) { rgb[0] = p ; rgb[1] = v ; rgb[2] = t; }
    else if ( i == 3 ) { rgb[0] = p ; rgb[1] = q ; rgb[2] = v; }
    else if ( i == 4 ) { rgb[0] = t ; rgb[1] = p ; rgb[2] = v; }
    else               { rgb[0] = v ; rgb[1] = p ; rgb[2] = q; }
  }
  return rgb;
}

color lerp(color start, color end, float value) {
  // assumes inputs are RGBA arrays
  // use algorithm from http://stackoverflow.com/questions/168838/color-scaling-function
  // convert everything to HSV
  // interpolate
  // convert back to RGBA
  float[] start_hsv = rgb2hsv(red_(start)/255.0, green_(start)/255.0, blue_(start)/255.0);
  float[] end_hsv = rgb2hsv(red_(end)/255.0, green_(end)/255.0, blue_(end)/255.0);
  float[] interp_hsv = interp3(start_hsv, end_hsv, value, 1);
  float[] interp_rgb = hsv2rgb(interp_hsv[0], interp_hsv[1], interp_hsv[2]);
  float interp_alpha = interp1(alpha_(start) / 255.0, alpha_(end) / 255.0, value, 1);
  color rgba = color_( Math.round(interp_rgb[0] * 255),
                       Math.round(interp_rgb[1] * 255),
                       Math.round(interp_rgb[2] * 255),
                       Math.round(interp_alpha * 255));
  return rgba;
}

// override Processing's color, red, green, blue, and alpha functions
// in order to cooperate better in Java environment
public int color_(float gray) {
  return color_(gray, gray, gray, 255);
}
public int color_(float gray, float alpha) {
  return color_(gray, gray, gray, alpha);
}
public int color_(float red, float green, float blue) {
  return color_(red, green, blue, 255);
}
public int color_(float red, float green, float blue, float alpha) {
  return color(red, green, blue, alpha);
}
public int color_(int gray) {
  return color_(gray, gray, gray, 255);
}
public int color_(int gray, int alpha) {
  return color_(gray, gray, gray, alpha);
}
public int color_(int red, int green, int blue) {
  return color_(red, green, blue, 255);
}
public int color_(int red, int green, int blue, int alpha) {
  return color(red, green, blue, alpha);
}
public int colorJ_(float red, float green, float blue, float alpha) {
  if (alpha > 255) alpha = 255;
  else if (alpha < 0) alpha = 0;
  if (red > 255) red = 255;
  else if (red < 0) red = 0;
  if (green > 255) green = 255;
  else if (green < 0) green = 0;
  if (blue > 255) blue = 255;
  else if (blue < 0) blue = 0;
  return colorJ_((int)red, (int)green, (int)blue, (int)alpha);
}
public int colorJ_(int red, int green, int blue, int alpha) {
  // use for Java versions of Delv
  // doesn't work for Javascript though
  // from https://www.processing.org/reference/leftshift.html
  int a = alpha;
  int r = red;
  int g = green;
  int b = blue;
  a = a << 24;
  r = r << 16;
  g = g << 8;
  int argb = a | r | g | b;
  return argb;
}
public float alpha_(int clr) {
  return alpha(clr);
}
public float alphaJ_(int clr) {
  // use for Java versions of Delv
  // doesn't work for Javascript though
  int a = (clr >> 24) & 0xFF;
  return a;
}
public float red_(int clr) {
  return red(clr);
}
public float redJ_(int clr) {
  // use for Java versions of Delv
  // doesn't work for Javascript though
  int r = (clr >> 16) & 0xFF;
  return r;
}
public float green_(int clr) {
  return green(clr);
}
public float greenJ_(int clr) {
  // use for Java versions of Delv
  // doesn't work for Javascript though
  int g = (clr >> 8) & 0xFF;
  return g;
}
public float blue_(int clr) {
  return blue(clr);
}
public float blueJ_(int clr) {
  // use for Java versions of Delv
  // doesn't work for Javascript though
  int b = clr & 0xFF;
  return b;
}

// TODO create some default color functions here
// Note:  color functions assume that value will be in the range [0,1]
// This is done in order to work with the ContinuousColorMap concept above

interface DelvColorFun {
  color getColor(float value);
}

class green_scale implements DelvColorFun {
  color getColor(float value) {
    return lerp(color_(0,0,0), color_(0,255,0), value);
  }
}

class green_to_red implements DelvColorFun {
  color getColor(float value) {
    return lerp(color_(0,255,0), color_(255,0,0), value);
  }
}

class red_to_blue implements DelvColorFun {
  color getColor(float value) {
    return lerp(color_(255,0,0), color_(0,0,255), value);
  }
}

class brightgreen implements DelvColorFun {
  color getColor(float value) {
    return color_(0, 255, 0);
  }
}

class ColorMapWithCheckpoints implements DelvColorFun {
  ArrayList<Integer> _colors;

  ColorMapWithCheckpoints(ArrayList<Integer> colors) {
    if (colors.size() > 0) {
      _colors = colors;
    } else {
      _colors = new ArrayList<Integer>();
      _colors.add(unhex("FFFFD9"));
      _colors.add(unhex("EDF8B1"));
      _colors.add(unhex("C7E9B4"));
      _colors.add(unhex("7FCDBB"));
      _colors.add(unhex("41B6C4"));
      _colors.add(unhex("1D91C0"));
      _colors.add(unhex("225EA8"));
      _colors.add(unhex("253494"));
      _colors.add(unhex("081D58"));
    }
  }

  ColorMapWithCheckpoints() {
    this(new ArrayList<Integer>());
  }

  color getColor(float value) {
    // pass this class into ContinuousColorMap.setColor as colorfun
    // value is in range 0 to 1
    // divide this range into equal pieces depending on number of self.colors
    int numIntervals = _colors.size() - 1;
    float interval = 1.0 / numIntervals;
    color c = color_(255,255,255);
    for (int i = 0; i < numIntervals; ++i) {
      if (value < (i+1) * interval) {
        c = lerp(_colors.get(i), _colors.get(i+1), (value - (i)*interval) / interval);
        break;
      }
    }
    return c;
  }
} // end class ColorMapWithCheckpoints

// TODO create some default color map constructors here
String[] categorical_map_1() {
  // from MulteeSum
  String[] cmap = {"FF7F00",
                   "6A3D9A",
                   "1F78B4",
                   "33A02C",
                   "FB9A99",
                   "A6CEE3",
                   "B2DF8A",
                   "FDBF6F",
                   "CAB2D6"};
  return cmap;
}

String[] categorical_map_2() {
  // from InSite
  String[] cmap = {"1F78B4",   // blue
                   "33A02C",   // green
                   "E31A1C",   // red
                   "FF7F00",   // orange
                   "6A3D9A",   // purple
                   "D2D2D2", // clear old color (FEATURE_DEFAULT_COLOR)
                   "A6CEE3",   // lt blue
                   "B2DF8A",   // lt green
                   "FB9A99",   // lt red
                   "FDBF6F",   // lt orange
                   "CAB2D6",   // lt purple
                   "010101"}; // clear all colors (FEATURE_CLEAR_COLOR
  return cmap;
}

DelvDiscreteColorMap create_discrete_map_from_hex(String[] cats, String[] cmap) {
  color[] cmap_rgb = new color[cmap.length];
  for (int i = 0; i < cmap.length; ++i) {
    cmap_rgb[i] = unhex(cmap[i]);
  }

  return create_discrete_map(cats, cmap_rgb);
}

DelvDiscreteColorMap create_discrete_map(String[] cats, color[] cols) {
  int num_colors = cols.length;
  DelvDiscreteColorMap disc_map = new DelvDiscreteColorMap();
  for (int i = 0; i < cats.length; i++) {
    disc_map.setColor(cats[i], cols[i % num_colors]);
  }
  return disc_map;
}

void testMaps() {
  DelvContinuousColorMap cmap1 = new DelvContinuousColorMap();
  cmap1.setDefaultColor(color_(130,130,130));
  HalfOpenRange crange = new HalfOpenRange();
  crange.setUpper(.3);
  cmap1.setColor(crange, new green_scale());
  crange = new HalfOpenRange();
  crange.setLower(.5);
  crange.setUpper(.8);
  cmap1.setColor(crange, new green_to_red());
  crange = new HalfOpenRange();
  crange.setLower(.9);
  crange.setUpper(1.5);
  cmap1.setColor(crange, new red_to_blue());
  crange = new HalfOpenRange();
  crange.setLower(1.6);
  crange.setUpper(1.9);
  cmap1.setColor(crange, new brightgreen());
  cmap1.drawToFile("/tmp/custom_cont_map.png");

  DelvContinuousColorMap cmap4 = new DelvContinuousColorMap();
  DelvColorFun checkpts = new ColorMapWithCheckpoints();
  cmap4.setDefaultColor(color_(130,130,130));
  crange = new HalfOpenRange();
  crange.setLower(-10);
  crange.setUpper(20);
  cmap4.setColor(crange, checkpts);
  cmap4.drawToFile("/tmp/map_with_checkpoints.png");

  // create categorical map
  String[] cat1 = {"a","b","c","d","e","f","g","h","i"};
  DelvDiscreteColorMap cmap2 = create_discrete_map_from_hex(cat1, categorical_map_1());
  cmap2.drawToFile("/tmp/cat1.png");

  String[] cat2 = {"a","b","c","d","e","f","g","h","i","j","k","l"};
  DelvDiscreteColorMap cmap3 = create_discrete_map_from_hex(cat2, categorical_map_2());
  cmap3.drawToFile("/tmp/cat2.png");
}

