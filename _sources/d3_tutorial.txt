######################
Using Delv with D3.js
######################

.. _d3-project-layout:

=================
D3.js project layout
=================

For a standard Delv d3.js project, the following directory
structure is recommended:

* ``your_project_directory``

   * ``your_app.xhtml`` -- See :ref:`xhtml-templates` for a layout template
   * ``your_javascript_app.js`` -- This file contains the logic to construct and connect the
     visualizations together, including configuration of the views.  See
     :ref:`javascript-templates` for an example of how to setup Delv and configure views. 
   * ``your_d3_chart_type.js`` -- This file contains the view for one d3 chart type. See
     :ref:`d3-templates` for an example view. 
   * ``your_other_d3_chart_type.js`` -- This file contains the view for another d3 chart type. 
   * ``delvjs`` -- In order to work in the web browser, the javascript code
     should be in a subdirectory relative to your xhtml.   If you prefer not to copy the contents of
     delvjs, you can link to it instead: 

     :samp:`cd your_project_directory; ln -s </path/to/delv/delvjs>`      

      * ``delv.js``
      * ``jquery-1.7.2.js``
      * ``d3.v2.js``


.. todo::
   provide links to download info for delv.js, jquery, d3, etc.

