#!/bin/bash

# jython
jyd="/Users/krismz/Software/jython"
jython_bin="${jyd}/jython"
jython_cp="${jyd}/jython.jar"

# eclipse
ejd="/Users/krismz/Software/eclipse/plugins"
eclipse_cp="${ejd}/org.eclipse.swt.cocoa.macosx.x86_64_3.103.2.v20150203-1351.jar:${ejd}/org.eclipse.swt_3.103.2.v20150203-1313.jar:${ejd}/org.eclipse.wb.rcp.swing2swt_1.7.0.r44x201405021526.jar"

# Delv python code
delvd="/Users/krismz/Software/delv"
delv_jp="${delvd}/jydelv:${delvd}/pydelv"

# processing
#pjd="/Users/krismz/Software/Processing_2.0b7_jars/core/library"
#processing_cp="${pjd}/core.jar:${pjd}/gluegen-rt.jar:${pjd}/jogl-all.jar"
# For Processing 2.2
sjd="/Users/krismz/Software/delv/examples/inSite/application.macosx/inSite.app/Contents/Java"
# For Processing 2.0.2
#sjd="/Users/krismz/Software/delv/examples/inSite/application.macosx/inSite.app/Contents/Resources/Java"
sketch_cp="${sjd}/core.jar:${sjd}/gluegen-rt.jar:${sjd}/jogl-all.jar:${sjd}/inSite.jar:${sjd}/data/pf_tempesta_seven.ttf:${sjd}/data/pf_tempesta_seven_bold.ttf:${sjd}/data"


# ImageJ via FIJI
#fjd="/Applications/Fiji.app/jars"
#fiji_cp="${fjd}/ij-1.47s.jar:${fjd}/VIB-lib-2.0.0-SNAPSHOT.jar"

#fjpd="/Applications/Fiji.app/plugins"
#fiji_plugins_cp="${fjpd}/3D_Viewer.jar"

# CorrPro (sCorrPlot)
#tmpd="/Users/krismz/Software/gyroscope/CorrProOrig/application.macosx/CorrPro.app/Contents/Resources/Java/"
#tmpd_cp="${tmpd}/iCorrPro.jar:${tmpd}/pca_transform-0.7.2.jar:${tmpd}/pdf.jar:${tmpd}/itext.jar"

# inSite 
#isd="/Users/krismz/Software/snapvis/trunk/src/snapvis_views/Processing/application.macosx/Processing.app/Contents/Resources/Java/"
#isd_cp="${isd}/inSite.jar:${isd}/data/pf_tempesta_seven.ttf:${isd}/data/pf_tempesta_seven_bold.ttf"

# Caleydo
cjd="/Users/krismz/Software/Caleydo.app/plugins"
caleydo_cp=`ls ${cjd}/*.jar | awk -v ORS=: '{ print $1 }' `

# JRI
jrid="/Library/Frameworks/R.framework/Versions/3.0/Resources/library/rJava/jri"
#jrid="/opt/local/Library/Frameworks/R.framework/Versions/3.1/Resources/library/rJava/jri"
jri_cp=${jrid}/JRI.jar:${jrid}/JRIEngine.jar:${jrid}/REngine.jar
jri_path=${jrid}

# JavaGD
#jgdd="/Library/Frameworks/R.framework/Versions/3.0/Resources/library/JavaGD/java"
##jgdd="/opt/local/Library/Frameworks/R.framework/Versions/3.1/Resources/library/JavaGD/java"
#jgd_cp=${jgdd}/JavaGD.jar
#jgd_path=${jgdd}

# R
rd='/Library/Frameworks/R.framework/Resources'
#rd='/opt/local/Library/Frameworks/R.framework/Resources'
export R_HOME=${rd}

#cp=${processing_cp}:${fiji_cp}:${fiji_plugins_cp}:${tmpd_cp}:${isd_cp}
cp=${eclipse_cp}:${caleydo_cp}:${jri_cp}:${sketch_cp}
export CLASSPATH=$cp

jcp=${jython_cp}

pth=${jri_path}

jp=${delv_jp}
#export JYTHONPATH=${JYTHONPATH}:${jp}
# -J passes the following argument to the JVM instead of jython
# -XstartOnFirstThread is for Mac and SWT to avoid:  "WARNING: Display must be created on main thread due to Cocoa restrictions."

# startonfirstthread for SWT/AWT things
$jython_bin -J-XstartOnFirstThread -J-Djava.library.path=$pth -Dpython.path=$cp:$jp $*
#$jython_bin -J-Djava.library.path=$pth -Dpython.path=$cp:$jp $*
