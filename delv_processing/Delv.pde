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
  void emitSignal(String signal, String invoker, String dataset, String detail);
  void emitSignal(String signal, String invoker, String dataset, String[] details);
  void connectToSignal(String signal, String name, String method);
  void disconnectFromSignal(String signal, String name);
  DelvView getView(String name);
  void addView(DelvView view, String name);
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
  Boolean hasAttr(String dataset, String attribute);
  String[] getAttrs(String dataset);
  String[] getAllCats(String dataset, String attribute);
  String[] getCatColor(String dataset, String attribute, String category);
  String[][] getCatColors(String dataset, String attribute);
  String[] getCatEncoding(String dataset, String attribute, String category);
  String[][] getCatEncodings(String dataset, String attribute);

  ////////////////////
  // data items
  ////////////////////
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
  String[] getFilterItems(String dataset, String attribute);
  Float[] getFilterItemsAsFloat(String dataset, String attribute);
  float[][] getFilterItemsAsFloatArray(String dataset, String attribute);
  String[][] getFilterItemsAsStringArray(String dataset, String attribute);

  String[] getItemColor(String dataset, String colorByAttribute, String identifier);
  String[] getItemColor(String dataset, String colorByAttribute, String[] coordinate);
  String[][] getItemColors(String dataset, String colorByAttribute);
  String[] getItemEncoding(String dataset, String encodingByAttribute, String identifier);
  String[] getItemEncoding(String dataset, String encodingByAttribute, String[] coordinate);
  String[][] getItemEncodings(String dataset, String encodingByAttribute);

  ////////////////////
  // data coordinates
  ////////////////////
  String[] getAllIds(String dataset, String attribute);
  String[][] getAllCoords(String dataset, String attribute);

  ////////////////////
  // data as graph
  ////////////////////

  // TODO put in graph-like interface

  ////////////////////
  // data operations
  ////////////////////
  // sort
  // possible values of sortType: ascending, descending
  void sortBy(String invoker, String dataset, String attribute, String sortType);
  // possible values of similarity sortType: similarity, dissimilarity
  void sortBy(String invoker, String dataset, String identifier, String sortType);
  void sortBy(String invoker, String dataset, String[] coordinate, String sortType);
  void clearSort(String invoker, String dataset);
  String[][] getSortCriteria(String dataset);

  // TODO transforms

  // TODO aggregates

  ////////////////////
  // set selections
  ////////////////////
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
  void selectItems(String invoker, String dataset, String[] coordinates, String selectType);
  void deselectItems(String invoker, String dataset, String[] coordinates, String selectType);
  void selectItems(String invoker, String dataset, String[][] coordinates, String selectType);
  void deselectItems(String invoker, String dataset, String[][] coordinates, String selectType);
  // TODO need way to pass arbitrary shape definition (ie function) not just rectangular?
  // TODO need one call of select per attribute?  Or allow multiple at once?  what about multiple ranges per attribute? think need single range per attribute since ANDing across attribute array here. to be able to OR across ranges for single attribute, would need multiple calls to select
  // TODO same question for filter
  void selectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType);
  void deselectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType);
  void selectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType);
  void deselectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType);
  void selectLike(String invoker, String dataset, String[] coordinates, String[] relationships, String selectType);
  void deselectLike(String invoker, String dataset, String[] coordinates, String[] relationships, String selectType);
  void selectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType);
  void deselectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType);
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String invoker, String dataset, String selectType);

  // TODO need filter clearing API too
  void filterCats(String invoker, String dataset, String attribute, String[] categories);
  void filterRanges(String invoker, String dataset, String attribute, String[] mins, String[] maxes);
  // TODO can we specify a coordinate in a multidimensional table as a single string?  Do we even want to?  Can we specify a generic data relationship as a string?  Is there some other representation we want to use here?
  void filterLike(String invoker, String dataset, String[] coordinates, String[] relationships);
  void filterLike(String invoker, String dataset, String[][] coordinates, String[] relationships);
  void clearFilter(String invoker, String dataset);

  // TODO need to figure out a way to specify a continuous color map (colorfun) in some cross-language way.  Some intermediate compromises might include a more generic checkpoints style interface where the colors get specified along with a value and then nicely lerped in between
  void mapColor(String invoker, String dataset, String attribute, String category, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void mapEncoding(String invoker, String dataset, String attribute, String category, String encoding);

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
  void panCat(String invoker, String dataset, String attribute, String category);
  void panRange(String invoker, String dataset, String attribute, String center);
  void panLike(String invoker, String dataset, String identifier, String relationship);
  void panLike(String invoker, String dataset, String[] coordinate, String relationship);

  // zoom changes size of window, leaving the center at the previous spot
  // TODO add a zoomOut / zoomIn API that allows jumping back to previous zoom
  void zoomItem(String invoker, String dataset, String numItems);
  void zoomVal(String invoker, String dataset, String leftVal, String rightVal);
  void zoomCat(String invoker, String dataset, String numCats);
  void zoomRange(String invoker, String dataset, String minVal, String maxVal);
  // width specified in data space
  void zoomRange(String invoker, String dataset, String width);
  void zoomLike(String invoker, String dataset, String numLikeItems);

  void setLOD(String invoker, String dataset, String levelOfDetail);

  ////////////////////
  // get selections
  ////////////////////

  String getHoverId(String dataset);
  String[] getHoverCoord(String dataset);
  String getHoverCat(String dataset, String attribute);
  String[] getHoverRange(String dataset, String attribute);
  // TODO how do we want this to work?  It returns the coordinate/relationship pair or just the relationship
  String[] getHoverLike(String dataset);

  String[] getSelectIds(String dataset, String selectType);
  String[][] getSelectCoords(String dataset, String selectType);
  String[][] getSelectCats(String dataset, String attribute, String selectType);
  String[][] getSelectRanges(String dataset, String attribute, String selectType);
  String[][] getSelectLike(String dataset, String selectType);
  String[][][] getSelectCriteria(String dataset, String selectType);

  String[] getFilterIds(String dataset);
  String[][] getFilterCoords(String dataset);
  String[][] getFilterCats(String dataset, String attribute);
  String[][] getFilterRanges(String dataset, String attribute);
  String[][] getFilterLike(String dataset);
  String[][][] getFilterCriteria(String dataset);

  // nav changes center of window and size of window
  String getNavCenterId(String dataset);
  String[] getNavCenterCoord(String dataset);
  String[] getNavIds(String dataset);
  String[][] getNavCoords(String dataset);
  String getNavNumItems(String dataset);
  String getNavCenterVal(String dataset, String attribute);
  String getNavLeftVal(String dataset, String attribute);
  String getNavRightVal(String dataset, String attribute);
  String getNavNumCats(String dataset, String attribute);
  String getNavMinVal(String dataset, String attribute);
  String getNavMaxVal(String dataset, String attribute);
  String getNavWidth(String dataset, String attribute);
  String getNavLike(String dataset);
  String getNavNumLike(String dataset);

  String getLOD(String dataset);

  ////////////////////
  // selection colors
  ////////////////////
  // TODO allow for rgba everywhere
  void setHoverColor(String[] rgbaColor);
  void setHoverColor(String dataset, String[] rgbaColor);
  void setSelectColor(String[] rgbaColor, String selectType);
  void setSelectColor(String dataset, String[] rgbaColor, String selectType);
  void setFilterColor(String[] rgbaColor);
  void setFilterColor(String dataset, String[] rgbaColor);
  void setLikeColor(String[] rgbaColor);
  void setLikeColor(String dataset, String[] rgbaColor);

  String[] getHoverColor(String dataset);
  String[] getSelectColor(String dataset, String selectType);
  String[] getFilterColor(String dataset);
  String[] getLikeColor(String dataset);
  // TODO figure out interface for setting other encodings (shape / size / etc).

 }

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

  // identifiers / coordinates
  void addId(String id);
  boolean hasId(String id);
  void addCoord(String[] coord);
  boolean hasCoord(String[] coord);

  String[] getAllIds(String attr);
  String[][] getAllCoords(String attr);
  String getHoverId();
  String[] getHoverCoord();
  String[] getSelectIds(String selectType);
  String[][] getSelectCoords(String selectType);
  String[] getFilterIds();
  String[][] getFilterCoords();
  String getNavCenterId();
  String getNavCenterCoord();
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
  String[] getFilterItems(String attr);
  Float[] getFilterItemsAsFloat(String attr);
  float[][] getFilterItemsAsFloatArray(String attr);
  String[][] getFilterItemsAsStringArray(String attr);

  String[] getItemColor(String colorByAttr, String id);
  String[] getItemColor(String colorByAttr, String[] coord);
  String[][] getItemColors(String colorByAttr);
  String[] getItemEncoding(String encodingByAttr, String id);
  String[] getItemEncoding(String encodingByAttr, String[] coord);
  String[][] getItemEncodings(String encodingByAttr);

  // attributes
  void clearAttributes();
  void addAttr(DelvBasicAttribute attr);
  Boolean hasAttr(String attr);
  String[] getAttrs();
    Boolean hasAttr(String dataset, String attribute);
  String[] getAttrs(String dataset);
  String[] getAllCats(String dataset, String attribute);
  String[] getCatColor(String dataset, String attribute, String category);
  String[][] getCatColors(String dataset, String attribute);
  String[] getCatEncoding(String dataset, String attribute, String category);
  String[][] getCatEncodings(String dataset, String attribute);

  ////////////////////
  // data items
  ////////////////////
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
  String[] getFilterItems(String dataset, String attribute);
  Float[] getFilterItemsAsFloat(String dataset, String attribute);
  float[][] getFilterItemsAsFloatArray(String dataset, String attribute);
  String[][] getFilterItemsAsStringArray(String dataset, String attribute);

  String[] getItemColor(String dataset, String colorByAttribute, String identifier);
  String[] getItemColor(String dataset, String colorByAttribute, String[] coordinate);
  String[][] getItemColors(String dataset, String colorByAttribute);
  String[] getItemEncoding(String dataset, String encodingByAttribute, String identifier);
  String[] getItemEncoding(String dataset, String encodingByAttribute, String[] coordinate);
  String[][] getItemEncodings(String dataset, String encodingByAttribute);

  ////////////////////
  // data coordinates
  ////////////////////
  String[] getAllIds(String dataset, String attribute);
  String[][] getAllCoords(String dataset, String attribute);

  ////////////////////
  // data as graph
  ////////////////////

  // TODO put in graph-like interface

  ////////////////////
  // data operations
  ////////////////////
  // sort
  // possible values of sortType: ascending, descending
  void sortBy(String invoker, String dataset, String attribute, String sortType);
  // possible values of similarity sortType: similarity, dissimilarity
  void sortBy(String invoker, String dataset, String identifier, String sortType);
  void sortBy(String invoker, String dataset, String[] coordinate, String sortType);
  void clearSort(String invoker, String dataset);
  String[][] getSortCriteria(String dataset);

  // TODO transforms

  // TODO aggregates

  ////////////////////
  // set selections
  ////////////////////
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
  void selectItems(String invoker, String dataset, String[] coordinates, String selectType);
  void deselectItems(String invoker, String dataset, String[] coordinates, String selectType);
  void selectItems(String invoker, String dataset, String[][] coordinates, String selectType);
  void deselectItems(String invoker, String dataset, String[][] coordinates, String selectType);
  // TODO need way to pass arbitrary shape definition (ie function) not just rectangular?
  // TODO need one call of select per attribute?  Or allow multiple at once?  what about multiple ranges per attribute? think need single range per attribute since ANDing across attribute array here. to be able to OR across ranges for single attribute, would need multiple calls to select
  // TODO same question for filter
  void selectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType);
  void deselectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType);
  void selectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType);
  void deselectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType);
  void selectLike(String invoker, String dataset, String[] coordinates, String[] relationships, String selectType);
  void deselectLike(String invoker, String dataset, String[] coordinates, String[] relationships, String selectType);
  void selectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType);
  void deselectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType);
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String invoker, String dataset, String selectType);

  // TODO need filter clearing API too
  void filterCats(String invoker, String dataset, String attribute, String[] categories);
  void filterRanges(String invoker, String dataset, String attribute, String[] mins, String[] maxes);
  // TODO can we specify a coordinate in a multidimensional table as a single string?  Do we even want to?  Can we specify a generic data relationship as a string?  Is there some other representation we want to use here?
  void filterLike(String invoker, String dataset, String[] coordinates, String[] relationships);
  void filterLike(String invoker, String dataset, String[][] coordinates, String[] relationships);
  void clearFilter(String invoker, String dataset);

  // TODO need to figure out a way to specify a continuous color map (colorfun) in some cross-language way.  Some intermediate compromises might include a more generic checkpoints style interface where the colors get specified along with a value and then nicely lerped in between
  void mapColor(String invoker, String dataset, String attribute, String category, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void mapEncoding(String invoker, String dataset, String attribute, String category, String encoding);

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
  void panCat(String invoker, String dataset, String attribute, String category);
  void panRange(String invoker, String dataset, String attribute, String center);
  void panLike(String invoker, String dataset, String identifier, String relationship);
  void panLike(String invoker, String dataset, String[] coordinate, String relationship);

  // zoom changes size of window, leaving the center at the previous spot
  // TODO add a zoomOut / zoomIn API that allows jumping back to previous zoom
  void zoomItem(String invoker, String dataset, String numItems);
  void zoomVal(String invoker, String dataset, String leftVal, String rightVal);
  void zoomCat(String invoker, String dataset, String numCats);
  void zoomRange(String invoker, String dataset, String minVal, String maxVal);
  // width specified in data space
  void zoomRange(String invoker, String dataset, String width);
  void zoomLike(String invoker, String dataset, String numLikeItems);

  void setLOD(String invoker, String dataset, String levelOfDetail);

  ////////////////////
  // get selections
  ////////////////////

  String getHoverId(String dataset);
  String[] getHoverCoord(String dataset);
  String getHoverCat(String dataset, String attribute);
  String[] getHoverRange(String dataset, String attribute);
  // TODO how do we want this to work?  It returns the coordinate/relationship pair or just the relationship
  String[] getHoverLike(String dataset);

  String[] getSelectIds(String dataset, String selectType);
  String[][] getSelectCoords(String dataset, String selectType);
  String[][] getSelectCats(String dataset, String attribute, String selectType);
  String[][] getSelectRanges(String dataset, String attribute, String selectType);
  String[][] getSelectLike(String dataset, String selectType);
  String[][][] getSelectCriteria(String dataset, String selectType);

  String[] getFilterIds(String dataset);
  String[][] getFilterCoords(String dataset);
  String[][] getFilterCats(String dataset, String attribute);
  String[][] getFilterRanges(String dataset, String attribute);
  String[][] getFilterLike(String dataset);
  String[][][] getFilterCriteria(String dataset);

  // nav changes center of window and size of window
  String getNavCenterId(String dataset);
  String[] getNavCenterCoord(String dataset);
  String[] getNavIds(String dataset);
  String[][] getNavCoords(String dataset);
  String getNavNumItems(String dataset);
  String getNavCenterVal(String dataset, String attribute);
  String getNavLeftVal(String dataset, String attribute);
  String getNavRightVal(String dataset, String attribute);
  String getNavNumCats(String dataset, String attribute);
  String getNavMinVal(String dataset, String attribute);
  String getNavMaxVal(String dataset, String attribute);
  String getNavWidth(String dataset, String attribute);
  String getNavLike(String dataset);
  String getNavNumLike(String dataset);

  String getLOD(String dataset);

  ////////////////////
  // selection colors
  ////////////////////
  // TODO allow for rgba everywhere
  void setHoverColor(String[] rgbaColor);
  void setHoverColor(String dataset, String[] rgbaColor);
  void setSelectColor(String[] rgbaColor, String selectType);
  void setSelectColor(String dataset, String[] rgbaColor, String selectType);
  void setFilterColor(String[] rgbaColor);
  void setFilterColor(String dataset, String[] rgbaColor);
  void setLikeColor(String[] rgbaColor);
  void setLikeColor(String dataset, String[] rgbaColor);

  String[] getHoverColor(String dataset);
  String[] getSelectColor(String dataset, String selectType);
  String[] getFilterColor(String dataset);
  String[] getLikeColor(String dataset);
  // TODO figure out interface for setting other encodings (shape / size / etc).

 }

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

  // identifiers / coordinates
  void addId(String id);
  boolean hasId(String id);
  void addCoord(String[] coord);
  boolean hasCoord(String[] coord);

  String[] getAllIds(String attr);
  String[][] getAllCoords(String attr);
  String getHoverId();
  String[] getHoverCoord();
  String[] getSelectIds(String selectType);
  String[][] getSelectCoords(String selectType);
  String[] getFilterIds();
  String[][] getFilterCoords();
  String getNavCenterId();
  String getNavCenterCoord();
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
  String[] getFilterItems(String attr);
  Float[] getFilterItemsAsFloat(String attr);
  float[][] getFilterItemsAsFloatArray(String attr);
  String[][] getFilterItemsAsStringArray(String attr);

  String[] getItemColor(String colorByAttr, String id);
  String[] getItemColor(String colorByAttr, String[] coord);
  String[][] getItemColors(String colorByAttr);
  String[] getItemEncoding(String encodingByAttr, String id);
  String[] getItemEncoding(String encodingByAttr, String[] coord);
  String[][] getItemEncodings(String encodingByAttr);

  // attributes
  void clearAttributes();
  void addAttr(DelvBasicAttribute attr);
  Boolean hasAttr(String attr);
  String[] getAttrs();
    Boolean hasAttr(String dataset, String attribute);
  String[] getAttrs(String dataset);
  String[] getAllCats(String dataset, String attribute);
  String[] getCatColor(String dataset, String attribute, String category);
  String[][] getCatColors(String dataset, String attribute);
  String[] getCatEncoding(String dataset, String attribute, String category);
  String[][] getCatEncodings(String dataset, String attribute);

  ////////////////////
  // data items
  ////////////////////
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
  String[] getFilterItems(String dataset, String attribute);
  Float[] getFilterItemsAsFloat(String dataset, String attribute);
  float[][] getFilterItemsAsFloatArray(String dataset, String attribute);
  String[][] getFilterItemsAsStringArray(String dataset, String attribute);

  String[] getItemColor(String dataset, String colorByAttribute, String identifier);
  String[] getItemColor(String dataset, String colorByAttribute, String[] coordinate);
  String[][] getItemColors(String dataset, String colorByAttribute);
  String[] getItemEncoding(String dataset, String encodingByAttribute, String identifier);
  String[] getItemEncoding(String dataset, String encodingByAttribute, String[] coordinate);
  String[][] getItemEncodings(String dataset, String encodingByAttribute);

  ////////////////////
  // data coordinates
  ////////////////////
  String[] getAllIds(String dataset, String attribute);
  String[][] getAllCoords(String dataset, String attribute);

  ////////////////////
  // data as graph
  ////////////////////

  // TODO put in graph-like interface

  ////////////////////
  // data operations
  ////////////////////
  // sort
  // possible values of sortType: ascending, descending
  void sortBy(String invoker, String dataset, String attribute, String sortType);
  // possible values of similarity sortType: similarity, dissimilarity
  void sortBy(String invoker, String dataset, String identifier, String sortType);
  void sortBy(String invoker, String dataset, String[] coordinate, String sortType);
  void clearSort(String invoker, String dataset);
  String[][] getSortCriteria(String dataset);

  // TODO transforms

  // TODO aggregates

  ////////////////////
  // set selections
  ////////////////////
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
  void selectItems(String invoker, String dataset, String[] coordinates, String selectType);
  void deselectItems(String invoker, String dataset, String[] coordinates, String selectType);
  void selectItems(String invoker, String dataset, String[][] coordinates, String selectType);
  void deselectItems(String invoker, String dataset, String[][] coordinates, String selectType);
  // TODO need way to pass arbitrary shape definition (ie function) not just rectangular?
  // TODO need one call of select per attribute?  Or allow multiple at once?  what about multiple ranges per attribute? think need single range per attribute since ANDing across attribute array here. to be able to OR across ranges for single attribute, would need multiple calls to select
  // TODO same question for filter
  void selectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType);
  void deselectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType);
  void selectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType);
  void deselectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType);
  void selectLike(String invoker, String dataset, String[] coordinates, String[] relationships, String selectType);
  void deselectLike(String invoker, String dataset, String[] coordinates, String[] relationships, String selectType);
  void selectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType);
  void deselectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType);
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String invoker, String dataset, String selectType);

  // TODO need filter clearing API too
  void filterCats(String invoker, String dataset, String attribute, String[] categories);
  void filterRanges(String invoker, String dataset, String attribute, String[] mins, String[] maxes);
  // TODO can we specify a coordinate in a multidimensional table as a single string?  Do we even want to?  Can we specify a generic data relationship as a string?  Is there some other representation we want to use here?
  void filterLike(String invoker, String dataset, String[] coordinates, String[] relationships);
  void filterLike(String invoker, String dataset, String[][] coordinates, String[] relationships);
  void clearFilter(String invoker, String dataset);

  // TODO need to figure out a way to specify a continuous color map (colorfun) in some cross-language way.  Some intermediate compromises might include a more generic checkpoints style interface where the colors get specified along with a value and then nicely lerped in between
  void mapColor(String invoker, String dataset, String attribute, String category, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void mapEncoding(String invoker, String dataset, String attribute, String category, String encoding);

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
  void panCat(String invoker, String dataset, String attribute, String category);
  void panRange(String invoker, String dataset, String attribute, String center);
  void panLike(String invoker, String dataset, String identifier, String relationship);
  void panLike(String invoker, String dataset, String[] coordinate, String relationship);

  // zoom changes size of window, leaving the center at the previous spot
  // TODO add a zoomOut / zoomIn API that allows jumping back to previous zoom
  void zoomItem(String invoker, String dataset, String numItems);
  void zoomVal(String invoker, String dataset, String leftVal, String rightVal);
  void zoomCat(String invoker, String dataset, String numCats);
  void zoomRange(String invoker, String dataset, String minVal, String maxVal);
  // width specified in data space
  void zoomRange(String invoker, String dataset, String width);
  void zoomLike(String invoker, String dataset, String numLikeItems);

  void setLOD(String invoker, String dataset, String levelOfDetail);

  ////////////////////
  // get selections
  ////////////////////

  String getHoverId(String dataset);
  String[] getHoverCoord(String dataset);
  String getHoverItem(String dataset, String attribute);
  String getHoverCat(String dataset, String attribute);
  String[] getHoverRange(String dataset, String attribute);
  // TODO how do we want this to work?  It returns the coordinate/relationship pair or just the relationship
  String[] getHoverLike(String dataset);

  String[] getSelectIds(String dataset, String selectType);
  String[][] getSelectCoords(String dataset, String selectType);
  String[] getSelectItems(String dataset, String attribute, String selectType);
  String[][] getSelectCats(String dataset, String attribute, String selectType);
  String[][] getSelectRanges(String dataset, String attribute, String selectType);
  String[][] getSelectLike(String dataset, String selectType);
  String[][][] getSelectCriteria(String dataset, String selectType);

  String[] getFilterIds(String dataset);
  String[][] getFilterCoords(String dataset);
  String[][] getFilterItems(String dataset, String attribute);
  String[][] getFilterCats(String dataset, String attribute);
  String[][] getFilterRanges(String dataset, String attribute);
  String[][] getFilterLike(String dataset);
  String[][][] getFilterCriteria(String dataset);

  // nav changes center of window and size of window
  String getNavCenterId(String dataset);
  String[] getNavCenterCoord(String dataset);
  String[] getNavIds(String dataset);
  String[][] getNavCoords(String dataset);
  String getNavNumItems(String dataset);
  String getNavItems(String dataset);
  String getNavCenterVal(String dataset, String attribute);
  String getNavLeftVal(String dataset, String attribute);
  String getNavRightVal(String dataset, String attribute);
  String getNavNumCats(String dataset, String attribute);
  String getNavMinVal(String dataset, String attribute);
  String getNavMaxVal(String dataset, String attribute);
  String getNavWidth(String dataset, String attribute);
  String getNavLike(String dataset);
  String getNavNumLike(String dataset);

  String getLOD(String dataset);

  ////////////////////
  // selection colors
  ////////////////////
  // TODO allow for rgba everywhere
  void setHoverColor(String[] rgbaColor);
  void setHoverColor(String dataset, String[] rgbaColor);
  void setSelectColor(String[] rgbaColor, String selectType);
  void setSelectColor(String dataset, String[] rgbaColor, String selectType);
  void setFilterColor(String[] rgbaColor);
  void setFilterColor(String dataset, String[] rgbaColor);
  void setLikeColor(String[] rgbaColor);
  void setLikeColor(String dataset, String[] rgbaColor);

  String[] getHoverColor(String dataset);
  String[] getSelectColor(String dataset, String selectType);
  String[] getFilterColor(String dataset);
  String[] getLikeColor(String dataset);
  // TODO figure out interface for setting other encodings (shape / size / etc).

 }

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

  // identifiers / coordinates
  void addId(String id);
  boolean hasId(String id);
  void addCoord(String[] coord);
  boolean hasCoord(String[] coord);

  String[] getAllIds(String attr);
  String[][] getAllCoords(String attr);
  String getHoverId();
  String[] getHoverCoord();
  String[] getSelectIds(String selectType);
  String[][] getSelectCoords(String selectType);
  String[] getFilterIds();
  String[][] getFilterCoords();
  String getNavCenterId();
  String getNavCenterCoord();
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
  String[] getFilterItems(String attr);
  Float[] getFilterItemsAsFloat(String attr);
  float[][] getFilterItemsAsFloatArray(String attr);
  String[][] getFilterItemsAsStringArray(String attr);

  String[] getItemColor(String colorByAttr, String id);
  String[] getItemColor(String colorByAttr, String[] coord);
  String[][] getAllItemColors(String colorByAttr);
  String[][] getFilterItemColors(String colorByAttr);
  String[] getItemEncoding(String encodingByAttr, String id);
  String[] getItemEncoding(String encodingByAttr, String[] coord);
  String[][] getItemEncodings(String encodingByAttr);

  void hoverItem(String invoker, String id);
  void hoverItem(String invoker, String[] coord);

  void selectItems(String invoker, String[] coords, String selectType);
  void deselectItems(String invoker, String[] coords, String selectType);
  void selectItems(String invoker, String[][] coords, String selectType);
  void deselectItems(String invoker, String[][] coords, String selectType);
  void navItem(String invoker, String id, String numItems);
  void navItem(String invoker, String[] coord, String numItems);
  void panItem(String invoker, String id);
  void panItem(String invoker, String[] coord);
  void zoomItem(String invoker, String numItems);

  String getHoverItem(String attr);
  String[] getSelectItems(String attr, String selectType);
  String[][] getFilterItems(String attr);
  String getNavNumItems();
  String getNavItems();


  // attributes
  void clearAttributes();
  void addAttr(DelvBasicAttribute attr);
  Boolean hasAttr(String attr);
  String[] getAttrs();
  String[] getAllCats(String attr);
  String[] getCatColor(String attr, String cat);
  String[][] getAllCatColors(String attr);
  String[][] getFilterCatColors(String attr);
  String[] getCatEncoding(String attr, String cat);
  String[][] getCatEncodings(String attr);

  void hoverCat(String invoker, String attr, String cat);
  void hoverRange(String invoker, String attr, String minVal, String maxVal);
  void selectCats(String invoker, String[] attrs, String[] cats, String selectType);
  void deselectCats(String invoker, String[] attrs, String[] cats, String selectType);
  void selectRanges(String invoker, String[] attrs, String[] mins, String[] maxes, String selectType);
  void deselectRanges(String invoker, String[] attrs, String[] mins, String[] maxes, String selectType);
  void filterCats(String invoker, String attr, String[] cats);
  void filterRanges(String invoker, String attr, String[] mins, String[] maxes);

  void mapColor(String invoker, String attr, String cat, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void mapEncoding(String invoker, String attr, String cat, String encoding);

  // following works for ordered categorical attribute
  void navVal(String invoker, String attr, String value, String leftVal, String rightVal);
  // following works for unordered categorical attribute
  void navCat(String invoker, String attr, String cat, String numCats);
  void navRange(String invoker, String attr, String center, String minVal, String maxVal);
  // width specified in data space
  void navRange(String invoker, String attr, String center, String width);

  void panCat(String invoker, String attr, String cat);
  void panRange(String invoker, String attr, String center);

  void zoomCat(String invoker, String numCats);
  void zoomRange(String invoker, String minVal, String maxVal);
  // width specified in data space
  void zoomRange(String invoker, String width);

  String getHoverCat(String attr);
  String[] getHoverRange(String attr);
  String[][] getSelectCats(String attr, String selectType);
  String[][] getSelectRanges(String attr, String selectType);
  String[][][] getSelectCriteria(String selectType);
  String[][] getFilterCats(String attr);
  String[][] getFilterRanges(String attr);
  String[][][] getFilterCriteria(String dataset);
  String getNavCenterVal(String attr);
  String getNavLeftVal(String attr);
  String getNavRightVal(String attr);
  String getNavNumCats(String attr);
  String getNavMinVal(String attr);
  String getNavMaxVal(String attr);
  String getNavWidth(String attr);

  // Relationships
  void hoverLike(String invoker, String id, String relationship);
  void hoverLike(String invoker, String[] coord, String relationship);
  void selectLike(String invoker, String[] coords, String[] relationships, String selectType);
  void deselectLike(String invoker, String[] coords, String[] relationships, String selectType);
  void selectLike(String invoker, String[][] coords, String[] relationships, String selectType);
  void deselectLike(String invoker, String[][] coords, String[] relationships, String selectType);
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String invoker, String selectType);

  void filterLike(String invoker, String[] coords, String[] relationships);
  void filterLike(String invoker, String[][] coords, String[] relationships);
  void clearFilter(String invoker);

  void navLike(String invoker, String id, String relationship, String numLikeItems);
  void navLike(String invoker, String[] coord, String relationship, String numLikeItems);
  void clearNav(String invoker);

  void panLike(String invoker, String id, String relationship);
  void panLike(String invoker, String[] coord, String relationship);

 void zoomLike(String invoker, String numLikeItems);

  void setLOD(String invoker, String levelOfDetail);

  // TODO how do we want this to work?  It returns the coordinate/relationship pair or just the relationship
  String[] getHoverLike();
  String[][] getSelectLike(String selectType);
  String[][] getFilterLike();
  String getNavLike();
  String getNavNumLike();
  String getLOD();

  // color
  void setHoverColor(String[] rgbaColor);
  void setSelectColor(String[] rgbaColor, String selectType);
  void setFilterColor(String[] rgbaColor);
  void setLikeColor(String[] rgbaColor);

  String[] getHoverColor();
  String[] getSelectColor(String selectType);
  String[] getFilterColor();
  String[] getLikeColor();

  // apply filters
  void applyFilters();

}

interface DelvAttribute {
  void clear();

  void setItem(String id, String item);
  void setFloatItem(String id, Float item);
  void setFloatArrayItem(String id, float[] item);
  void setStringArrayItem(String id, String[] item);

  String getItem(String id);
  Float getItemAsFloat(String id);
  float[] getItemAsFloatArray(String id);
  String[] getItemAsStringArray(String id);
  String[] getAllItems();
  Float[] getAllItemsAsFloat();
  float[][] getAllItemsAsFloatArray();
  String[][] getAllItemsAsStringArray();

  void removeId(String id);

  void updateHighlightedCategory(String cat);
  void updateHoveredCategory(String cat);
  String getHighlightedCategory();
  String getHoveredCategory();
  void toggleVisibility(String cat);
  String[] getAllCategories();
  String[] getVisibleCategories();
  String[] getCategoryColor(String cat);
  String[][] getAllCategoryColors();
  String[][] getVisibleCategoryColors();
  String[] getItemColor(String id);
  void setCategoryColor(String cat, String[] rgbColor);

  void updateVisibility(String item);
  boolean isItemVisible(String id);
}

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

public class DelvImpl implements Delv {
  HashMap<String, DelvData> dataIFs;
  HashMap<String, DelvView> views;
  HashMap< String, HashMap<String, String> > signalHandlers;

  public DelvImpl() {
    dataIFs = new HashMap<String, DelvData>();
    views = new HashMap<String, DelvView>();
    signalHandlers = new HashMap< String, HashMap<String, String> >();
  }

  public DelvImpl(DelvData dataInt) {
    dataIFs = new HashMap<String, DelvData>();
    dataIFs.put(dataInt.getName(), dataInt);
    views = new HashMap<String, DelvView>();
    signalHandlers = new HashMap< String, HashMap<String, String> >();
  }

  void log(String msg) {
    println(msg);
  }

  void emitEvent(String name, String detail) {
  }

  DelvData getDataIF(String dataSource) {
    return dataIFs.get(dataSource);
  }

  void addDataIF(DelvData dataInt) {
    dataIFs.put(dataInt.getName(), dataInt);
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
    if (signalHandlers.containsKey(signal)) {
      for (String key: signalHandlers.get(signal).keySet()) {
        // since we don't have entrySet yet, do the following instead:
        // view = views.get(entry.getKey());
        DelvView view = views.get(key);
        try {
          // since we don't have entrySet yet, do the following instead:
          //Method m = view.getClass().getMethod(entry.getValue(), params);
          Method m = view.getClass().getMethod(signalHandlers.get(signal).get(key), params);
          m.invoke(view, args);
        } catch (IllegalArgumentException e) {
          e.printStackTrace();
        } catch (IllegalAccessException e) {
          e.printStackTrace();
        } catch (InvocationTargetException e) {
          e.getTargetException().printStackTrace();
        } catch (NoSuchMethodException nsme) {
          System.err.println("There is no public " + signalHandlers.get(signal).get(key) + "() method " +
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
    if (signalHandlers.containsKey(signal)) {
      //for (Map.Entry<String, String> entry : signalHandlers.get(signal).entrySet()) {
      for (String key: signalHandlers.get(signal).keySet()) {
        // since we don't have entrySet yet, do the following instead:
        // view = views.get(entry.getKey());
        DelvView view = views.get(key);
        try {
          // since we don't have entrySet yet, do the following instead:
          //Method m = view.getClass().getMethod(entry.getValue(), params);
          Method m = view.getClass().getMethod(signalHandlers.get(signal).get(key), params);
          m.invoke(view, args);
        } catch (IllegalArgumentException e) {
          e.printStackTrace();
        } catch (IllegalAccessException e) {
          e.printStackTrace();
        } catch (InvocationTargetException e) {
          e.getTargetException().printStackTrace();
        } catch (NoSuchMethodException nsme) {
          System.err.println("There is no public " + signalHandlers.get(signal).get(key) + "() method " +
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
    if (!signalHandlers.containsKey(signal)) {
      signalHandlers.put(signal, new HashMap<String, String>());
    }
    signalHandlers.get(signal).put(name, method);
  }

  void disconnectFromSignal(String signal, String name) {
    log("Disconnecting " + signal + " from " + name);
    if (signalHandlers.containsKey(signal) && signalHandlers.get(signal).containsKey(name)) {
      signalHandlers.get(signal).remove(name);
    }
  }

  void addView(DelvView view, String name) {
    views.put(name, view);
  }

  void reloadData() {
    log("reloading data");
     for (DelvView view : views.values()) {
       view.reloadData("Delv");
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

}

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
  int _background_color;
  boolean _drawBox;
  String[] _ids;
  String _hoverId;
  String[] _selectIds;
  String _highlightId;
  String _colorCat;
  String _label;
  int _highlighted_idx;
  int _hovered_idx;
  int[] _selected_idx;
  Delv _delvIF;
  DelvData _dataIF;
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
    _background_color = color_(255);
    _drawBox = true;
    _ids = new String[0];
    _hoverId = "";
    _selectIds = new String[0];
    _highlightId = "";
    _colorCat = "";
    _highlighted_idx = -1;
    _hovered_idx = -1;
    _selected_idx = new int[0];
    _colorAttr = "";
  }
  public DelvBasicView() { this("BasicView", new int[2], 100, 100); }
  public DelvBasicView(String name) { this(name, new int[2], 100, 100); }

  public void bindDelv(Delv dlv) {
    _delvIF = dlv;
    connectSignals();
  }

  public DelvView dataIF(String dataIFName) {
    _dataIF = _delvIF.getDataIF(dataIFName);
    return this;
  }

  public String name() { return _name; }
  public DelvBasicView name(String name) {
    _name = name;
    return this;
  }

  public String datasetName() {
    return _datasetName;
  }
  public DelvBasicView datasetName(String name) {
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
    if (_delvIF == null) {
      return;
    }
    _delvIF.connectToSignal("highlightedIdChanged", _name, "onHighlightedIdChanged");
    _delvIF.connectToSignal("hoveredIdChanged", _name, "onHoveredIdChanged");
    _delvIF.connectToSignal("selectedIdsChanged", _name, "onSelectedIdsChanged");
  }

  void selectionChanged(String selection) {
    // see if need to add any other logic here
    // TODO distinguish between Item selection, Category selection, and Attribute selection
    String[] selections = new String[1];
    selections[0] = selection;
    _dataIF.updateSelectedIds(_name, _datasetName, selections);
  }
  // public void selectionChanged(String selection) {}
  public void colorChanged(String selection, color c) {}

  // TODO undo this hack for onDataUpdated
  void onDataUpdated(String invoker, String dataset, String attribute) {}
  void onDataUpdated(String invoker, String dataset, String[] attributes) {}

  void onHighlightedIdChanged(String invoker, String dataset, String id) {
    if (!invoker.equals(_name)) {
      if (dataset.equals(_datasetName)) {
        setHighlightedId(id);
        // TODO any redraw notification here?
      }
    }
  }
  void onHoveredIdChanged(String invoker, String dataset, String id) {
    if (!invoker.equals(_name)) {
      if (dataset.equals(_datasetName)) {
        setHoveredId(id);
      }
    }
  }

  void onSelectedIdsChanged(String invoker, String dataset, String[] identifiers) {
    if (!invoker.equals(_name)) {
      if (dataset.equals(_datasetName)) {
        setSelectedIds(identifiers);
      }
    }
  }

  void updateSelections() {
    // TODO handle selection updates
    // String[] selections;
    // selections = _dataIF.getSelectedIds(_datasetName);
    String id;
    id = _dataIF.getHighlightedId(_datasetName);
    setHighlightedId(id);
    id = _dataIF.getHoveredId(_datasetName);
    setHoveredId(id);
    // TODO handle color / color map updates
  }

  public void reloadData(String source) { updateSelections(); }

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
  public int getBackgroundColor() { return _background_color; }
  public DelvBasicView setBackgroundColor(int c) {
    _background_color = c;
    return this;
  }

  public void drawBox(boolean doDraw) {
    _drawBox = doDraw;
  }

  // * * * Get/Set the ids * * * //
  public String[] getIds() { return _ids; }
  public DelvBasicView setIds(String[] ids) {
    _ids = ids;
    idsUpdated();
    //redraw();
    return this;
  }
  public String getId(int idx) {
    return _ids[idx];
  }

  public void setHighlightedId(String id) {
    _highlighted_idx = -1;
    _highlightId = id;
    for ( int idx = 0; idx < _ids.length; idx++ ) {
      if (id.equals(_ids[idx])) {
        _highlighted_idx = idx;
        break;
      }
    }
    highlightedIdUpdated();
    //redraw();
  }
  public void setHoveredId(String id) {
    // TODO actually pick a better data structure and algorithm
    _hovered_idx = -1;
    _hoverId = id;
    for ( int idx = 0; idx < _ids.length; idx++ ) {
      if (id.equals(_ids[idx])) {
        _hovered_idx = idx;
        break;
      }
    }
    hoveredIdUpdated();
    //redraw();
  }
  public void setSelectedIds(String[] ids) {
    // TODO actually pick a better data structure and algorithm
    _selected_idx = new int[ids.length];
    _selectIds = ids;
    for ( int id = 0; id < ids.length; id++) {
      for ( int idx = 0; idx < _ids.length; idx++ ) {
        if (ids[id].equals(_ids[idx])) {
          _selected_idx[id] = idx;
          break;
        }
      }
    }
    selectedIdsUpdated();
    draw();
  }

  public void hoverOn(int id) {
    hoveredIdx(true, id, true);
  }
  public void hoverOn(int id, boolean doDraw) {
    hoveredIdx(true, id, doDraw);
  }
  public void hoverOff() {
    hoveredIdx(false,-1,true);
  }
  public void hoverOff(boolean doDraw) {
    hoveredIdx(false, -1, doDraw);
  }
  public void highlightOn(int id) {
    highlightedIdx(true, id, true);
  }
  public void highlightOn(int id, boolean doDraw) {
    highlightedIdx(true, id, doDraw);
  }
  public void highlightOff() {
    highlightedIdx(false,-1,true);
  }
  public void highlightOff(boolean doDraw) {
    highlightedIdx(false, -1, doDraw);
  }

  public void renderBox() {
    // Render the box around the view
    noStroke();
    fill( _background_color );
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
  public void movieEvent(MovieIF m) {}
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
  public void idsUpdated() {}
  public void highlightedIdUpdated() {}
  public void hoveredIdUpdated() {}
  public void selectedIdsUpdated() {}

  // To work in javascript as well, cannot have method overloading!! Pick different names!
  public void hoveredId(String id) {
    hoveredId(id, true);
  }
  public void hoveredId(String id, boolean doDraw) {
    if (!(id.equals(_hoverId))) {
      _hoverId = id;
      _dataIF.updateHoveredId(_name, _datasetName, id);
      if (doDraw) {
        //redraw();
      }
    }
  }
  public void hoveredIdx(boolean isHovered, int id) {
    hoveredIdx(isHovered, id, true);
  }
  public void hoveredIdx(boolean isHovered, int id, boolean doDraw) {
    if (isHovered) {
      hoveredId(getId(id), doDraw);
    } else {
      hoveredId("", doDraw);
    }
  }

  // public void selectedId(String id) {
  //   selectedId(id, true);
  // }
  // public void selectedId(String id, boolean doDraw) {
  //   // TODO decide whether selectionChanged should only be issued for different
  //   // selections vs repeats of the same.
  //   // if (!(id.equals(_selectId))) {
  //   _selectId = id;
  //   // TODO distinguish between Item selection, Category selection, and Attribute selection
  //   String[] selections = new String[1];
  //   selections[0] = id;
  //   _dataIF.updateSelectedIds(_name, _datasetName, selections);
  //   if (doDraw) {
  //     draw();
  //   }
  //   // }
  // }
  // public void selectedIdx(boolean isSelected, int id) {
  //   selectedIdx(isSelected, id, true);
  // }
  // public void selectedIdx(boolean isSelected, int id, boolean doDraw) {
  //   if (isSelected) {
  //     selectedId(getId(id), doDraw);
  //   } else {
  //     selectedId("", doDraw);
  //   }
  // }


  public void highlightedId(String id) {
    highlightedId(id, true);
  }
  public void highlightedId(String id, boolean doDraw) {
    if (!(id.equals(_highlightId))) {
      _highlightId = id;
      _dataIF.updateHighlightedId(_name, _datasetName, id);
      if (doDraw) {
        //redraw();
      }
    }
  }
  public void highlightedIdx(boolean isHighlighted, int id) {
    highlightedIdx(isHighlighted, id, true);
  }
  public void highlightedIdx(boolean isHighlighted, int id, boolean doDraw) {
    if (isHighlighted) {
      highlightedId(getId(id), doDraw);
    } else {
      highlightedId("", doDraw);
    }
  }

  public void coloredCat(String cat, color c) {
    coloredCat(cat, c, true);
  }
  public void coloredCat(String cat, color c, boolean doDraw) {
    if (!(cat.equals(_colorCat))) {
      _colorCat = cat;
      // TODO, how do we know when to updateCategoryColor
      // vs when to update item color or range color?
      // ANSWER (keep track of this for write-up): item colors will never be changed directly, so only ever updating categories or ranges.  So create two interfaces
      // coloredCat for updating categoryColor, and coloredRange for updating a continuous range w/ color.
      // NOTE: May also want to add a highlightColor, hoverColor, selectionColor
      // to the dataIF and have a way to update and get these colors.  Make these colors also part of the base view class.
      String[] colorStr = new String[3];
      colorStr[0] = "" + red_(c);
      colorStr[1] = "" + green_(c);
      colorStr[2] = "" + blue_(c);
      _dataIF.updateCategoryColor(_name, _datasetName, _colorAttr, _colorCat, colorStr);
      if (doDraw) {
        //redraw();
      }
    }
  }

  // public void coloredIdx(int id, color c) {
  //   coloredIdx(id, c, true);
  // }
  // public void coloredIdx(int id, color c, boolean doDraw) {
  //   coloredId(getId(id), c, doDraw);
  // }

}

class DelvCompositeView extends DelvBasicView {
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
      dlv.addView(view, view.name());
      view.bindDelv(dlv);
    }
    _delvIF = dlv;
  }

  public DelvBasicView dataIF(String dataIFName) {
    for (DelvBasicView view: _views) {
      view.dataIF(dataIFName);
    }
    _dataIF = _delvIF.getDataIF(dataIFName);
    return this;
  }

  public DelvBasicView datasetName(String name) {
    _datasetName = name;
    for (DelvBasicView view: _views) {
      view.datasetName(name);
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

  public void reloadData(String source) {
    for (DelvBasicView view: _views) {
      view.reloadData(source);
    }
    super.reloadData(source);
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

  public void movieEvent(MovieIF m) {
    for (DelvBasicView view : _views) {
      view.movieEvent(m);
    }
    super.movieEvent(m);
  }

} // end class DelvCompositeView

// DelvCategoryView
// A view that can render the categories for
// one dimension of data.  It converts category selections into
// data filtering messages (category visibility).  For
// other behaviors of a category view, implement a different base view.
// Since it inherits from DelvBasicView, it also
// has access to the colorAttr

public class DelvCategoryView extends DelvBasicView {
  String _cat1Attr;
  String[] _cat1;
  String[] _visibleCat1;
  color[] _cat1Colors;
  color[] _visibleCat1Colors;
  String _selectCat;
  String _hoverCat;
  String _highlightCat;
  boolean _doSort;

  public DelvCategoryView() {
    this("DelvCategory");
  }

  public DelvCategoryView(String name) {
    super(name);
    _cat1 = new String[0];
    _visibleCat1 = new String[0];
    _visibleCat1Colors = new color[0];
    _selectCat = "";
    _hoverCat = "";
    _highlightCat = "";
    _doSort = true;
  }

  public DelvCategoryView doSort(boolean sort) {
    _doSort = sort;
    return this;
  }

  public String cat1Attr() {
    return _cat1Attr;
  }
  public DelvCategoryView cat1Attr(String attr) {
    _cat1Attr = attr;
    return this;
  }

  public void setCat1(String[] cats) {
    _cat1 = cats;
    cat1Updated();
  }
  public void setVisibleCat1(String[] cats) {
    _visibleCat1 = cats;
    visibleCat1Updated();
  }

  public void reloadData(String source) {
    if (_delvIF == null) {
      return;
    }

    if (!source.equals(_name)) {
      String[] cats;
      cats = _dataIF.getAllCategories(_datasetName, _cat1Attr);
      if (_doSort) {
        cats = sort(cats);
      }
      setCat1(cats);
      updateVisibility();
    }
    super.reloadData(source);
  }

  public void updateVisibility() {
    String[] selections;
    selections = _dataIF.getVisibleCategories(_datasetName, _cat1Attr);
    if (_doSort) {
      selections = sort(selections);
    }
    setVisibleCat1(selections);
    updateColors();
  }

  public void updateColors() {
    // assumes that all categories and visible categories have been set already
    if (!_colorAttr.equals("")) {
      _cat1Colors = new color[_cat1.length];
      String[] colorStr = new String[0];
      for (int i = 0; i < _cat1.length; i++) {
        colorStr = _dataIF.getCategoryColor(_datasetName, _colorAttr, _cat1[i]);
        color c = color_(int(colorStr[0]), int(colorStr[1]), int(colorStr[2]));
        _cat1Colors[i] = c;
      }
      cat1ColorsUpdated();

      _visibleCat1Colors = new color[_visibleCat1.length];
      for (int i = 0; i < _visibleCat1.length; i++) {
        colorStr = _dataIF.getCategoryColor(_datasetName, _colorAttr, _visibleCat1[i]);
        color c = color_(int(colorStr[0]), int(colorStr[1]), int(colorStr[2]));
        _visibleCat1Colors[i] = c;
      }
      visibleCat1ColorsUpdated();
    }
  }

  public void connectSignals() {
    if (_delvIF == null) {
      return;
    }

    _delvIF.connectToSignal("categoryVisibilityChanged", _name, "onCategoryVisibilityChanged");
    _delvIF.connectToSignal("hoveredCategoryChanged", _name, "onHoveredCategoryChanged");
    _delvIF.connectToSignal("hoveredIdChanged", _name, "onHoveredIdChanged");
    _delvIF.connectToSignal("highlightedCategoryChanged", _name, "onHighlightedCategoryChanged");
    _delvIF.connectToSignal("categoryColorsChanged", _name, "onCategoryColorsChanged");
  }

 public void onCategoryVisibilityChanged(String invoker, String dataset, String attribute) {
    if (invoker.equals(_name)) {
      _delvIF.log(_name + ".onCategoryVisibilityChanged(" + dataset + ", " + attribute + ") triggered by self");
    } else {
      _delvIF.log(_name + ".onCategoryVisibilityChanged(" + dataset + ", " + attribute + ") triggered by " + invoker);
      if ((dataset.equals(_datasetName)) && (attribute.equals(_cat1Attr))) {
        updateVisibility();
      }
    }
  }
  public void onHoveredIdChanged(String invoker, String dataset, String identifier) {
    if (invoker.equals(_name)) {
      _delvIF.log(_name+".onHoveredIdChanged(" + dataset + ", " + identifier + ") triggered by self");
    } else {
      _delvIF.log(_name+".onHoveredIdChanged(" + dataset + ", " + identifier + ") triggered by " + invoker);
      if (dataset.equals(_datasetName)) {
        _hoverCat = _dataIF.getItem(_datasetName, _cat1Attr, identifier);
        hoveredCatUpdated();
      }
    }
  }
  public void onHoveredCategoryChanged(String invoker, String dataset, String attribute) {
    if (invoker.equals(_name)) {
      _delvIF.log(_name+".onHoveredCategoryChanged(" + dataset + ", " + attribute + ") triggered by self");
    } else {
      _delvIF.log(_name+".onHoveredCategoryChanged(" + dataset + ", " + attribute + ") triggered by " + invoker);
      if (dataset.equals(_datasetName) && attribute.equals(_cat1Attr)) {
        _hoverCat = _dataIF.getHoveredCategory(_datasetName, _cat1Attr);
        hoveredCatUpdated();
      }
    }
  }
  public void onHighlightedCategoryChanged(String invoker, String dataset, String attribute) {
    if (invoker.equals(_name)) {
      _delvIF.log(_name + ".onHighlightedCategoryChanged(" + dataset + ", " + attribute + ") triggered by self");
    } else {
      _delvIF.log(_name + ".onHighlightedCategoryChanged(" + dataset + ", " + attribute + ") triggered by " + invoker);
      if (dataset.equals(_datasetName) && attribute.equals(_cat1Attr)) {
        _highlightCat = _dataIF.getHighlightedCategory(_datasetName, _cat1Attr);
        highlightedCatUpdated();
      }
    }
  }

  public void onCategoryColorsChanged(String invoker, String dataset, String attribute) {
    if (!invoker.equals(_name) &&
        dataset.equals(_datasetName) &&
        attribute.equals(_cat1Attr)) {
          updateColors();
    }
  }


  public void selectedCat(String cat) {
    selectedCat(cat, true);
  }
  public void selectedCat(String cat, boolean doDraw) {
    // TODO decide whether selectionChanged should only be issued for different
    // selections vs repeats of the same.
    // if (!(cat.equals(_selectCat))) {
    _selectCat = cat;
    // TODO distinguish between Item selection, Category selection, and Attribute selection
    // TODO can category selection mean something else besides visibility?
    _dataIF.updateCategoryVisibility(_name, _datasetName, _cat1Attr, cat);
    if (doDraw) {
      //redraw();
    }
    // }
  }

  public void hoveredCat(String cat) {
    hoveredCat(cat, true);
  }
  public void hoveredCat(String cat, boolean doDraw) {
    if (!(cat.equals(_hoverCat))) {
      _hoverCat = cat;
      _dataIF.updateHoveredCategory(_name, _datasetName, _cat1Attr, cat);
      if (doDraw) {
        draw();
      }
    }
  }

  public void highlightedCat(String cat) {
    highlightedCat(cat, true);
  }
  public void highlightedCat(String cat, boolean doDraw) {
    if (!(cat.equals(_highlightCat))) {
      _highlightCat = cat;
      _dataIF.updateHighlightedCategory(_name, _datasetName, _cat1Attr, cat);
      if (doDraw) {
        draw();
      }
    }
  }

  // override these if you need to do a one-time calculation when these events happen
  public void cat1Updated() {}
  public void visibleCat1Updated() {}
  public void hoveredCatUpdated() {}
  public void highlightedCatUpdated() {}
  public void cat1ColorsUpdated() {}
  public void visibleCat1ColorsUpdated() {}

} // end DelvCategoryView

// Delv1DView
// A view that can render one dimension of data
// Since it inherits from DelvBasicView, it also
// has access to the colorAttr

class Delv1DView extends DelvBasicView {
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

  void reloadData(String source) {
    if (_delvIF == null) {
      return;
    }

    if (!source.equals(_name)) {
      String[] data;
      // TODO need to get Visible Items or Filtered Items or something else
      data = _dataIF.getAllItems(_datasetName, _dim1Attr);
      setDim1(data);
      String[] ids;
      ids = _dataIF.getAllIds(_datasetName, _dim1Attr);
      setIds(ids);
    }
    super.reloadData(source);
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

  void reloadData(String source) {
    if (_delvIF == null) {
      return;
    }

    if (!source.equals(_name)) {
      String[] data;
      // TODO need to get Visible Items or Filtered Items or something else
      data = _dataIF.getAllItems(_datasetName, _dim2Attr);
      setDim2(data);
    }
    super.reloadData(source);
  }

  void dim2Updated() {}

} // end Delv2DView

// Some classes to support implementation of DelvBasicData
import java.util.TreeMap;

class DelvItemId {
  // want these all to be public
  String name;
  boolean visible;
  boolean selected;

  DelvItemId(String id) {
    name = id;
    visible = true;
    selected = false;
  }

  void toggleVisibility() {
    visible = !visible;
  }

  void toggleSelection() {
    selected = !selected;
  }

} // end class DelvItemId

interface DelvRange {}

class DelvCategoricalRange implements DelvRange {
  ArrayList<String> _categories;
  HashMap<String, Boolean> _visible;

  DelvCategoricalRange() {
    // keeping this separate because _categories needs to be in the correct sorted order
    // (or does it, not sure this is true).
    // ( TODO maybe a sorted hash map would be better?)
    _categories = new ArrayList<String>();
    _visible = new HashMap<String, Boolean>();
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
    _visible.put(cat, true);
  }

  // void setCategories(String[] cats) { }
  String[] getCategories() {
    return _categories.toArray(new String[_categories.size()]);
  }

  String[] getVisibleCategories() {
    ArrayList<String> vis = new ArrayList<String>();
    for (String cat : _categories) {
      if (_visible.get(cat)) {
        vis.add(cat);
      }
    }
    return vis.toArray(new String[vis.size()]);
  }

  String[] getInvisibleCategories() {
    ArrayList<String> vis = new ArrayList<String>();
    for (String cat : _categories) {
      if (!_visible.get(cat)) {
        vis.add(cat);
      }
    }
    return vis.toArray(new String[vis.size()]);
  }

  void toggleVisibility(String cat) {
    _visible.put(cat, !_visible.get(cat));
  }

  boolean isCategoryVisible(String cat) {
    return _visible.get(cat);
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
  public static final String[] _types = new String[] { "UNSTRUCTURED", "CATEGORICAL", "CATEGORICAL_LIST", "CONTINUOUS", "FLOAT_ARRAY" };
    public static final AttributeType UNSTRUCTURED = new AttributeType(_types[0]);
    public static final AttributeType CATEGORICAL = new AttributeType(_types[1]);
    public static final AttributeType CATEGORICAL_LIST = new AttributeType(_types[2]);
    public static final AttributeType CONTINUOUS = new AttributeType(_types[3]);
    public static final AttributeType FLOAT_ARRAY = new AttributeType(_types[4]);

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

class DelvBasicAttribute implements DelvAttribute {
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
  // TODO range
  DelvRange _fullRange;
  DelvRange _visibleRange;
  String _highlightCategory;
  String _hoverCategory;

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
    _visibleRange = data_range;
    _highlightCategory = "";
    _hoverCategory = "";
  }

  void clear() {
    _items = new HashMap<String, String>((int)Math.ceil(100000/.75));
    _floatArrayMap = new HashMap<String, Integer>((int)Math.ceil(100000/.75));
    _floatArrayItems = new float[0][];
    _stringArrayItems = new HashMap<String, String[]>();
    _floatItems = new HashMap<String, Float>((int)Math.ceil(100000/.75));
  }

  void setItem(String id, String item) {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      _items.put(id, item);
      ((DelvCategoricalRange)_fullRange).addCategory(item);
      ((DelvCategoricalRange)_visibleRange).addCategory(item);
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
  void setFloatItem(String id, Float item) {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      _floatItems.put(id, item);
      ((DelvContinuousRange)_fullRange).update(item);
    }
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

  void setStringArrayItem(String id, String[] item) {
    if (_type.equals(AttributeType.CATEGORICAL_LIST)) {
      _stringArrayItems.put(id, item);
      for (int ii = 0; ii < item.length; ii++) {
        ((DelvCategoricalRange)_fullRange).addCategory(item[ii]);
        ((DelvCategoricalRange)_visibleRange).addCategory(item[ii]);
      }
    }
  }

  // String[] getAllIdsAndItems(String id) { }

  String getItem(String id) {
    if (_items.containsKey(id)) {
      return "" + _items.get(id);
    } else if (_floatItems.containsKey(id)) {
      return "" + _floatItems.get(id);
    } else {
      return "";
    }
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

  void removeId(String id) {
    // TODO need error handling here if id is not found in the map
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

  void updateHighlightedCategory(String cat) {
    _highlightCategory = cat;
  }

  void updateHoveredCategory(String cat) {
    _hoverCategory = cat;
  }

  String getHighlightedCategory() {
    return _highlightCategory;
  }

  String getHoveredCategory() {
    return _hoverCategory;
  }

  void toggleVisibility(String cat) {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      ((DelvCategoricalRange)_visibleRange).toggleVisibility(cat);
    }
  }

  String[] getAllCategories() {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      return ((DelvCategoricalRange)_fullRange).getCategories();
    } else {
      return new String[0];
    }
  }

  String[] getVisibleCategories() {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      return ((DelvCategoricalRange)_visibleRange).getVisibleCategories();
    } else {
      return new String[0];
    }
  }

  String[] getCategoryColor(String cat) {
    String[] colorStr = new String[3];
    color c = _colorMap.getColor(cat);
    colorStr[0] = "" + red_(c);
    colorStr[1] = "" + green_(c);
    colorStr[2] = "" + blue_(c);
    return colorStr;
  }

  String[][] getAllCategoryColors() {
    String[] cats = getAllCategories();
    String[][] colors = new String[cats.length][];
    for (int i = 0; i < cats.length; i++) {
      colors[i] = getCategoryColor(cats[i]);
    }
    return colors;
  }

  String[][] getVisibleCategoryColors() {
    String[] cats = getVisibleCategories();
    String[][] colors = new String[cats.length][];
    for (int i = 0; i < cats.length; i++) {
      colors[i] = getCategoryColor(cats[i]);
    }
    return colors;
  }

  String[] getItemColor(String id) {
    color c = _colorMap.getColor(getItem(id));

    String[] colorStr = new String[3];
    colorStr[0] = "" + red_(c);
    colorStr[1] = "" + green_(c);
    colorStr[2] = "" + blue_(c);
    return colorStr;
  }

  void setCategoryColor(String cat, String[] rgbColor) {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      _colorMap.setColor(cat, color_(parseInt(rgbColor[0]), parseInt(rgbColor[1]), parseInt(rgbColor[2])));
    }
  }

  void updateVisibility(String item) {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      ((DelvContinuousRange)_visibleRange).update(parseFloat(item));
    }
  }

  // DelvRange getVisibleRange() {
  //   if (_type.equals(AttributeType.CONTINUOUS)) {
  //     return _visibleRange;
  //   }
  // }

  // void setVisibleRange(DelvRange vrange) {
  //   if (_type.equals(AttributeType.CONTINUOUS)) {
  //     _visibleRange = vrange;
  //   }
  // }

  boolean isItemVisible(String id) {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      return ((DelvCategoricalRange)_visibleRange).isCategoryVisible(_items.get(id));
    } else if (_type.equals(AttributeType.CONTINUOUS)) {
      return ((DelvContinuousRange)_visibleRange).isInRange(_floatItems.get(id));
    } else {
      // TODO fix this, UNSTRUCTURED data is always visible for now
      return true;
    }
  }


} // end class DelvBasicAttribute

// Works well for large number of attributes where only a few are displayed at a time
// and relatively low number of items (large d, small n where n a few thousand or less)
class DelvBasicDataSet implements DelvDataSet {
  String _name;
  ArrayList<DelvItemId> _itemIds;
  HashMap<String, Integer> _itemIdHash;
  HashMap<String, DelvBasicAttribute> _attributes;
  String _highlightId;
  String _hoverId;

  DelvBasicDataSet(String name) {
    _name = name;
    _itemIds = new ArrayList<DelvItemId>();
    _itemIdHash = new HashMap<String, Integer>();
    _attributes = new HashMap<String, DelvBasicAttribute>();
    _highlightId = "";
    _hoverId = "";
  }

  void clearItems() {
    // TODO switch to entrySet once working in Processing
    for (String attr : _attributes.keySet()) {
      _attributes.get(attr).clear();
    }
    _itemIds = new ArrayList<DelvItemId>();
    _itemIdHash = new HashMap<String, Integer>();
  }

  void clearAttributes() {
    _attributes = new HashMap<String, DelvBasicAttribute>();
  }

  void addId(String id) {
    DelvItemId newId = new DelvItemId(id);
    _itemIdHash.put(id, _itemIds.size());
    _itemIds.add(newId);
  }

  boolean hasId(String id) {
    return (_itemIdHash.get(id) != null);
  }

  String[] getSelectedIds() {
    ArrayList<String> selected = new ArrayList<String>();
    for (DelvItemId id : _itemIds) {
      if (id.selected) {
        selected.add(id.name);
      }
    }
    return selected.toArray(new String[selected.size()]);
  }

  String[] getVisibleIds() {
    ArrayList<String> visible = new ArrayList<String>();
    for (DelvItemId id : _itemIds) {
      if (id.visible) {
        visible.add(id.name);
      }
    }
    return visible.toArray(new String[visible.size()]);
  }

  String getHighlightedId() {
    return _highlightId;
  }
  String getHoveredId() {
    return _hoverId;
  }

  int getNumIds() {
    return _itemIds.size();
  }

  String getNextId() {
    return "" + _itemIds.size();
  }

  void removeId(String id) {
    // TODO switch to entrySet once working in Processing
    for (String attr : _attributes.keySet()) {
      _attributes.get(attr).removeId(id);
    }
    // TODO not sure that this remove works from itemIds
    _itemIds.remove(id);
    _itemIdHash.remove(id);
  }

  void setItem(String attr, String id, String item) {
    if (!hasId(id)) {
      addId(id);
    }
    _attributes.get(attr).setItem(id, item);
  }
  void setFloatItem(String attr, String id, Float item) {
    if (!hasId(id)) {
      addId(id);
    }
    _attributes.get(attr).setFloatItem(id, item);
  }
  void setFloatArrayItem(String attr, String id, float[] item) {
    if (!hasId(id)) {
      addId(id);
    }
    _attributes.get(attr).setFloatArrayItem(id, item);
  }
  void setStringArrayItem(String attr, String id, String[] item) {
    if (!hasId(id)) {
      addId(id);
    }
    _attributes.get(attr).setStringArrayItem(id, item);
  }
  void addAttribute(DelvBasicAttribute attr) {
    _attributes.put(attr._name, attr);
  }

  Boolean hasAttribute(String attr) {
    return _attributes.containsKey(attr);
  }

  String[] getAttributes() {
    return _attributes.keySet().toArray(new String[0]);
  }

  String[] getAllCategories(String attr) {
   return _attributes.get(attr).getAllCategories();
  }

  String[] getVisibleCategories(String attr) {
    return _attributes.get(attr).getVisibleCategories();
  }

  String[] getCategoryColor(String attr, String cat) {
    return _attributes.get(attr).getCategoryColor(cat);
  }

  String[][] getAllCategoryColors(String attr) {
    return _attributes.get(attr).getAllCategoryColors();
  }

  String[][] getVisibleCategoryColors(String attr) {
    return _attributes.get(attr).getVisibleCategoryColors();
  }

  String[] getItemColor(String attr, String id) {
    return _attributes.get(attr).getItemColor(id);
  }

  String[][] getAllItemColors(String attr) {
    int numItems = _itemIds.size();
    String[][] colors = new String[numItems][];
    for (int i = 0; i < numItems; i++) {
      colors[i] = _attributes.get(attr).getItemColor(_itemIds.get(i).name);
    }
    return colors;
  }

  String getHighlightedCategory(String attr) {
    return _attributes.get(attr).getHighlightedCategory();
  }
  String getHoveredCategory(String attr) {
    return _attributes.get(attr).getHoveredCategory();
  }

  String[] getAllItems(String attr) {
    int numItems = _itemIds.size();
    String[] items = new String[numItems];
    for (int i = 0; i < numItems; i++) {
      items[i] = _attributes.get(attr).getItem(_itemIds.get(i).name);
    }
    return items;
  }
  Float[] getAllItemsAsFloat(String attr) {
    int numItems = _itemIds.size();
    Float[] items = new Float[numItems];
    for (int i = 0; i < numItems; i++) {
      items[i] = _attributes.get(attr).getItemAsFloat(_itemIds.get(i).name);
    }
    return items;
  }
  float[][] getAllItemsAsFloatArray(String attr) {
    int numItems = _itemIds.size();
    float[][] items = new float[numItems][];
    for (int i = 0; i < numItems; i++) {
      items[i] = _attributes.get(attr).getItemAsFloatArray(_itemIds.get(i).name);
    }
    return items;
  }
  String[][] getAllItemsAsStringArray(String attr) {
    int numItems = _itemIds.size();
    String[][] items = new String[numItems][];
    for (int i = 0; i < numItems; i++) {
      items[i] = _attributes.get(attr).getItemAsStringArray(_itemIds.get(i).name);
    }
    return items;
  }

  String getItem(String attr, String id) {
    String item = "";
    try {
      item = _attributes.get(attr).getItem(id);
    } catch (NullPointerException e) {
      //_delvIF.log("Caught exception trying to get item " + id + " from attribute " + attr + " for dataset " + _name);
      e.printStackTrace();
    }
    return item;
    //return _attributes.get(attr).getItem(id);
  }
  Float getItemAsFloat(String attr, String id) {
    return _attributes.get(attr).getItemAsFloat(id);
  }
  float[] getItemAsFloatArray(String attr, String id) {
    return _attributes.get(attr).getItemAsFloatArray(id);
  }
  String[] getItemAsStringArray(String attr, String id) {
    return _attributes.get(attr).getItemAsStringArray(id);
  }

  String[] getAllIds(String attr) {
    String[] ids = new String[_itemIds.size()];
    for (int i = 0; i < _itemIds.size(); i++) {
      ids[i] = _itemIds.get(i).name;
    }
    return ids;
  }

  // String[] getAllItemsAndIds(String attr) {
  //   return _attributes.get(attr).getAllIdsAndItems();
  // }

  void updateCategoryVisibility(String attr, String cat) {
    _attributes.get(attr).toggleVisibility(cat);
    determineItemVisibility();
  }

  void updateCategoryColor(String attr, String cat, String[] rgbColor) {
    _attributes.get(attr).setCategoryColor(cat, rgbColor);
  }

  void updateHighlightedCategory(String attr, String cat) {
    _attributes.get(attr).updateHighlightedCategory(cat);
  }

  void updateHoveredCategory(String attr, String cat) {
    _attributes.get(attr).updateHoveredCategory(cat);
  }



  void determineItemVisibility() {
    for (DelvItemId id : _itemIds) {
      id.visible = true;
      for (DelvBasicAttribute attr : _attributes.values()) {
        if (!attr.isItemVisible(id.name)) {
          id.visible = false;
          break;
        }
      }
    }
  }

  void updateSelectedIds(String[] ids) {
    for (DelvItemId id : _itemIds) {
      id.selected = false;
      for (int i = 0; i < ids.length; i++) {
        if (id.name.equals(ids[i])) {
          id.selected = true;
          break;
        }
      }
    }
  }

  void updateHighlightedId(String id) {
    _highlightId = id;
  }

  void updateHoveredId(String id) {
    _hoverId = id;
  }

  

} // end class DelvBasicDataSet

public class DelvBasicData implements DelvData {
  String _name;
  Delv _delvIF;
  HashMap <String, DelvBasicDataSet> _data;

  public DelvBasicData() {
    _name = "BasicData";
    _data = new HashMap<String, DelvBasicDataSet>();
  }
  public DelvBasicData(String name) {
    _name = name;
    _data = new HashMap<String, DelvBasicDataSet>();
  }

  public void setName(String name) {
    _name = name;
  }
  public String getName() {
    return _name;
  }

  // TODO should data interface and delv interface be so tightly coupled? (each with a reference to the other?)
  public void setDelvIF(Delv dlv) {
    _delvIF = dlv;
  }
  public void updateCategoryVisibility(String invoker, String dataset, String attribute, String category) {
    _data.get(dataset).updateCategoryVisibility(attribute, category);
    _delvIF.emitSignal("categoryVisibilityChanged",invoker, dataset, attribute);
  }
  public void updateCategoryColor(String invoker, String dataset, String attribute, String category, String[] rgbColor) {
    _data.get(dataset).updateCategoryColor(attribute, category, rgbColor);
    _delvIF.emitSignal("categoryColorsChanged", invoker, dataset, attribute);
  }
  public void updateHighlightedCategory(String invoker, String dataset, String attribute, String category) {
    _data.get(dataset).updateHighlightedCategory(attribute, category);
    _delvIF.emitSignal("highlightedCategoryChanged",invoker, dataset, attribute);
  }
  public void updateHoveredCategory(String invoker, String dataset, String attribute, String category) {
    _data.get(dataset).updateHoveredCategory(attribute, category);
    _delvIF.emitSignal("hoveredCategoryChanged",invoker, dataset, attribute);
  }
  public void updateHighlightedId(String invoker, String dataset, String id) {
    _data.get(dataset).updateHighlightedId(id);
    _delvIF.emitSignal("highlightedIdChanged",invoker, dataset, id);
  }
  public void updateHoveredId(String invoker, String dataset, String id) {
    _data.get(dataset).updateHoveredId(id);
    _delvIF.emitSignal("hoveredIdChanged",invoker, dataset, id);
  }
  public void updateSelectedIds(String invoker, String dataset, String[] ids) {
    _data.get(dataset).updateSelectedIds(ids);
    _delvIF.emitSignal("selectedIdsChanged",invoker, dataset, ids);
  }

  public void clearItems(String dataset) {
    _data.get(dataset).clearItems();
  }

  public void setItem(String dataset, String attribute, String identifier, String item) {
    _data.get(dataset).setItem(attribute, identifier, item);
  }
  public void setFloatItem(String dataset, String attribute, String identifier, Float item) {
    _data.get(dataset).setFloatItem(attribute, identifier, item);
  }
  public void setFloatArrayItem(String dataset, String attribute, String identifier, float[] item) {
    _data.get(dataset).setFloatArrayItem(attribute, identifier, item);
  }
  public void setStringArrayItem(String dataset, String attribute, String identifier, String[] item) {
    _data.get(dataset).setStringArrayItem(attribute, identifier, item);
  }

  public Boolean hasAttribute(String dataset, String attribute) {
    return _data.get(dataset).hasAttribute(attribute);
  }

  public String[] getAttributes(String dataset) {
    return _data.get(dataset).getAttributes();
  }

  public String[] getVisibleCategories(String dataset, String attribute) {
    return _data.get(dataset).getVisibleCategories(attribute);
  }

  public String[] getAllCategories(String dataset, String attribute) {
    return _data.get(dataset).getAllCategories(attribute);
  }

  public String[] getCategoryColor(String dataset, String attribute, String category) {
    return _data.get(dataset).getCategoryColor(attribute, category);
  }

  public String[][] getAllCategoryColors(String dataset, String attribute) {
    return _data.get(dataset).getAllCategoryColors(attribute);
  }
  public String[][] getVisibleCategoryColors(String dataset, String attribute) {
    return _data.get(dataset).getVisibleCategoryColors(attribute);
  }
  public String[] getItemColor(String dataset, String attribute, String identifier) {
    return _data.get(dataset).getItemColor(attribute, identifier);
  }
  public String[][] getAllItemColors(String dataset, String attribute) {
    return _data.get(dataset).getAllItemColors(attribute);
  }
  
  public String[] getAllItems(String dataset, String attribute) {
    return _data.get(dataset).getAllItems(attribute);
  }
  public Float[] getAllItemsAsFloat(String dataset, String attribute) {
    return _data.get(dataset).getAllItemsAsFloat(attribute);
  }
  public float[][] getAllItemsAsFloatArray(String dataset, String attribute) {
    return _data.get(dataset).getAllItemsAsFloatArray(attribute);
  }
  public String[][] getAllItemsAsStringArray(String dataset, String attribute) {
    return _data.get(dataset).getAllItemsAsStringArray(attribute);
  }

  public String[] getAllIds(String dataset, String attribute) {
    return _data.get(dataset).getAllIds(attribute);
  }

  public String getItem(String dataset, String attribute, String identifier) {
    return _data.get(dataset).getItem(attribute, identifier);
  }
  public Float getItemAsFloat(String dataset, String attribute, String identifier) {
    return _data.get(dataset).getItemAsFloat(attribute, identifier);
  }
  public float[] getItemAsFloatArray(String dataset, String attribute, String identifier) {
    return _data.get(dataset).getItemAsFloatArray(attribute, identifier);
  }
  public String[] getItemAsStringArray(String dataset, String attribute, String identifier) {
    return _data.get(dataset).getItemAsStringArray(attribute, identifier);
  }
  
  // TODO put these null checks in for all gets of datasets
  public String getHighlightedId(String dataset) {
    DelvBasicDataSet ds = _data.get(dataset);
    if (null == ds) {
      return "";
    } else {
      return ds.getHighlightedId();
    }
  }

  public String getHoveredId(String dataset) {
    DelvBasicDataSet ds = _data.get(dataset);
    if (null == ds) {
      return "";
    } else {
      return ds.getHoveredId();
    }
  }

  public String getHighlightedCategory(String dataset, String attribute) {
    DelvBasicDataSet ds = _data.get(dataset);
    if (null == ds) {
      return "";
    } else {
      return ds.getHighlightedCategory(attribute);
    }
  }
  public String getHoveredCategory(String dataset, String attribute) {
    DelvBasicDataSet ds = _data.get(dataset);
    if (null == ds) {
      return "";
    } else {
      return ds.getHoveredCategory(attribute);
    }
  }

  public DelvDataSet addDataSet(String dataset) {
    DelvBasicDataSet ds = new DelvBasicDataSet(dataset);
    _data.put(dataset, ds);
    return ds;
  }

  public DelvDataSet getDataSet(String dataset) {
    return _data.get(dataset);
  }

  public boolean hasDataSet(String dataset) {
    return _data.containsKey(dataset);
  }

  public void removeDataSet(String dataset) {
    _data.remove(dataset);
  }

} // end class DelvBasicData

public class DelvCSVData extends DelvBasicData {
  String _filename;
  String _dataset;
  String _old_dataset;
  String _delim;
  String _comment;

  public DelvCSVData(String name) {
    this("", "", name);
  }

  public DelvCSVData(String filename, String dataset, String name) {
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

  public DelvData delim(String aDelim) {
    _delim = aDelim;
    return this;
  }

  public String delim() {
    return _delim;
  }

  public DelvData comment(String aComment) {
    _comment = aComment;
    return this;
  }

  public String comment() {
    return _comment;
  }

  public DelvData newDataSetFromFile(String filename, String dataset) {
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
    removeDataSet(_old_dataset);
  }

  public void createDataset() {
    // set up dataset
    color def_col = color_( 210 );
    DelvDataSet ds = addDataSet(_dataset);
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
            _delvIF.log("Invalid row, expected " + numcols + " columns, found " + cols.length + " instead for row " + lineno + ": " + line);
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
        _delvIF.log("Adding CONTINUOUS attribute " + header[ii].trim());
        ds.addAttribute(new DelvBasicAttribute(header[ii].trim(), AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
      } else {
        _delvIF.log("Adding CATEGORICAL attribute " + header[ii].trim());
        ds.addAttribute(new DelvBasicAttribute(header[ii].trim(), AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
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
        DelvDataSet ds = _data.get(_dataset);
        String id = ds.getNextId();

        ds.addId(id);
        for (int ii = 0; ii < header.length; ii++) {
          ds.setItem(header[ii].trim(), id, cols[ii].trim());
        }
      }
    }
  }

} // end class DelvCSVData

// DelvColorMap implementations

class DelvDiscreteColorMap implements DelvColorMap {
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

  // void setMap(DelvColorMap colorMap);

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

  // TODO somewhat dangerous, decide if this method is even necessary
  // void setMap(DelvColorMap colorMap);

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

// some helper color utilities

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
  // assumes inputs are RGB arrays
  // use algorithm from http://stackoverflow.com/questions/168838/color-scaling-function
  // convert everything to HSV
  // interpolate
  // convert back to RGB
  float[] start_hsv = rgb2hsv(red_(start)/255.0,green_(start)/255.0,blue_(start)/255.0);
  float[] end_hsv = rgb2hsv(red_(end)/255.0,green_(end)/255.0,blue_(end)/255.0);
  float[] interp_hsv = interp3(start_hsv, end_hsv, value, 1);
  float[] interp_rgb = hsv2rgb(interp_hsv[0], interp_hsv[1], interp_hsv[2]);
  color rgb = color_( Math.round(interp_rgb[0] * 255),
                      Math.round(interp_rgb[1] * 255),
                      Math.round(interp_rgb[2] * 255) );
  return rgb;
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

