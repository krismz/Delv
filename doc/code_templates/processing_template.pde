///////////////////////////////////
//              View             //
///////////////////////////////////

// EDIT: search and replace YourView with the name of your view

// NOTE: extend DelvBasicView which implements DelvView to get some common delv and processing.js functionality, or extend DelvCategoryView to get additional functionality when visualizing the categories of a dataset

class YourView extends DelvCategoryView {
  // EDIT: add any view member variables
  // String[] choices;
  // boolean[] choices_selected;

  YourView() {
    // EDIT: provide a more appropriate default name for the view
    this("DefaultName");
  }

  YourView(String name) {
    // NOTE: be sure to call the superclass's constructor
    super(name);
    // EDIT: any other appropriate initialization
    choices = new String[0];
    choices_selected = new boolean[0];
    textFont( _verdana_font_12 );
  }

  // EDIT: add any other getters and setters for view variables

  // EDIT: implement the methods that the will pass data to be visualized
  void setChoices(String[] new_choices) {
    choices = new_choices;
    choices_selected = new boolean[choices.length];
    for (int i = 0; i < choices.length; ++i) {
      choices_selected[i] = true;
    }
    // NOTE: when this is used in processing.js, the normal draw cycle doesn't happen as expected.
    // therefore, you should call redraw() explicitly when the data or visualization has changed.
    redraw();
  }

  void setSelectedChoices(String[] selected_choices) {
    for (int i = 0; i < choices.length; ++i) {
      choices_selected[i] = false;
      for (int j = 0; j < selected_choices.length; ++j) {
        if (selected_choices[j].equals(choices[i])) {
          choices_selected[i] = true;
        }
      }
    }
    // NOTE: when this is used in processing.js, the normal draw cycle doesn't happen as expected.
    // therefore, you should call redraw() explicitly when the data or visualization has changed.
    redraw();
  }

  // NOTE: The parent class View's draw() method takes care of setting the background
  // and translating to _origin.
  // After the translation, draw will call render() which should be overridden here.
  // After render() has completed, draw will translate back from _origin.
  void render() {
    // EDIT: draw stuff here!
  }

  void setup() {
    // EDIT: implement as you would any Processing setup method
  }

  // EDIT: The parent class implements resize by setting _w and _h, and calling redraw()
  // reimplement resize here if this is insufficient for your purposes.

  void mouseMovedInView(int mx, int my) {
    // EDIT: handle mouse move events
    // NOTE: remember to call redraw() explicitly to ensure that the visualization is updated
    // for processing.js
    // NOTE: remember to notify DelvBasicView if some event has happened (like a hover has occurred)
    // so that the View can notify the world.
  }

  void mousePressedInView(int mx, int my, boolean rightPressed) {
    // EDIT: handle mouse press events
    // NOTE: remember to call redraw() explicitly to ensure that the visualization is updated
    // for processing.js
    // NOTE: remember to notify DelvBasicView if some event has happened (like a hover has occurred)
    // so that the View can notify the world.
  }

  void mouseReleasedInView(int mx, int my) {
    // EDIT: handle mouse release events
    // NOTE: remember to call draw() explicitly to ensure that the visualization is updated
    // for processing.js
    // NOTE: remember to notify DelvBasicView if some event has happened (like a hover has occurred)
    // so that the View can notify the world.
  }

  void mouseDraggedInView(int mx, int my) {
    // EDIT: handle mouse drag events
    // NOTE: remember to call draw() explicitly to ensure that the visualization is updated
    // for processing.js
    // NOTE: remember to notify DelvBasicView if some event has happened (like a hover has occurred)
    // so that the View can notify the world.
  }

  void mouseScrolledInView(int wr) {
    // EDIT: handle mouse scroll events
    // NOTE: remember to call draw() explicitly to ensure that the visualization is updated
    // for processing.js
    // NOTE: remember to notify DelvBasicView if some event has happened (like a hover has occurred)
    // so that the View can notify the world.
  }

}
