
// class InSiteTestDataOld implements DelvData {
//   Delv _delvIF;
//   String _highlightedID1, _highlightedID2;
//   String _hoveredID1, _hoveredID2;
//   HashMap <String, Boolean> _regionCatVisibility;

//   InSiteTestDataOld() {
//     _highlightedID1 = _highlightedID2 = "";
//     _hoveredID1 = _hoveredID2 = "";
//     _regionCatVisibility = new HashMap<String, Boolean>();
//     _regionCatVisibility.put("dmel",true);
//     _regionCatVisibility.put("dyak",true);
//     _regionCatVisibility.put("wild",true);
//     _regionCatVisibility.put("mutant",true);
//     _regionCatVisibility.put("bcd",true);
//     _regionCatVisibility.put("cad",true);
//     _regionCatVisibility.put("tll",true);
//     _regionCatVisibility.put("hb",true);
//   }

//   void loadData() {}

//   // TODO should data interface and delv interface be so tightly coupled? (each with a reference to the other?)
//   void setDelvIF(Delv dlv) {
//     _delvIF = dlv;
//   }
//   void updateCategoryVisibility(String invoker, String dataset, String attribute, String selection) {
//     if (dataset.equals("Regions")) {
//       boolean val = _regionCatVisibility.get(selection);
//       _regionCatVisibility.put(selection, !val);
//     }
//     _delvIF.emitSignal("categoryVisibilityChanged",invoker, dataset, attribute);
//   }
//   void updateCategoryColor(String invoker, String dataset, String attribute, String selection, String[] rgbColor) {
//     _delvIF.emitSignal("categoryColorsChanged", invoker, dataset, attribute);
//   }
//   void updateHighlightedCategory(String invoker, String dataset, String attribute, String selection) {
//     println("Placeholder for updateHighlightedCategory");
//   }
//   void updateHoveredCategory(String invoker, String dataset, String attribute, String selection) {
//     println("Placeholder for updateHoveredCategory(" + invoker + ", " + dataset + ", " + attribute + ", " + selection + ")");
//   }
//   void updateHighlightedId(String invoker, String dataset, String id) {
//     if (dataset.equals("Regions")) {
//       _highlightedID1 = id;
//     }
//     else {
//       _highlightedID2 = id;
//     }
//   }
//   void updateHoveredId(String invoker, String dataset, String id) {
//     if (dataset.equals("Regions")) {
//       _hoveredID1 = id;
//     }
//     else {
//       _hoveredID2 = id;
//     }
//   }
//   void updateSelectedIds(String invoker, String dataset, String[] ids) {
//     println("Placeholder for updateSelectedIds");
//   }

//   String[] getVisibleCategories(String dataset, String attribute) {
//     ArrayList<String> cats = new ArrayList<String>();
//     if (attribute.equals("Species")) {
//       if (_regionCatVisibility.get("dmel"))
//         cats.add("dmel");
//       if (_regionCatVisibility.get("dyak"))
//         cats.add("dyak");
//     } else if (attribute.equals("Phenotype")) {
//       if (_regionCatVisibility.get("wild"))
//         cats.add("wild");
//       if (_regionCatVisibility.get("mutant"))
//         cats.add("mutant");
//     } else if (attribute.equals("motif_type")) {
//       if (_regionCatVisibility.get("bcd"))
//         cats.add("bcd");
//       if (_regionCatVisibility.get("cad"))
//         cats.add("cad");
//       if (_regionCatVisibility.get("tll"))
//         cats.add("tll");
//       if (_regionCatVisibility.get("hb"))
//         cats.add("hb");
//     }
//     return cats.toArray(new String[cats.size()]);
//   }


//   String[] getAllCategories(String dataset, String attribute) {
// 	String[] cats;
// 	if (attribute.equals("Species")) {
// 	    cats = new String[2];
// 	    cats[0] = "dmel";
// 	    cats[1] = "dyak";
// 	} else if (attribute.equals("Phenotype")) {
// 	    cats = new String[2];
// 	    cats[0] = "wild";
// 	    cats[1] = "mutant";
//         } else if (attribute.equals("motif_type")) {
//           cats = new String[4];
//           cats[0] = "bcd";
//           cats[1] = "cad";
//           cats[2] = "tll";
//           cats[3] = "hb";
// 	} else {
// 	    cats = new String[0];
// 	}
// 	return cats;
//     }

//   String[][] getAllCategoryColors(String dataset, String attribute) {
// 	String[][] cols;
// 	if (attribute.equals("Species")) {
//           cols = new String[2][3];
//           // cols[0] = "#1F78B4
//           cols[0][0] = "31";
//           cols[0][1] = "120";
//           cols[0][2] = "180";
//           // cols[1] = "#33A02C
//           cols[1][0] = "51";
//           cols[1][1] = "160";
//           cols[1][2] = "44";
// 	} else if (attribute.equals("Phenotype")) {
//           cols = new String[2][3];
//           // cols[0] = "#1F78B4
//           cols[0][0] = "31";
//           cols[0][1] = "120";
//           cols[0][2] = "180";
//           // cols[1] = "#33A02C
//           cols[1][0] = "51";
//           cols[1][1] = "160";
//           cols[1][2] = "44";
//         } else if (attribute.equals("motif_type")) {
//           cols = new String[4][3];
//           // cols[0] = "#1F78B4
//           cols[0][0] = "31";
//           cols[0][1] = "120";
//           cols[0][2] = "180";
//           // cols[1] = "#33A02C
//           cols[1][0] = "51";
//           cols[1][1] = "160";
//           cols[1][2] = "44";
//           cols[2][0] = "210";
//           cols[2][1] = "210";
//           cols[2][2] = "210";
//           cols[3][0] = "210";
//           cols[3][1] = "210";
//           cols[3][2] = "210";
// 	} else {
// 	    cols = new String[0][0];
// 	}
// 	return cols;
//   }
//   String[][] getVisibleCategoryColors(String dataset, String attribute) {
//     return getAllCategoryColors(dataset, attribute);
//   }
//   String getHoveredCategory(String dataset, String attribute) {
//     String cat;
//     if (attribute.equals("Species")) {
//       cat = "dyak";
//     } else if (attribute.equals("Phenotype")) {
//       cat = "wild";
//     } else if (attribute.equals("motif_type")) {
//       cat = "cad";
//     } else {
//       cat = "";
//     }
//     return cat;
//   }

//   String[] getAllItems(String dataset, String attribute) {
//         if (dataset.equals("Regions")) {
//           if (attribute.equals("Species")) {
//             String[] vals = { "dmel", "dmel", "dmel", "dmel", "dmel", "dmel", "dmel", "dmel", "dmel", "dyak", "dyak", "dyak", "dyak", "dyak", "dyak", "dyak", "dyak", "dyak", "dyak", "dyak", "dyak", "dyak" };
//             return vals;
//           } else if (attribute.equals("Phenotype")) {
//             String[] vals = { "mutant",  "mutant", "mutant", "mutant", "mutant", "wild", "wild", "wild", "wild",  "mutant", "mutant", "mutant", "mutant", "mutant", "mutant", "wild", "wild", "wild", "wild", "wild", "wild", "wild" };
//             return vals;
//           } else if (attribute.equals("totalLength")) {
//             String[] vals = { "1566", "1566", "1566", "1566", "1566", "1566", "1566", "1566", "1566", "1618", "1618", "1618", "1618", "1618", "1618", "1618", "1618", "1618", "1618", "1618", "1618", "1618" };
//             return vals;
//           } else if (attribute.equals("class")) {
//             String[] vals = { "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site", "binding_site" };
//             return vals;
//           } else if (attribute.equals("start")) {
//             String[] vals = { "871", "796", "617", "1262", "542", "1025", "21", "413", "425", "14", "613", "358", "681", "522", "690", "22", "415", "427", "487", "530", "706", "1154" };
//             return vals;
//           } else if (attribute.equals("length")) {
//             String[] vals = { "14", "14", "8", "8", "10", "7", "8", "8", "8", "8", "12", "8","12","7","12", "8", "8", "8", "8", "8", "8", "8" };
//             return vals;
//           } else if (attribute.equals("motif_type")) {
//             String[] vals = { "bcd","bcd","cad","cad","cad","tll","hb","hb","hb","hb","hb","hb","hb","hb","hb","hb","hb","hb","hb","hb","hb","hb" };
//             return vals;
//           } else if (attribute.equals("strength")) {
//             String[] vals = { "9.60","9.39","8.44","8.28","8.91","8.93","9.92","9.95","9.75","8.198758555","5.4574","12.528","15.42387","11.5514","7.404","9.92","9.92","9.75","11.28","10.81","11.28","11.28" };
//             return vals;
//           } else {
// 	    return new String[0];
//           }
// 	} else {
//           if (attribute.equals("Species")) {
//             String[] vals = { "dmel", "dmel", "dmel", "dmel", "dmel", "dmel","dyak", "dyak", "dyak", "dyak"};
//             return vals;
//           } else if (attribute.equals("Phenotype")) {
//             String[] vals = { "mutant",  "mutant", "mutant", "wild", "wild", "wild", "mutant", "mutant", "wild", "wild" };
//             return vals;
//           } else if (attribute.equals("totalLength")) {
//             String[] vals = { "1566", "1566", "1566", "1566", "1566", "1566", "1618", "1618", "1618", "1618" };
//             return vals;
//           } else if (attribute.equals("class")) {
//             String[] vals = { "annotation", "annotation", "annotation", "annotation", "annotation", "annotation", "annotation", "annotation", "annotation", "annotation" };
//             return vals;
//           } else if (attribute.equals("start")) {
//             String[] vals = { "503","900","960","503","900","960","700","1002","700","1002" };
//             return vals;
//           } else if (attribute.equals("length")) {
//             String[] vals = { "100","20","0","100","20","0","55","0","55","0" };
//             return vals;
//           } else if (attribute.equals("description")) {
//             String[] vals = { "example1","example2","example3", "example1","example2","example3", "example4","example5", "example4","example5" };
//             return vals;
//           } else {
// 	    return new String[0];
//           }
//         }
//     }
//   Float[] getAllItemsAsFloat(String dataset, String attribute) {
//     String[] itemStrs = getAllItems(dataset, attribute);
//     Float[] items = new Float[itemStrs.length];
//     for( int i = 0; i < itemStrs.length; i++) {
//       items[i] = parseFloat(itemStrs[i]);
//     }
//     return items;
//   }

//   String[] getAllIds(String dataset, String attribute) {
//         if (dataset.equals("Regions")) {
//           // a dense data set example, all values are populated for all ids
//           // therefore we can just return a static list instead of looking up per attribute
//           String[] vals = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21" };
//           return vals;
// 	} else {
//           String[] vals = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" };
//           return vals;
//         }
//     }

//   String getItem(String dataset, String attribute, String identifier) {
//     println("Placeholder for getItem");
//     return "0";
//   }
//   Float getItemAsFloat(String dataset, String attribute, String identifier) {
//     println("Placeholder for getItemAsFloat");
//     return 0.0f;
//   }

//   String getHighlightedId(String dataset) {
//     if (dataset.equals("Regions")) {
//       return _highlightedID1;
//     }
//     else {
//       return _highlightedID2;
//     }
//   }
//   String getHoveredId(String dataset) {
//     if (dataset.equals("Regions")) {
//       return _hoveredID1;
//     }
//     else {
//       return _hoveredID2;
//     }
//   }

// }
