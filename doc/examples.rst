##############
Delv Examples
##############

.. _simple-views-example:

======================
Running local examples
======================

Serve locally
=============

Run your favorite web server from the Delv examples directory.  Then navigate to ``localhost:8384``
in your web browser (substitute whatever port you've chosen as necessary).  For example

> cd /path/to/delv/examples
> python -m SimpleHTTPServer 8384


Local file loading
==================

Enable local file loading for your browsers.
**Note that these are all dangerous settings when browsing the web, only use these settings for LOCAL browsing.**

Firefox: go to about:config and set security.fileuri.strict_origin_policy to false
Safari: Advanced-> Show develop menu in menu bar.  Develop->Disable local file restrictions
Chrome:  Start chrome with --allow-file-access-from-files (from mac: open /Applications/Google\ Chrome.app --args --allow-file-access-from-files)

.. _insite-example:

==========
inSite 
==========

To run the inSite example in Processing, open ``/path/to/delv/examples/inSite/inSite.pde`` from your
Processing environment and press play.  To see the same example in Javascript, point a web browser
at ``localhost:8384/inSite/inSite.xhtml`` or ``file:///path/to/delv/examples/inSite/inSite.xhtml``.  This is an example of several interactions including category filtering, an interactive color choosing legend, rollover / hovering, etc.

.. _d3-demo-example:

==========
D3 Demo
==========

The D3 demo is an example of 4 different D3 examples taken from `d3js.org
<https://github.com/mbostock/d3/wiki/Gallery>`_ and combined with the RegionView that is the center
bar chart visualization in the insite-example_.  To run this example, point a web browser at
``localhost:8384/d3_demo/d3_demo.xhtml`` or  ``file:///path/to/delv/examples/d3_demo/d3_demo.xhtml``

.. _vega-crossfilter-example:

================
Vega Crossfilter
================

The Vega Crossfilter example is an example of integrating the Vega crossfilter example from  the
`Vega online editor
<http://vega.github.io/vega-editor/>`_  into Delv.  To run this example, point a web browser at
``localhost:8384/vega_crossfilter/vega_crossfilter.xhtml`` or  ``file:///path/to/delv/examples/vega_crossfilter/vega_crossfilter.xhtml``


============
simple views
============

This is a demonstration of a simple 1-D view (a sparkline) interacting with a 2-D view
(Template200).  Point a web browser at ``localhost:8384/simple_views/simple_views.xhtml`` or
``file:///path/to/delv/examples/simple_views/simple_views.xhtml`` to start the example.  Note that mousing over points in the bar chart will highlight the points in the sparkline.

.. todo::
   Get a version of these examples published as part of the documentation build and pushed to github.io.

.. _tangelo-example:

===========
tangelo
===========

This example modifies `tangelo's <https://github.com/Kitware/tangelo>`_ ner example.  

To run this example, do the following::

> cd /path/to/tangelo/examples/ner
> mv ner.js ner.orig.js
> ln -s /path/to/delv/examples/tangelo/ner/ner.js
> mv index.html index.orig.html
> ln -s /path/to/delv/examples/tangelo/ner/index.html
> ln -s /path/to/delv/delvjs
> ln -s /path/to/delv/examples/tangelo/views
> cd data
> ln -s ../views/data/pf_tempesta_seven.ttf
> ln -s ../views/data/pf_tempesta_seven_bold.ttf

And then start the ner example as you normally would.



