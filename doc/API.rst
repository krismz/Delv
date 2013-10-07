#############
API Reference
#############

==========
DataIF API
==========

Delv defines a common abstract data interface that views can use to access datasets.  This interface allows the view to access data without needing to know or understand where or how the data is stored.

.. _dataIF-signals:

DataIF signals:

* categoryVisibilityChanged
* categoryColorsChanged
* hoveredCategoryChanged
* highlightedCategoryChanged
* selectedIdsChanged
* highlightedIdChanged
* hoveredIdChanged

.. todo::
   are these supposed to be the same as the delv signals?  if not, should we give them different names to disambiguate them?

.. class:: dataIF()

   the abstract data interface

.. todo::
    should this class be a part of delv namespace?  delv.js or delv generally?

.. method:: dataIF.updateCategoryVisibility(invoker, dataset, attribute, selection)

   :param string invoker: The name of the object that is toggling the visibility
   :param string dataset: The name of the dataset whose attribute's category's visibility is toggling
   :param string attribute: The name of the attribute whose category's visibility is being toggled
   :param string selection: The name of the category whose visibility is toggling

   toggle the visibility of the category specified by selection.  Any item whose attribute's value
   matches category will have it's visibility toggled.

.. method:: dataIF.updateHighlightedId(invoker, dataset, id)

   :param string invoker: The name of the object that is updating the highlighted id
   :param string dataset: The name of the dataset whose identifier is being highlighted
   :param string id: The id of the item that is being highlighted

   updateHighlightedId sets which item specified by id is highlighted.  To have no item highlighted,
   use "" for the id.

.. method:: dataIF.updateHoveredId(invoker, dataset, id)

   :param string invoker: The name of the object that is updating the hovered id
   :param string dataset: The name of the dataset whose identifier is being hovered
   :param string id: The id of the item that is being hovered

   updateHoveredId sets which item specified by id is hovered.  To have no item hovered,
   use "" for the id.

.. method:: dataIF.getAllItems(dataset, attribute)

   :param string dataset: The name of the dataset that has the attribute
   :param string attribute: The name of the attribute whose items should be returned
   :returns: Returns a String[] list of all the items for that attribute

   Get all the items (as Strings) for attribute from dataset.    Returns an empty String[] on error.

.. method:: dataIF.getAllIds(dataset, attribute)

   :param string dataset: The name of the dataset that has the attribute
   :param string attribute: The name of the attribute whose iss should be returned
   :returns: Returns a String[] list of all the ids of the items for that attribute

   Get all the ids of the items (as Strings) for attribute from dataset.    Returns an empty String[] on error.

.. method:: dataIF.getItem(dataset, attribute, identifier)

   :param string dataset: The name of the dataset that has the attribute
   :param string attribute: The name of the attribute whose item should be returned
   :param string identifier: The id of the item to return
   :returns: Returns a String representation of the item with this id for that attribute

   Get the item (as a String) for attribute from dataset.  Returns an empty String on error.

.. method:: dataIF.getHighlightedId(dataset)

   :param string dataset: The name of the dataset
   :returns: Returns the id of the item in the dataset that is currently highlighted

   Get the id of the currently highlighted item in the dataset.  If none is highlighted, returns an
   empty string.

.. method:: dataIF.getHoveredId(dataset)

   :param string dataset: The name of the dataset
   :returns: Returns the id of the item in the dataset that is currently hovered

   Get the id of the currently hovered item in the dataset.  If none is hovered, returns an
   empty string.


-----

=========
Delv API
=========

.. _delv-signals:

Delv signals:

* categoryVisibilityChanged
* hoveredIdChanged

.. todo::
   complete this list of signals



.. js:data:: delv

   The delv interface provides signal handling capabilities for the delv signals and other custom signals that are registered with it.  

.. method:: delv.log(msg)

   :param string log: a message to log

   In javascript, this will print the msg to the console.  In Processing, this is a call to
   println().

.. method:: delv.getDataIF(id)

   :param string id: name of the requested dataIF instance
   :returns: a reference to a :py:class:`dataIF` instance

   returns the reference to the requested dataIF instance.

.. method:: delv.emitSignal(signal, invoker, dataset, attribute)

   :param string signal: The name of the signal to emit
   :param string invoker: The name of the object emitting the signal
   :param string dataset: The name of the dataset pertaining to the reason the signal is emitted
   :param string attribute: The name of the attribute pertaining to the reason the signal is emitted

   emitSignal is a way for either the data interface to send signals to delv or for views to
   send custom, unrecognized signals through delv to the other views.  This is a good mechanism
   for sending signals that relate to changing features of the visualization unrelated to the data.
   For instance, to change paragraph alignment, an alignment selector view might send an
   ``alignmentChanged`` signal as follows:

   .. code-block:: javascript

      delv.emitSignal("alignmentChanged", "alignmentView", "", "LEFT");

   where the dataset is left blank since it is not associated with a particular data set.

.. todo::
   decide whether emitEvent still needs to be part of the API.   If so, document it

.. method:: delv.connectToSignal(signal, name, method)

   :param string signal: The name of the signal, can be one of the delv :ref:`signals<delv-signals>`, or a custom signal
   :param string name: The name of the view whose method should be invoked when the signal has been emitted
   :param string method: The name of the method which should be called when the signal has been emitted

   connectToSignal registers the view's name and method with delv's signal handler.  Whenever the signal has been emitted, delv will invoke the registered methods as :samp:`name.method({invoker}, {dataset}, {attribute});` where invoker is the name of the object that emitted the signal, dataset is the name of the data set associated with the signal, and attribute is the name of the data attribute associated with the signal. 

    To unregister a method from delv's signal handler, use :py:func:`delv.disconnectFromSignal`

.. method:: delv.disconnectFromSignal(signal, name)

   :param string signal: The name of the signal to disconnect from
   :param string name: The name of the view whose method should no longer be invoked when the signal is emitted.

   disconnectFromSignal unregisters a view's method from the delv's signal handler for the given signal.  

.. note::

  Only one method per view can be registered with a particular signal in delv.

.. todo::
   Should multiple methods per view be allowed to be associated with a single signal?

.. method:: delv.addView(view, id)

   :param view: the view instance to be added to Delv's list of known views
   :param string id: a string uniquely identifying this view instance
   :returns: the delv instance (to support method chaining)

   Registers a view with Delv.  :py:class:`delv.d3Chart` and :py:class:`delv.processingSketch` both automatically register the view they construct with Delv, so this method **does not** need to be called for views constructed in this fashion.

   **Supports method chaining**.

.. method:: delv.reloadData(source)

   :param source: a string identifying who is calling reloadData

   Delv will tell all views to reloadData(source).  Call this when a data source has finished
   initial load or has changed.

-----

============
delv.js API
============

.. todo::
   which of these methods are just the javascript implementation of the Delv API, and which of these methods/classes are javascript-specific?

.. todo::
   consistent capitalization (delv or Delv)?

 .. todo::
    More detail about delv

.. js:data:: delv

    delv is a namespace implementing the delv interface that is created when delv.js is loaded.
    In addition to the basic delv API, delv.js also provides some helper functions to support
    using delv in an asynchronous environment and to ease the integration of visualizations written
    in Processing or D3.js.

.. todo::
   As support for Raphael.js, Google Maps, etc is included, update the docs here to reflect that

.. todo::
   document giveDataIFToViews if this hacky interface is still needed to workaround javascript
   asynchronicity issues.

.. method:: delv.addDataIF(dataIF, id)

   :param dataIF: reference to a :py:class:`dataIF` instance
   :param string id: unique name of the dataIF instance

   addDataIF adds the dataIF to Delv's list of dataSources and also connects the dataIF's :ref:`signals <dataIF-signals>` to Delv's signal handler.

   **Supports method chaining**.

.. method:: delv.resizeAll()

   Has delv resize all views based on the current window size.  Delv automatically registers resizeAll to listen for the SVGResize and resize events, so you should not need to call resizeAll yourself.


.. todo::
   should resizeAll be part of delv.js or delvIF?

.. todo::
   should addDataIF be part of delv.js or delvIF?

-----

.. currentmodule:: delv

.. class:: d3Chart(elementId, script, viewConstructor, loadCompleteCallback)

   :param string elementId: ID of the html document element where the d3Chart should be drawn to.
   :param string script: name of the javascript file containing the code implementing the view and view for this chart
   :param string viewConstructor: name of the view constructor method that should be used to construct the view that will be drawing in this chart
   :param function loadCompleteCallback: function to call when the script has finished loading and the view has been successfully constructed

   d3Chart is a helper class that loads the given script on demand, constructs the specified view and tells it to draw in the given html element, and finally calls the loadCompleteCallback once all of this has been done successfully.

.. todo::
    this assumes that the view and view are in the same file, but it might be better to allow them to be in separate files, should this also take a list of files in ala processingSketch?

-----

.. class:: processingSketch(canvas, sketchList, viewConstructor, loadCompleteCallback)

   :param string canvas: ID of the html5 canvas element where the processing sketch should draw to.
   :param string sketchList: list of the processing .pde files containing the code implementing the view, view and helper objects for this sketch 
   :param string viewConstructor: name of the view constructor method that should be used to construct the view that will be drawing this sketch
   :param function loadCompleteCallback: function to call when the sketches have finished loading and the view has been successfully constructed

   processingSketch is a helper class that loads the given processing .pde files on demand, constructs the specified view and tells it to draw in the given html5 canvas element, and finally calls the loadCompleteCallback once all of this has been done successfully.

.. todo::
   Get full list of what to include in sketchList (or condense Delv pdes into a single file

.. note::
   Be sure to include DelvView.pde, Delv1DView.pde and Delv.pde in the sketchList

-----

.. class:: view()

.. todo::
   Address API inconsistency where dataIF(name) is used, but setName(name) is used.  Should it be setDataIF(name) or name(name) ?

.. method:: view.dataIF(name)

   :param string name: The name of the data interface

   sets the view's DataIF to the data interface with the given name 

.. todo::
   Should we document the _name attribute or the setName / getName functions or both?

.. method:: view.getName()
                  view.setName(name)

   Get and set the name of the view.

   **Supports method chaining**

.. :method:: view.resize(width, height)

   :param width: width in pixels to resize view to
   :param height: height in pixels to resize view to    

   The default implementation ignores the resize.  This method should be overridden to provide meaningful resizing.

.. method:: view.connectSignals()

   The default implementation has no signals connected.  This method is called by Delv once the view has been fully loaded in Javascript.  This is the recommended place to put calls to :py:func:`delv.connectToSignal` like:

.. code-block:: javascript

   _delvIF.connectToSignal("categoryVisibilityChanged", "YourViewName", "YourVisibilityChangedCallback");
   _delvIF.connectToSignal("YourCustomSignal", "YourViewName", "YourCustomSignalCallback");

.. seealso::
   See :ref:`delv signals<delv-signals>` for a complete list of recognized Delv signals.

-----

.. class:: d3View(svgElem)

   :param string svgElem: the name of the svg element that the d3 view can modify and draw in

   the d3 view is a :py:class:`delv.view` that additionally knows the name of the containing svg element that it is allowed to modify and draw in

-----

.. class:: d3HierarchyView(svgElem)

   :param string svgElem: the name of the svg element that the d3 view can modify and draw in

   the d3 hierarchy view is a :py:class:`delv.d3View` that knows how to convert attributes defining node size, node name, link start, and link end into the hierarchy data object recognized by d3 examples such as bar_hierarchy, force_collapsible, partition_sunburst_zoom, and tree_interactive

.. method:: d3HierarchyView.getNodeDatasetName()
                  d3HierarchyView.setNodeDatasetName(name)

   Get or set the name of the dataset containing the node name and node size attributes.

   **Supports method chaining**.

.. method:: d3HierarchyView.getLinkDatasetName()
                  d3HierarchyView.setLinkDatasetName(name)

   Get or set the name of the dataset containing the link start and link end attributes.

   **Supports method chaining**.


.. method:: d3HierarchyView.getNodeSizeAttr()
                  d3HierarchyView.setNodeSizeAttr(name)

   Get or set the name of the attribute that describes the node size.  

   **Supports method chaining**.

.. method:: d3HierarchyView.getNodeNameAttr()
                  d3HierarchyView.setNodeNameAttr(name)

   Get or set the name of the attribute that contains the unique identifiers for the nodes.

   **Supports method chaining**.

.. method:: d3HierarchyView.getLinkStartAttr()
                  d3HierarchyView.setLinkStartAttr(name)

   Get or set the name of the attribute that contains the names of the nodes that are the start of each link.

   **Supports method chaining**.

.. method:: d3HierarchyView.getLinkEndAttr()
                  d3HierarchyView.setLinkEndAttr(name)

   Get or set the name of the attribute that contains the names of the nodes that are the end of each link.

   **Supports method chaining**.

.. method:: d3HierarchyView.convertToHierarchy()

   :returns: the node hierarchy in a data object that the d3 hierarchy views can accept as input to their bindData method

   Convert from node size, node name, link start and link end lists into a hierarchy of objects with name, tag, children, and size attributes.

.. todo::
   provide links back to the d3 documentation for these examples

.. todo::
   provide a link to an example of how to use the d3 hierarchy view

