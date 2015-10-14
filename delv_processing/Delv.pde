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
  void emitSignal(String signal, String invoker, String dataset);
  void emitSignal(String signal, String invoker, String dataset, String detail);
  void emitSignal(String signal, String invoker, String dataset, String[] details);
  void emitSignal(String signal, String invoker, String dataset, String coordination, String detail);
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

  String getHoverItem(String dataset, String attribute);
  Float getHoverItemAsFloat(String dataset, String attribute);
  float[] getHoverItemAsFloatArray(String dataset, String attribute);
  String[] getHoverItemAsStringArray(String dataset, String attribute);

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
  void selectCats(String invoker, String dataset, String[] attributes, String[][] categories, String selectType);
  void deselectCats(String invoker, String dataset, String[] attributes, String[][] categories, String selectType);
  void selectRanges(String invoker, String dataset, String[] attributes, String[][] mins, String[][] maxes, String selectType);
  void deselectRanges(String invoker, String dataset, String[] attributes, String[][] mins, String[][] maxes, String selectType);
  void selectLike(String invoker, String dataset, String[] identifiers, String[] relationships, String selectType);
  void deselectLike(String invoker, String dataset, String[] identifiers, String[] relationships, String selectType);
  void selectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType);
  void deselectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType);
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String invoker, String dataset, String selectType);

  // TODO need filter clearing API too
  void filterCats(String invoker, String dataset, String attribute, String[] categories);
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

  String getHoverId(String dataset);
  String[] getHoverCoord(String dataset);
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
  String[] getFilterCats(String dataset, String attribute);
  String[][] getFilterRanges(String dataset, String attribute);
  String[][] getFilterLike(String dataset);
  String[][][] getFilterCriteria(String dataset);

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

  String[] getHoverColor(String dataset);
  String[] getSelectColor(String dataset, String selectType);
  String[] getFilterColor(String dataset);
  String[] getLikeColor(String dataset);
  // TODO figure out interface for getting/setting other encodings (shape / size / etc).

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

  // operations
  // sort
  // possible values of sortType: ascending, descending
  void sortByVal(String invoker, String attribute, String sortType);
  // possible values of similarity sortType: similarity, dissimilarity
  void sortBySimilarity(String invoker, String identifier, String sortType);
  void sortSimilarity(String invoker, String[] coordinate, String sortType);
  void clearSort(String invoker);
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

  void selectItems(String invoker, String[] ids, String selectType);
  void deselectItems(String invoker, String[] ids, String selectType);
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
  String getNumNavItems();
  String getNavItems(String attr);

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
  void selectCats(String invoker, String[] attrs, String[][] cats, String selectType);
  void deselectCats(String invoker, String[] attrs, String[][] cats, String selectType);
  void selectRanges(String invoker, String[] attrs, String[][] mins, String[][] maxes, String selectType);
  void deselectRanges(String invoker, String[] attrs, String[][] mins, String[][] maxes, String selectType);
  void filterCats(String invoker, String attr, String[] cats);
  void filterRanges(String invoker, String attr, String[] mins, String[] maxes);

  void colorCat(String invoker, String attr, String cat, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String invoker, String attr, String cat, String encoding);

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
  void zoomRange(String invoker, String attr, String minVal, String maxVal);
  // width specified in data space
  void zoomRange(String invoker, String attr, String width);

  String getHoverCat(String attr);
  String[] getHoverRange(String attr);
  String[][] getSelectCats(String attr, String selectType);
  String[][] getSelectRanges(String attr, String selectType);
  String[][][] getSelectCriteria(String selectType);
  String[][] getFilterCats(String attr);
  String[][] getFilterRanges(String attr);
  String[][][] getFilterCriteria();
  String getNavCenterVal(String attr);
  String getNavLeftVal(String attr);
  String getNavRightVal(String attr);
  String getNumNavCats(String attr);
  String getNavMinVal(String attr);
  String getNavMaxVal(String attr);
  String getNavWidth(String attr);

  // Relationships
  void hoverLike(String invoker, String id, String relationship);
  void hoverLike(String invoker, String[] coord, String relationship);
  void selectLike(String invoker, String[] ids, String[] relationships, String selectType);
  void deselectLike(String invoker, String[] ids, String[] relationships, String selectType);
  void selectLike(String invoker, String[][] coords, String[] relationships, String selectType);
  void deselectLike(String invoker, String[][] coords, String[] relationships, String selectType);
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String invoker, String selectType);

  void filterLike(String invoker, String[] ids, String[] relationships);
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
  String getNumNavLike();
  String getLOD();

  // color
  void hoverColor(String[] rgbaColor);
  void selectColor(String[] rgbaColor, String selectType);
  void filterColor(String[] rgbaColor);
  void likeColor(String[] rgbaColor);

  String[] getHoverColor();
  String[] getSelectColor(String selectType);
  String[] getFilterColor();
  String[] getLikeColor();

  // apply filters
  void applyFilters();


} // end interface DelvDataSet

interface DelvAttribute {

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

  String getHoverItem();
  Float getHoverItemAsFloat();
  float[] getHoverItemAsFloatArray();
  String[] getHoverItemAsStringArray();

  String[] getSelectItems(String selectType);
  Float[] getSelectItemsAsFloat(String selectType);
  float[][] getSelectItemsAsFloatArray(String selectType);
  String[][] getSelectItemsAsStringArray(String selectType);

  String[] getFilterItems();
  Float[] getFilterItemsAsFloat();
  float[][] getFilterItemsAsFloatArray();
  String[][] getFilterItemsAsStringArray();

  String getNumNavItems();
  String[] getNavItems();
  Float[] getNavItemsAsFloat();
  float[][] getNavItemsAsFloatArray();
  String[][] getNavItemsAsStringArray();

  String[] getItemColor(String id);
  String[] getItemColor(String[] coord);
  String[][] getAllItemColors();
  String[][] getFilterItemColors();
  String[] getItemEncoding(String id);
  String[] getItemEncoding(String[] coord);
  String[][] getItemEncodings();

  String[] getAllCats();
  String[] getCatColor(String cat);
  String[][] getAllCatColors();
  String[][] getFilterCatColors();
  String[] getCatEncoding(String cat);
  String[][] getCatEncodings();

  void hoverCat(String invoker, String cat);
  void hoverRange(String invoker, String minVal, String maxVal);
  void selectCats(String invoker, String[] cats, String selectType);
  void deselectCats(String invoker, String[] cats, String selectType);
  void selectRanges(String invoker, String[] mins, String[] maxes, String selectType);
  void deselectRanges(String invoker, String[] mins, String[] maxes, String selectType);
  void filterCats(String invoker, String[] cats);
  void filterRanges(String invoker, String[] mins, String[] maxes);

  void colorCat(String invoker, String cat, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String invoker, String cat, String encoding);

  // following works for ordered categorical attribute
  void navVal(String invoker, String value, String leftVal, String rightVal);
  // following works for unordered categorical attribute
  void navCat(String invoker, String cat, String numCats);
  void navRange(String invoker, String center, String minVal, String maxVal);
  // width specified in data space
  void navRange(String invoker, String center, String width);

  void panCat(String invoker, String cat);
  void panRange(String invoker, String center);

  void zoomCat(String invoker, String numCats);
  void zoomRange(String invoker, String minVal, String maxVal);
  // width specified in data space
  void zoomRange(String invoker, String width);

  String getHoverCat();
  String[] getHoverRange();
  String[][] getSelectCats(String selectType);
  String[][] getSelectRanges(String selectType);
  String[][][] getSelectCriteria(String selectType);
  String[][] getFilterCats();
  String[][] getFilterRanges();
  String[][][] getFilterCriteria(String dataset);
  String getNavCenterVal();
  String getNavLeftVal();
  String getNavRightVal();
  String getNumNavCats();
  String getNavMinVal();
  String getNavMaxVal();
  String getNavWidth();

  // apply filter
  void applyFilter();
  boolean isItemFiltered(String id);
  boolean isItemFiltered(String[] coord);

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
  log(""+obj+"."+method+"("+args+") not implemented");
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
  }

  void log(String msg) {
    println(msg);
  }

  void emitEvent(String name, String detail) {
    notImplemented("DelvImpl","emitEvent", name +", " + detail);
  }

  void emitSignal(String signal, String invoker, String dataset attribute) {
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
          Method m = view.getClass().getMethod(signalHandlers.get(signal).get(key), params);
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
          Method m = view.getClass().getMethod(signalHandlers.get(signal).get(key), params);
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
          Method m = view.getClass().getMethod(signalHandlers.get(signal).get(key), params);
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
  void addView(DelvView view, String name) {
    _views.put(name, view);
  }

  void reloadData() {
    reloadData("Delv");
  }
  void reloadData(String source) {
    log("reloading data");
     for (DelvView view : _views.values()) {
       view.reloadData(source);
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
      return ds.getCatEncodings(dataset, attribute);
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
      ds.setFloatItem(, attribute, coordinate, item);
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

  String getHoverItem(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverItem(attribute);
    } else {
      log("Warning in getHoverItem! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  Float getHoverItemAsFloat(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverItemAsFloat(attribute);
    } else {
      log("Warning in getHoverItemAsFloat! Dataset <"+dataset+"> does not exist.");
      return null;
    }
  }
  float[] getHoverItemAsFloatArray(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverItemAsFloatArray(attribute);
    } else {
      log("Warning in getHoverItemAsFloatArray! Dataset <"+dataset+"> does not exist.");
      return new float[0];
    }
  }
  String[] getHoverItemAsStringArray(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverItemAsStringArray(attribute);
    } else {
      log("Warning in getHoverItemAsStringArray! Dataset <"+dataset+"> does not exist.");
      return new String[0];
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
      return String[0][];
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
      ds.sortByVal(invoker, attribute, sortType);
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
      ds.sortBySimilarity(invoker, attribute, sortType);
      emitSignal("sortChanged", invoker, dataset, identifier);
    } else {
      log("Warning in sortBySimilarity! Dataset <"+dataset+"> does not exist.");
    }
  }
  void sortBySimilarity(String invoker, String dataset, String[] coordinate, String sortType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.sortBySimilarity(invoker, attribute, sortType);
      emitSignal("sortChanged", invoker, dataset, coordinate);
    } else {
      log("Warning in sortBySimilarity! Dataset <"+dataset+"> does not exist.");
    }
  }
  void clearSort(String invoker, String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearSort(invoker);
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
      ds.hoverItem(invoker, identifier);
      emitSignal("hoverChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in hoverItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void hoverItem(String invoker, String dataset, String[] coordinate) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverItem(invoker, coordinate);
      emitSignal("hoverChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in hoverItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void hoverCat(String invoker, String dataset, String attribute, String category) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverCat(invoker, attribute, category);
      emitSignal("hoverChanged", invoker, dataset, "CAT", attribute);
    } else {
      log("Warning in hoverCat! Dataset <"+dataset+"> does not exist.");
    }
  }
  void hoverRange(String invoker, String dataset, String attribute, String minVal, String maxVal) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverRange(invoker, attribute, minVal, maxVal);
      emitSignal("hoverChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in hoverRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  // TODO how to specify relationship LIKE this coordinate (ie find all points similar to this one)?
  // might need to be able to pass in arbitrary function ala colorfun which would then make this hard to support cross language (ie over QtBridge)
  void hoverLike(String invoker, String dataset, String identifier, String relationship) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverLike(invoker, identifier, relationship);
      emitSignal("hoverChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in hoverLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void hoverLike(String invoker, String dataset, String[] coordinate, String relationship) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.hoverLike(invoker, identifier, coordinate, relationship);
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
      ds.selectItems(invoker, identifiers, selectType);
      emitSignal("selectChanged", invoker, dataset, "ITEM", selectType);
    } else {
      log("Warning in selectItems! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectItems(String invoker, String dataset, String[] identifiers, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectItems(invoker, identifiers, selectType);
      emitSignal("selectChanged", invoker, dataset, "ITEM", selectType);
    } else {
      log("Warning in deselectItems! Dataset <"+dataset+"> does not exist.");
    }
  }
  void selectItems(String invoker, String dataset, String[][] coordinates, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectItems(invoker, coordinates, selectType);
      emitSignal("selectChanged", invoker, dataset, "ITEM", selectType);
    } else {
      log("Warning in selectItems! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectItems(String invoker, String dataset, String[][] coordinates, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectItems(invoker, coordinates, selectType);
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
      ds.selectCats(invoker, attributes, categories, selectType);
      emitSignal("selectChanged", invoker, dataset, "CAT", selectType);
    } else {
      log("Warning in selectCats! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectCats(String invoker, String dataset, String[] attributes, String[] categories, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectCats(invoker, attributes, categories, selectType);
      emitSignal("selectChanged", invoker, dataset, "CAT", selectType);
    } else {
      log("Warning in deselectCats! Dataset <"+dataset+"> does not exist.");
    }
  }
  void selectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectRanges(invoker, attributes, mins, maxes, selectType);
      emitSignal("selectChanged", invoker, dataset, "RANGE", selectType);
    } else {
      log("Warning in selectRanges! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectRanges(String invoker, String dataset, String[] attributes, String[] mins, String[] maxes, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectRanges(invoker, attributes, mins, maxes, selectType);
      emitSignal("selectChanged", invoker, dataset, "RANGE", selectType);
    } else {
      log("Warning in deselectRanges! Dataset <"+dataset+"> does not exist.");
    }
  }
  void selectLike(String invoker, String dataset, String[] identifiers, String[] relationships, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectLike(invoker, identifiers, relationships, selectType);
      emitSignal("selectChanged", invoker, dataset, "LIKE", selectType);
    } else {
      log("Warning in selectLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectLike(String invoker, String dataset, String[] identifiers, String[] relationships, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectLike(invoker, identifiers, relationships, selectType);
      emitSignal("selectChanged", invoker, dataset, "LIKE", selectType);
    } else {
      log("Warning in deselectLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void selectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.selectLike(invoker, coordinates, relationships, selectType);
      emitSignal("selectChanged", invoker, dataset, "LIKE", selectType);
    } else {
      log("Warning in selectLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void deselectLike(String invoker, String dataset, String[][] coordinates, String[] relationships, String selectType) {
    selectType = validateSelectType(selectType);
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.deselectLike(invoker, coordinates, relationships, selectType);
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
      ds.clearSelect(invoker, selectType);
      emitSignal("selectChanged", invoker, dataset, "CLEAR", selectType);
    } else {
      log("Warning in clearSelect! Dataset <"+dataset+"> does not exist.");
    }
  }

  // TODO need filter clearing API too
  void filterCats(String invoker, String dataset, String attribute, String[] categories) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.filterCats(invoker, attribute, categories);
      emitSignal("filterChanged", invoker, dataset, "CAT");
    } else {
      log("Warning in filterCats! Dataset <"+dataset+"> does not exist.");
    }
  }
  void filterRanges(String invoker, String dataset, String attribute, String[] mins, String[] maxes) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.filterRanges(invoker, attribute, mins, maxes);
      emitSignal("filterChanged", invoker, dataset, "RANGE");
    } else {
      log("Warning in filterRanges! Dataset <"+dataset+"> does not exist.");
    }
  }
  // TODO can we specify a coordinate in a multidimensional table as a single string?  Do we even want to?  Can we specify a generic data relationship as a string?  Is there some other representation we want to use here?
  void filterLike(String invoker, String dataset, String[] identifiers, String[] relationships) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.filterLike(invoker, identifiers, categories);
      emitSignal("filterChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in filterLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void filterLike(String invoker, String dataset, String[][] coordinates, String[] relationships) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.filterLike(invoker, coordinates, categories);
      emitSignal("filterChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in filterLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void clearFilter(String invoker, String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearFilter(invoker);
      emitSignal("filterChanged", invoker, dataset, "CLEAR");
    } else {
      log("Warning in filterCats! Dataset <"+dataset+"> does not exist.");
    }
  }

  // TODO need to figure out a way to specify a continuous color map (colorfun) in some cross-language way.  Some intermediate compromises might include a more generic checkpoints style interface where the colors get specified along with a value and then nicely lerped in between
  void colorCat(String invoker, String dataset, String attribute, String category, String[] rgbaColor) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.colorCat(invoker, attribute, category, rgbaColor);
      emitSignal("colorChanged", invoker, dataset, attribute);
    } else {
      log("Warning in colorCat! Dataset <"+dataset+"> does not exist.");
    }
  }

  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String invoker, String dataset, String attribute, String category, String encoding) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.encodeCat(invoker, attribute, category, encoding);
      emitSignal("encodingChanged", invoker, dataset, attribute);
    } else {
      log("Warning in encodeCat! Dataset <"+dataset+"> does not exist.");
    }
  }

  // nav changes center of window and size of window
  void navItem(String invoker, String dataset, String identifier, String numItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navItem(invoker, identifier, numItems);
      emitSignal("navChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in navItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void navItem(String invoker, String dataset, String[] coordinate, String numItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navItem(invoker, coordinate, numItems);
      emitSignal("navChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in navItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  // following works for ordered categorical attribute
  void navVal(String invoker, String dataset, String attribute, String value, String leftVal, String rightVal) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navVal(invoker, attribute, value, leftVal, rightVal);
      emitSignal("navChanged", invoker, dataset, "VAL", attribute);
    } else {
      log("Warning in navVal! Dataset <"+dataset+"> does not exist.");
    }
  }
  // following works for unordered categorical attribute
  void navCat(String invoker, String dataset, String attribute, String category, String numCats) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navCat(invoker, attribute, category, numCats);
      emitSignal("navChanged", invoker, dataset, "CAT", attribute);
    } else {
      log("Warning in navCat! Dataset <"+dataset+"> does not exist.");
    }
  }
  void navRange(String invoker, String dataset, String attribute, String center, String minVal, String maxVal) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navRange(invoker, attribute, center, minVal, maxVal);
      emitSignal("navChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in navRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  // width specified in data space
  void navRange(String invoker, String dataset, String attribute, String center, String width) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navRange(invoker, attribute, center, width);
      emitSignal("navChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in navRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  void navLike(String invoker, String dataset, String identifier, String relationship, String numLikeItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navLike(invoker, identifier, relationship, numLikeItems);
      emitSignal("navChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in navLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void navLike(String invoker, String dataset, String[] coordinate, String relationship, String numLikeItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.navLike(invoker, coordinate, relationship, numLikeItems);
      emitSignal("navChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in navLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void clearNav(String invoker, String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.clearNav(invoker);
      emitSignal("navChanged", invoker, dataset, "CLEAR");
    } else {
      log("Warning in clearNav! Dataset <"+dataset+"> does not exist.");
    }
  }

  // pan changes center of window, leaves size the same as last nav
  void panItem(String invoker, String dataset, String identifier) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panItem(invoker, identifier);
      emitSignal("navChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in panItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panItem(String invoker, String dataset, String[] coordinate) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panItem(invoker, coordinate);
      emitSignal("navChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in panItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panVal(String invoker, String dataset, String attribute, String value) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panVal(invoker, attribute, value);
      emitSignal("navChanged", invoker, dataset, "VAL", attribute);
    } else {
      log("Warning in panVal! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panCat(String invoker, String dataset, String attribute, String category) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panCat(invoker, attribute, category);
      emitSignal("navChanged", invoker, dataset, "CAT", attribute);
    } else {
      log("Warning in panCat! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panRange(String invoker, String dataset, String attribute, String center) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panRange(invoker, attribute, center);
      emitSignal("navChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in panRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panLike(String invoker, String dataset, String identifier, String relationship) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panLike(invoker, identifier, relationship);
      emitSignal("navChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in panLike! Dataset <"+dataset+"> does not exist.");
    }
  }
  void panLike(String invoker, String dataset, String[] coordinate, String relationship) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.panLike(invoker, coordinate, relationship);
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
      ds.zoomItem(invoker, numItems);
      emitSignal("navChanged", invoker, dataset, "ITEM");
    } else {
      log("Warning in zoomItem! Dataset <"+dataset+"> does not exist.");
    }
  }
  void zoomVal(String invoker, String dataset, String attribute, String leftVal, String rightVal) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomVal(invoker, attribute, leftVal, rightVal);
      emitSignal("navChanged", invoker, dataset, "VAL", attribute);
    } else {
      log("Warning in zoomVal! Dataset <"+dataset+"> does not exist.");
    }
  }
  void zoomCat(String invoker, String dataset, String attribute, String numCats) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomCat(invoker, attribute, numCats);
      emitSignal("navChanged", invoker, dataset, "CAT", attribute);
    } else {
      log("Warning in zoomCat! Dataset <"+dataset+"> does not exist.");
    }
  }
  void zoomRange(String invoker, String dataset, String attribute, String minVal, String maxVal) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomRange(invoker, attribute, minVal, maxVal);
      emitSignal("navChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in zoomRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  // width specified in data space
  void zoomRange(String invoker, String dataset, String attribute, String width) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomRange(invoker, attribute, width);
      emitSignal("navChanged", invoker, dataset, "RANGE", attribute);
    } else {
      log("Warning in zoomRange! Dataset <"+dataset+"> does not exist.");
    }
  }
  void zoomLike(String invoker, String dataset, String numLikeItems) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.zoomLike(invoker, numLikeItems);
      emitSignal("navChanged", invoker, dataset, "LIKE");
    } else {
      log("Warning in zoomLike! Dataset <"+dataset+"> does not exist.");
    }
  }

  void setLOD(String invoker, String dataset, String levelOfDetail) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      ds.setLOD(invoker, levelOfDetail);
      emitSignal("lodChanged", invoker, dataset);
    } else {
      log("Warning in setLOD! Dataset <"+dataset+"> does not exist.");
    }
  }

  ////////////////////
  // get selections
  ////////////////////

  String getHoverId(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverId();
    } else {
      log("Warning in getHoverId! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String[] getHoverCoord(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverCoord();
    } else {
      log("Warning in getHoverCoord! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String getHoverCat(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverCat();
    } else {
      log("Warning in getHoverCat! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String[] getHoverRange(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getHoverRange();
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
      return ds.getSelectCats(selectType);
    } else {
      log("Warning in getSelectCats! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getSelectRanges(String dataset, String attribute, String selectType) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getSelectRanges(selectType);
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
      return ds.getFilterCats();
    } else {
      log("Warning in getFilterCats! Dataset <"+dataset+"> does not exist.");
      return new String[0];
    }
  }
  String[][] getFilterRanges(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterRanges();
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
  String[][][] getFilterCriteria(String dataset) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getFilterCriteria();
    } else {
      log("Warning in getFilterCriteria! Dataset <"+dataset+"> does not exist.");
      return new String[0][][];
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
      return ds.getNavCenterVal();
    } else {
      log("Warning in getNavCenterVal! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavLeftVal(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavLeftVal();
    } else {
      log("Warning in getNavLeftVal! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavRightVal(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavRightVal();
    } else {
      log("Warning in getNavRightVal! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNumNavCats(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNumNavCats();
    } else {
      log("Warning in getNumNavCats! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavMinVal(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavMinVal();
    } else {
      log("Warning in getNavMinVal! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavMaxVal(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavMaxVal();
    } else {
      log("Warning in getNavMaxVal! Dataset <"+dataset+"> does not exist.");
      return "";
    }
  }
  String getNavWidth(String dataset, String attribute) {
    DelvDataSet ds = getDataSet(dataset);
    if (ds != null) {
      return ds.getNavWidth();
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
  String[] _hoverCoord;
  HashMap<String, String[][]> _selectCoords;
  String[][] _filterCoords;
  String[][] _likeCoords;
  String _label;
  int _hoveredIdx;
  HashMap<String, int[]> _selectedIdx;
  int[] _filteredIdx;
  int[] _likeIdx;
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
    _background_color = color_(255);
    _drawBox = true;
    // TODO how and when to get dimension of unique coordinates?
    _coords = new String[0][];
    _hoverCoord = new String[] {""};
    _selectCoords = new HashMap<String, String[][]>();
    _selectCoords.put("PRIMARY", new String[0][]);
    _selectCoords.put("SECONDARY", new String[0][]);
    _selectCoords.put("TERTIARY", new String[0][]);
    _hoveredIdx = -1;
    _selectedIdx = new HashMap<String, int[]>();
    _selectedIdx.put("PRIMARY", new int[0]);
    _selectedIdx.put("SECONDARY", new int[0]);
    _selectedIdx.put("TERTIARY", new int[0]);
    _filteredIdx = new int[0];
    _likeIdx = new int[0];
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
    if (_delv == null) {
      return;
    }
    _delv.connectToSignal("sortChanged", _name, "onSortChanged");

    _delv.connectToSignal("hoverChanged", _name, "onHoverChanged");
    _delv.connectToSignal("selectChanged", _name, "onSelectChanged");
    _delv.connectToSignal("filterChanged", _name, "onFilterChanged");
    _delv.connectToSignal("likeChanged", _name, "onLikeChanged");

    // TODO instead of connecting to colorChanged, hoverColorChanged, filterColorChanged etc,
    // just get the item color for each item from Delv at render time

    // TODO hook up encodingChanged?  navChanged?

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
         dataset.equals(_datasetName) ) {
      setHoveredCoord( _delv.getHoverCoord(_datasetName) );
      }
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
  }
  void onFilterChanged(String invoker, String dataset, String coordination) {
    // only get the coordinates, not the relationship or val / ranges
    if ( !(invoker.equals(_name)) &&
         dataset.equals(_datasetName) ) {
      setFilteredCoords( _delv.getFilterCoords(_datasetName) );
      }
    }
  }
  void onLikeChanged(String invoker, String dataset, String coordination) {
    // only get the coordinates, not the relationship or val / ranges
    if ( !(invoker.equals(_name)) &&
         dataset.equals(_datasetName) ) {
      setLikedCoords( _delv.getLikeCoords(_datasetName) );
      }
    }
  }

  void updateSelections() {
    // TODO handle selection updates
    // String[] selections;
    // selections = _dataIF.getSelectedIds(_datasetName);
    setHoveredCoord( _delv.getHoverCoord(_datasetName) );
    setFilteredCoords( _delv.getFilterCoords(_datasetName) );
    setLikedCoords( _delv.getLikeCoords(_datasetName) );
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
  public int getBackgroundColor() { return _background_color; }
  public DelvBasicView setBackgroundColor(int c) {
    _background_color = c;
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

  public void setHoveredCoord(String[] coord) {
    // TODO actually pick a better data structure and algorithm
    _hoveredIdx = -1;
    _hoverCoord = coord;
    for ( int idx = 0; idx < _coords.length; idx++ ) {
      if (coordsEqual(_coords[idx], coord) {
        _hoveredIdx = idx;
        break;
      }
    }
    hoveredCoordUpdated();
    //redraw();
  }
  public void setSelectedCoords(String[][] coords) {
    // TODO actually pick a better data structure and algorithm
    _selectedIdx = new int[coords.length];
    // TODO handle secondary, tertiary selections
    _selectCoords.put("PRIMARY", coords);
    for ( int ii = 0; ii < coords.length; ii++) {
      String[] coord = coords[ii];
      for ( int idx = 0; idx < _coords.length; idx++ ) {
        if (coordsEqual(_coords[idx], coord) {
          _selectedIdx[ii] = idx;
          break;
        }
      }
    }
    selectedCoordsUpdated();
    draw();
  }
  public void setFilteredCoords(String[][] coords) {
    _filteredIdx = new int[coords.length];
    _filterCoords = coords;
    for ( int ii = 0; ii < coords.length; ii++) {
      String[] coord = coords[ii];
      for ( int idx = 0; idx < _coords.length; idx++ ) {
        if (coordsEqual(_coords[idx], coord) {
          _filteredIdx[ii] = idx;
          break;
        }
      }
    }
    filteredCoordsUpdated();
    //redraw();
  }
  public void setLikedCoords(String[][] coords) {
    _likedIdx = new int[coords.length];
    _likeCoords = coords;
    for ( int ii = 0; ii < coords.length; ii++) {
      String[] coord = coords[ii];
      for ( int idx = 0; idx < _coords.length; idx++ ) {
        if (coordsEqual(_coords[idx], coord) {
          _likedIdx[ii] = idx;
          break;
        }
      }
    }
    likedCoordsUpdated();
    //redraw();
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
  public void coordsUpdated() {}
  public void hoveredCoordUpdated() {}
  public void selectedCoordsUpdated() {}
  public void filteredCoordsUpdated() {}
  public void likedCoordsUpdated() {}

  // To work in javascript as well, cannot have method overloading!! Pick different names!
  public void hoverItem(String[] coord) {
    hoverItem(coord, true);
  }
  public void hoverItem(String[] coord, boolean doDraw) {
    if (!(coordEquals(coord,_hoverCoord))) {
      _hoverCoord = coord;
      _delv.hoverItem(_name, _datasetName, coord);
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
      dlv.addView(view, view.name());
      view.bindDelv(dlv);
    }
    super.bindDelv(dlv);
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
    _selectCats = new HashMap<String, String>();
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
    selections = _dataIF.getFilterCats(_datasetName, _catAttr);
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
        _selectCats.put(selectType, _delv.getSelectCats(_datasetName, _catAttr, selectType);
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
  // more general selection helpers
  public void selectCats(String[] cats, String selectType) {
    selectCats(cats, selectType, true);
  }
  public void selectCats(String[] cats, String selectType, boolean doDraw) {
    _selectCats.put(selectType, cats);
    String[] attrs = new String[1];
    attrs[0] = _catAttr;
    String[] catss = new String[1][];
    catss[0] = cats;
    _delv.selectCats(_name, _datasetName, attrs, catss);
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
    filterCat(cats, true);
  }
  public void filterCat(String cat, boolean doDraw) {
    String[] cats = new String[1];
    cats[0] = cat;
    filterCat(cats, doDraw);
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
  public void coloredCat(String cat, color c) {
    coloredCat(cat, c, true);
  }
  public void coloredCat(String cat, color c, boolean doDraw) {
    if (!(cat.equals(_colorCat))) {
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
  }

  // override these if you need to do a one-time calculation when these events happen
  public void catUpdated() {}
  public void filterCatUpdated() {}
  public void hoveredCatUpdated() {}
  public void selectedCatUpdated() {}
  public void catColorsUpdated() {}
  public void filterCatColorsUpdated() {}

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
      ids = _delv.getAllCoords(_datasetName, _dim1Attr);
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


public class DelvBasicDataSet implements DelvDataSet {
  String _name;
  ArrayList<DelvItemId> _itemIds;
  HashMap<String, Integer> _itemIdHash;
  HashMap<String, DelvBasicAttribute> _attributes;
  String[] _hoverCoord;
  int _lod;

  DelvBasicDataSet(String name) {
    _name = name;
    _itemIds = new ArrayList<DelvItemId>();
    _itemIdHash = new HashMap<String, Integer>();
    _attributes = new HashMap<String, DelvBasicAttribute>();
    _hoverCoord = new String[0];
  }


  String getName() {
    return _name;
  }
  void setName(String name) {
    _name = name;
  }

  HERE HERE HERE HERE

  // operations
  // sort
  // possible values of sortType: ascending, descending
  void sortByVal(String invoker, String attribute, String sortType);
  // possible values of similarity sortType: similarity, dissimilarity
  void sortBySimilarity(String invoker, String identifier, String sortType);
  void sortSimilarity(String invoker, String[] coordinate, String sortType);
  void clearSort(String invoker);
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

  void selectItems(String invoker, String[] ids, String selectType);
  void deselectItems(String invoker, String[] ids, String selectType);
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
  String getNumNavItems();
  String getNavItems(String attr);

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

  void colorCat(String invoker, String attr, String cat, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String invoker, String attr, String cat, String encoding) {
    notImplemented("DelvDataSet","encodeCat", invoker+", "+attr+", "+cat+", "+encoding);
  }

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
  void zoomRange(String invoker, String attr, String minVal, String maxVal);
  // width specified in data space
  void zoomRange(String invoker, String attr, String width);

  String getHoverCat(String attr);
  String[] getHoverRange(String attr);
  String[][] getSelectCats(String attr, String selectType);
  String[][] getSelectRanges(String attr, String selectType);
  String[][][] getSelectCriteria(String selectType);
  String[][] getFilterCats(String attr);
  String[][] getFilterRanges(String attr);
  String[][][] getFilterCriteria();
  String getNavCenterVal(String attr);
  String getNavLeftVal(String attr);
  String getNavRightVal(String attr);
  String getNumNavCats(String attr);
  String getNavMinVal(String attr);
  String getNavMaxVal(String attr);
  String getNavWidth(String attr);

  // Relationships
  void hoverLike(String invoker, String id, String relationship);
  void hoverLike(String invoker, String[] coord, String relationship);
  void selectLike(String invoker, String[] ids, String[] relationships, String selectType);
  void deselectLike(String invoker, String[] ids, String[] relationships, String selectType);
  void selectLike(String invoker, String[][] coords, String[] relationships, String selectType);
  void deselectLike(String invoker, String[][] coords, String[] relationships, String selectType);
  // TODO is this the right API to clear out all ranges/values for the specified coordinate/relationships?  written as is, this is really item selection
  void clearSelect(String invoker, String selectType);

  void filterLike(String invoker, String[] ids, String[] relationships);
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
  String getNumNavLike();
  String getLOD();

  // color
  void hoverColor(String[] rgbaColor);
  void selectColor(String[] rgbaColor, String selectType);
  void filterColor(String[] rgbaColor);
  void likeColor(String[] rgbaColor);

  String[] getHoverColor();
  String[] getSelectColor(String selectType);
  String[] getFilterColor();
  String[] getLikeColor();

  // apply filters
  void applyFilters();


} // end class DelvBasicDataSet

public class DelvBasicAttribute implements DelvAttribute {

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

  String getHoverItem();
  Float getHoverItemAsFloat();
  float[] getHoverItemAsFloatArray();
  String[] getHoverItemAsStringArray();

  String[] getSelectItems(String selectType);
  Float[] getSelectItemsAsFloat(String selectType);
  float[][] getSelectItemsAsFloatArray(String selectType);
  String[][] getSelectItemsAsStringArray(String selectType);

  String[] getFilterItems();
  Float[] getFilterItemsAsFloat();
  float[][] getFilterItemsAsFloatArray();
  String[][] getFilterItemsAsStringArray();

  String getNumNavItems();
  String[] getNavItems();
  Float[] getNavItemsAsFloat();
  float[][] getNavItemsAsFloatArray();
  String[][] getNavItemsAsStringArray();

  String[] getItemColor(String id);
  String[] getItemColor(String[] coord);
  String[][] getAllItemColors();
  String[][] getFilterItemColors();
  String[] getItemEncoding(String id);
  String[] getItemEncoding(String[] coord);
  String[][] getItemEncodings();

  String[] getAllCats();
  String[] getCatColor(String cat);
  String[][] getAllCatColors();
  String[][] getFilterCatColors();
  String[] getCatEncoding(String cat);
  String[][] getCatEncodings();

  void hoverCat(String invoker, String cat);
  void hoverRange(String invoker, String minVal, String maxVal);
  void selectCats(String invoker, String[] cats, String selectType);
  void deselectCats(String invoker, String[] cats, String selectType);
  void selectRanges(String invoker, String[] mins, String[] maxes, String selectType);
  void deselectRanges(String invoker, String[] mins, String[] maxes, String selectType);
  void filterCats(String invoker, String[] cats);
  void filterRanges(String invoker, String[] mins, String[] maxes);

  void colorCat(String invoker, String cat, String[] rgbaColor);
  // TODO how to define a glyph encoding in a cross-language manner?
  void encodeCat(String invoker, String cat, String encoding);

  // following works for ordered categorical attribute
  void navVal(String invoker, String value, String leftVal, String rightVal);
  // following works for unordered categorical attribute
  void navCat(String invoker, String cat, String numCats);
  void navRange(String invoker, String center, String minVal, String maxVal);
  // width specified in data space
  void navRange(String invoker, String center, String width);

  void panCat(String invoker, String cat);
  void panRange(String invoker, String center);

  void zoomCat(String invoker, String numCats);
  void zoomRange(String invoker, String minVal, String maxVal);
  // width specified in data space
  void zoomRange(String invoker, String width);

  String getHoverCat();
  String[] getHoverRange();
  String[][] getSelectCats(String selectType);
  String[][] getSelectRanges(String selectType);
  String[][][] getSelectCriteria(String selectType);
  String[][] getFilterCats();
  String[][] getFilterRanges();
  String[][][] getFilterCriteria(String dataset);
  String getNavCenterVal();
  String getNavLeftVal();
  String getNavRightVal();
  String getNumNavCats();
  String getNavMinVal();
  String getNavMaxVal();
  String getNavWidth();

  // apply filter
  void applyFilter();
  boolean isItemFiltered(String id);
  boolean isItemFiltered(String[] coord);

} // end class DelvBasicAttribute

public class DelvDiscreteColorMap implements DelvColorMap {
  // TODO for now only assume RGB tuple, and work on defining interface needs later
  color getColor(String value);
  // TODO somewhat dangerous, decide if this method is even necessary
  // void setMap(DelvColorMap colorMap);
  void setColor(String value, color c);
  void setDefaultColor(color c);
  void drawToFile(String filename);
} // end class DelvDiscreteColorMap


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
    alpha = rgbaColor[3];
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
  // convert back to RGB
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

