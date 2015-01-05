// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

// Extensions to Delv to support Movie Events from the Processing Video
// library.  Be sure to import processing.video.*;

//Only want to define this movie when a processing.video.Movie exists
// TODO figure this out later...
class P5_Movie implements MovieIF {
  Movie m;
  P5_Movie(Movie mov) {
    m = mov;
  }
  void read() {
    m.read();
  }
}
