######################
Setting up environment
######################

===========
Java libraries
===========

Here are the needed Java libraries and related install notes

* Eclipse - to build Java environments
* jre 1.7 on Mac
* JRI - to interface with R
* Caleydo - visualization package
* JOGL - Open GL for Java
* Jython - to do Python awesomeness w/ Java
* ImageJ - to do image processing and visualization
  
============
R packages
============

R packages for visualization

* rJava - also provides JRI
* ggplot2 - Hadley's visualization tool
* gridSVG
* SVGAnnotation
* shiny - R web access

============
Python modules
============

Python modules for visualization

* matplotlib
* ggplot
* vtk
* rpy2 - interface with R
* PyQT or PySide
* d3.py ?? -- useful?

 ============
 Jython/Java notes
 ============

 * To use a processing view in Java, it needs to be declared public as do all the .  Otherwise you will see errors like: AttributeError: 'inSite' object has no attribute 'ColorLegendWithDropdownView'
