# Run from jython started from run.sh
# ie ./jython.sh qplot_example.py

import org.rosuda.JRI.Rengine as Rengine

if __name__ == "__main__":
  reng = Rengine(["--vanilla"], False, None)
  # set up R library environment
  reng.eval('library(ggplot2)') # for qplot
  reng.eval('library(gridSVG)') # for SVG annotation and export to SVG
  reng.eval('library(XML)') # for converting SVG DOM to a String via saveXML
  # plot
  reng.eval('print(qplot(mpg,cyl,data=mtcars))')
  # now export to SVG
  reng.eval('sv<-grid.export("")')
  # and extract the SVG as a string
  svg=reng.eval('saveXML(sv$svg)').asString()
  # write the SVG to file
  fid=open('qplot_example.svg','w')
  fid.writelines(svg)
  fid.close()
