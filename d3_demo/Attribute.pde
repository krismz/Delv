// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// State Class (created to store plotting variables with the states)
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
class State {

    String _state;
    color _fill_color;
    color _stroke_color;
    
    int _bar_height;
    boolean _isOn;

    State( String s ) {
	_state = s;
	_fill_color = FEATURE_DEFAULT_COLOR;
	_stroke_color = -1;
	_bar_height = REGION_HEIGHT;
	_isOn = true;
    }

    boolean isOn(){ return _isOn; }
    void turnOff(){ _isOn = false; }
    void turnOn() { _isOn = true; }
    
    String getState() { return _state; }
    
    // * * * Get/set plotting variables * * * //
    color getFillColor() { return _fill_color; }
    color getStrokeColor() { return _stroke_color; }
    int getBarHeight() { return _bar_height; }

    void setFillColor(color c) { _fill_color = c; }  
    void setStrokeColor(color c) { _stroke_color = c; }  
    void setBarHeight(int h) { _bar_height = h; }
}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
class Attribute {

    String                 _name;        // The name of the attribute
    HashMap<String, State> _states;      // The possible states  
    ArrayList<String>      _state_order; // The order of the states

    // Rendering variables
    int _max_state_tag_pixel_width; // for determing the width of the leaf of the conditioning tree
    
    // * * * Constructors * * * //
    Attribute(String name, ArrayList<String> states) {

	// Save the name of the attribute
	_name = name; 
	
	// Save the order of the states
	_state_order = states;

	// Save states as a hash map
	_states = new HashMap<String, State>();
	for ( int i = 0; i < states.size(); i++ ){
	    _states.put( states.get(i),  new State(states.get(i)) );
	}
	
	// get the max pixel width of the states for the conditioning tree
	_max_state_tag_pixel_width = 0;
	textFont( _pixel_font_8 ); // may need to change this to BOLD if we have rollovers of tree labels
	for ( int i = 0; i < states.size(); i++ ) 
	    _max_state_tag_pixel_width = (int)max( _max_state_tag_pixel_width, textWidth(states.get(i)) );
  
    }
    // Default with just an attribute name
    Attribute(String name) {
	_name = name; 
	_state_order = new ArrayList<String>();
	_states = new HashMap<String, State>();	
	// initialize the max pixel width of the states for the conditioning tree
	_max_state_tag_pixel_width = 0;
  }

  // * * * Add in a state only if we dont already have it * * * //
  void addState(String state) {
      
      // If the state is null, return
      if (state == null)
	  return;
      
      // Look and see if we have this state already
      boolean add = true;
      state = state.trim();
      for (int i = 0; i < _states.size(); i++)
	  if(_states.containsKey(state))
	      add = false;
      if (add){
	  _states.put(state, new State(state));
	  _state_order.add(state);
      }    
   
      // check for the max pixel width of the states for the conditioning tree
      textFont( _pixel_font_8 ); // may need to change this to BOLD if we have rollovers of tree labels
      _max_state_tag_pixel_width = (int)max( _max_state_tag_pixel_width, textWidth(state) );
  }

    // * * * Return the state names in order * * * //
    ArrayList<String> getStateOrder(){ return _state_order; }

    // * * * Get the Attribute name * * * //
    String getName() { return _name; }

    // * * * Set the highlighted state * * * //
    void setHighlight(String state, boolean highlight){
	setNoHighlight();
	_states.get(state).setStrokeColor(FEATURE_HIGHLIGHT_COLOR);
    }
    void setHighlight(int state, boolean highlight){
	setNoHighlight();
	_states.get(_state_order.get(state)).setStrokeColor(FEATURE_HIGHLIGHT_COLOR);
    }
    void setHighlight(int state, boolean highlight, color c){
	setNoHighlight();
	_states.get(_state_order.get(state)).setStrokeColor(FEATURE_HIGHLIGHT_COLOR);
    }
    

    // * * * Set no highlighted state * * * //
    void setNoHighlight(){
	for(int i = 0; i < _states.size(); i++){
	    _states.get(_state_order.get(i)).setStrokeColor(-1);
	}
    }
    
    // * * * Get the number of states * * * //
    int getNumberOfStates() { 
	return _states.size();
    }
    
    // * * * Get the state at the specified index * * * //
    String getState(int i) { 
	// check that we are within bounds
	if ( i >= _states.size() ) {
	    println( "WARNING: request state is out-of-bounds for attribute. Returning NULL." );
	    return null;
	}
	else
	    return _state_order.get(i);
    }
    
    // * * * Turn a state on or off * * * //
    void turnStateOn(String state){
	_states.get(state).turnOn();
    }

    void turnStateOff(String state){
	_states.get(state).turnOff();
    }

    // * * * get if a state is on * * * //
    boolean getStateOn(int state){
	return _states.get(getState(state)).isOn();
    }

    // * * * Set the state's height * * * //
    void setStateHeight(int state, int height){
	_states.get(getState(state)).setBarHeight(height);
    }

    // * * * Get the index of the passed in state string * * * //
    int getStateIndex(String s) {
        
	for ( int i = 0; i < _state_order.size(); i++ ) {
	    if ( _state_order.get(i).equals(s) ){
		return i;
	    }
	}
	println( "WARNING: did not find state string in the list of states. Returning -1." );
	println( s + "." );
	printStates();
	println();
	return -1;
    }
    
    // * * * Get/set the state plotting variables * * * //
    int getStateBarHeight( int state_i ) { return _states.get(state_i).getBarHeight(); }
    int getStateBarHeight( String s ) { 
	if(_states.containsKey(s))
	    return _states.get(s).getBarHeight();
	println( "WARNING: cannot return bar height because state string not found. Returning." );
	return 0;
    }
  
    color getStateFillColor( int state_i ) { return _states.get(_state_order.get(state_i)).getFillColor(); }
    color getStateFillColor( String s ) { 
	if(_states.containsKey(s))
	    return _states.get(s).getFillColor();
	println( "WARNING: cannot return color because state string not found. Returning." );
	return FEATURE_DEFAULT_COLOR;
    }

    color getStateStrokeColor( int state_i ) 
    { return _states.get(_state_order.get(state_i)).getStrokeColor(); }
    color getStateStrokeColor( String s ) {
	if(_states.containsKey(s))
	    return _states.get(s).getStrokeColor();
	println( "WARNING: cannot return color because state string not found. Returning." );
	return -1;
    }
    void setStateStrokeColor(int state_i, color c){
	_states.get(_state_order.get(state_i)).setStrokeColor(c);
    }

    // Just set the stroke color
    void strokeColor(int i){
	color c = _states.get(_state_order.get(i)).getStrokeColor();
	if( c == -1)
	    noStroke();
	else
	    stroke(c);
    }

    boolean isHighlighted(int i){
	color c = _states.get(_state_order.get(i)).getStrokeColor();
	if(c == FEATURE_HIGHLIGHT_COLOR)
	    return true;
	else
	    return false;
    }

    void setStateBarHeight( int state_i, int h ) { _states.get(_state_order.get(state_i)).setBarHeight(h); }  
    void setStateColor( int state_i, color c ) {
	_states.get(_state_order.get(state_i)).setFillColor(c);
	if(c == FEATURE_CLEAR_COLOR) 
	    _states.get(_state_order.get(state_i)).turnOff();
	else
	    _states.get(_state_order.get(state_i)).turnOn();
    }
    
    // * * * Get the max tag length of the states in pixels * * * //
    int getMaxStateTagPixelWidth() { return _max_state_tag_pixel_width; }
    
    // * * * Print the Attribute name * * * //
    void printName() { println("Attribute Name: " + _name); }
    
    // * * * Print the Attribute states * * * //
    void printStates() {
	print("States: ");
	for (int i = 0; i < _states.size(); i++)
	    print(_state_order.get(i) + ". ");
	println("");
    }
    
    // * * * Print the Attribute * * * //
    void printAttribute() { printName(); printStates(); }

    // * * * Move a state UP in the list * * * //
    boolean moveStateUp(String state){

	if(state == null)
	    return false;

	// Get the index of the state
	int idx = -1;
	for(int i = 0; i < _state_order.size(); i++){
    if(state.equals(_state_order.get(i))){
      idx = i;
      break;
    }
	}

	// If we are not at the top, move up one
	if(idx > 0){
	    String temp = _state_order.get(idx-1);
	    _state_order.set(idx-1, state);
	    _state_order.set(idx, temp);	    
	    return true;
	}
	else
	    return false;
    }

    // * * * Move a state DOWN in the list * * * //
    boolean moveStateDown(String state){

	// Get the index of the state
	int idx = -1;
	for(int i = 0; i < _state_order.size(); i++){
    if(state.equals(_state_order.get(i))){
      idx = i;
      break;
    }
	}

	// If we are not at the bottom, move down one
	if(idx < _state_order.size()-1){
	    String temp = _state_order.get(idx+1);
	    _state_order.set(idx+1, state);
	    _state_order.set(idx, temp);	    
	    return true;
	}
	else
	    return false;
    }
}

