// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

// classes and interfaces used to talk back and forth between javascript and processing
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;

interface Delv {
  void log(String msg);
  void emitEvent(String name, String detail);
  DelvData getDataIF(String dataSource);
  void setDataIF(DelvData dataInt);
  void emitSignal(String signal, String invoker, String dataset, String attribute);
  void emitSignal(String signal, String invoker, String dataset, String[] attributes);
  void connectToSignal(String signal, String name, String method);
  void disconnectFromSignal(String signal, String name);
  void addView(DelvView view, String name);
  void reloadData();
  void runInThread(Object obj, String name);
 }

class DelvImpl implements Delv {
  DelvData dataIF;
  HashMap<String, DelvView> views;

  DelvImpl() {
    views = new HashMap<String, DelvView>();
  }

  DelvImpl(DelvData dataInt) {
    dataIF = dataInt;
    views = new HashMap<String, DelvView>();
  }

  void log(String msg) {
    println(msg);
  }

  void emitEvent(String name, String detail) {
// 	println("Event " + name + " emitted with detail: " + detail);
  }

  DelvData getDataIF(String dataSource) {
    // TODO do something with dataSource
    return dataIF;
  }

  // TODO this should be addDataIF and include a String argument for the name
  void setDataIF(DelvData dataInt) {
    dataIF = dataInt;
  }

  void emitSignal(String signal, String invoker, String dataset, String attribute) {
    log("Emitting " + signal + " sent from " + invoker + " for dataset " + dataset + " and attribute " + attribute);
    // TODO fix this hack
    if (signal.equals("dataUpdated")) {
      for (DelvView view : views.values()) {
        view.onDataUpdated(invoker, dataset, attribute);
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
    // TODO fix this hack
    if (signal.equals("dataUpdated")) {
      for (DelvView view : views.values()) {
        view.onDataUpdated(invoker, dataset, attributes);
      }
    }
  }

  void connectToSignal(String signal, String name, String method) {
    // TODO figure out how to support callbacks in Java version of Processing (require a naming convention etc?)
    log("Connecting " + signal + " to " + name + "." + method);
  }

  void disconnectFromSignal(String signal, String name) {
    log("Disconnecting " + signal + " from " + name);
  }

  void addView(DelvView view, String name) {
    views.put(name, view);
  }

  void reloadData() {
    log("reloading data");
    // for (DelvView view : views.values()) {
    //   view.reloadData("Delv");
    // }
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

interface DelvData {
  void updateCategoryVisibility(String invoker, String dataset, String attribute, String selection);
  void updateCategoryColor(String invoker, String dataset, String attribute, String selection, String[] rgbColor);
  void updateHighlightedCategory(String invoker, String dataset, String attribute, String selection);
  void updateHoveredCategory(String invoker, String dataset, String attribute, String selection);
  void updateHighlightedId(String invoker, String dataset, String id);
  void updateHoveredId(String invoker, String dataset, String id);
  void updateSelectedIds(String invoker, String dataset, String[] ids);

  void setItem(String dataset, String attribute, String identifier, String item);
  void setFloatItem(String dataset, String attribute, String identifier, Float item);
  void setFloatArrayItem(String dataset, String attribute, String identifier, float[] item);

  Boolean hasAttribute(String dataset, String attribute);
  String[] getAttributes(String dataset);
  String[] getAllCategories(String dataset, String attribute);
  String[] getVisibleCategories(String dataset, String attribute);
  String[][] getAllCategoryColors(String dataset, String attribute);
  String[][] getVisibleCategoryColors(String dataset, String attribute);
  String[] getItemColor(String dataset, String attribute, String identifier);
  String[] getAllItems(String dataset, String attribute);
  // TODO Float, float, Double or double here?
  Float[] getAllItemsAsFloat(String dataset, String attribute);
  float[][] getAllItemsAsFloatArray(String dataset, String attribute);
  String[] getAllIds(String dataset, String attribute);
  String getItem(String dataset, String attribute, String identifier);
  Float getItemAsFloat(String dataset, String attribute, String identifier);
  float[] getItemAsFloatArray(String dataset, String attribute, String identifier);
  String getHighlightedId(String dataset);
  String getHoveredId(String dataset);
  String getHighlightedCategory(String dataset, String attribute);
  String getHoveredCategory(String dataset, String attribute);
}

