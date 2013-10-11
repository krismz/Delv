###########################
Using Delv with Processing
###########################

.. _processing-project-layout:

=========================
Processing project layout
=========================

For a standard Delv Processing project, the following directory
structure is recommended:

* ``your_project_directory``

   * ``your_app.xhtml`` -- See :ref:`xhtml-templates` for a layout template.
   * ``javascript`` -- In order to work in the web browser, the javascript code
     should be in a subdirectory relative to your xhtml.
   
      * ``your_javascript_app.js`` -- This file contains the logic to construct and connect the
        visualizations together, including configuration of the views.  See
        :ref:`javascript-templates` for an example of how to setup Delv and configure views.
      * ``delv.js``
      * ``jquery-1.7.2.js``
      * ``processing-1.4.0.js``
      
   * ``your_processing_sketch`` -- to have this sketch run in Processing as well as in the web browser,
     make sure that you have a corresponding .pde file in this directory with the same name

      * ``your_processing_sketch.pde`` -- main entry to your processing sketch.  [#f1]_
      * ``your_processing_vis.pde`` -- This file contains the view for one
        visualization type.
        See :ref:`processing-templates` for an example View. [#f2]_ 
      * ``your_other_processing_vis.pde`` -- This file contains the view for another
        visualization type.  [#f2]_ 
      * ``Delv.pde``  [#f3]_ 
      * ``DelvBasicData.pde`` [#f3]_
      * ``DelvView.pde`` [#f3]_

.. todo::
   get project directory correct with all Delv files, or condense Delv*.pde into a single file

.. todo::
   provide links to download info for delv.js, jquery, processing.js, etc.

.. [#f1] Usually this main sketch is only used in the Processing environment, and should **NOT** be loaded by your_javascript_app.js
.. [#f2] Make sure all files including Delv.pde, DelvBasicData.pde and DelvView.pde are explicitly loaded in your_javascript_app.js
.. [#f3] For the web browser, this file could be in another location, but to work in Processing it needs to be in the same directory of your sketch (you can use a link if you
        don't want to copy the file).
