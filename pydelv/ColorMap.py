# ======================================================================
# Copyright (c) 2013, Scientific Computing and Imaging Institute,
# University of Utah. All rights reserved.
# Author: Kris Zygmunt
# License: New BSD 3-Clause (see accompanying LICENSE file for details)
# ======================================================================
import colorsys

class ColorMapException(Exception):
    def __init__(self, msg):
        self.msg = msg
    def __str__(self):
        return str(self.msg)

class ColorMap:
    #TODO for now only assume RGB tuple, and work on defining interface needs later
    def __init__(self):
        self.defaultColor = (220, 220, 220)

    def getColor(self, value):
        pass

    def setMap(self, colorMap):
        pass

    def getMap(self):
        pass

    def setColor(self, value, color):
        pass

    def setDefaultColor(self, color):
        self.defaultColor = color

class DiscreteColorMap(ColorMap):
    def __init__(self):
        self.colors = {}

    def getColor(self, value):
        if value in self.colors.keys():
            return self.colors[value]
        else:
            return self.defaultColor

    def setMap(self, colorMap):
        # TODO somewhat dangerous, decide if this method is even necessary
        self.colors = colorMap

    def getMap(self):
        return self.colors

    def setColor(self, value, color = None):
        # sets color map for entry value to color color
        # if color not provided, defaults to default color
        # overrides existing color if that value already exists
        if color:
            self.colors[value] = color
        else:
            self.colors[value] = self.defaultColor

    def drawToFile(self, filename):
        import png
        row = []
        for val in self.colors.keys():
            color = self.colors[val]
            for i in range(50):
                row.append(int(color[0]))
                row.append(int(color[1]))
                row.append(int(color[2]))

        img = []
        for i in range(0, 50):
            img.append(row)

        f = open(filename, 'wb')
        w = png.Writer(50*len(self.colors.keys()),50,greyscale=False)
        w.write(f, img)
        f.close()

class ContinuousRange:
    # implements a half-open range [lower, upper)
    # TODO be sure to enforce condition that both lb and ub can't be None for the same entry
    def __init__(self):
        self.lower = 0
        self.upper = 1

    def __str__(self):
        return "[%s,%s)" % (self.lower, self.upper)

    def overlapped(self, other):
        status = False
        if self.contains(other.lower) or self.contains(other.upper):
            status = True
        return status

    def contains(self, value):
        status = False
        if value != None:
            if self.lower == None and value < self.upper:
                status = True
            elif self.upper == None and value >= self.lower:
                status = True
            elif self.lower <= value and value < self.upper:
                status = True
        return status

class ContinuousColorMap(ColorMap):
    def __init__(self):
        self.bounds = []
        self.colors = []

    def getColor(self, value):
        bound = None
        for ii in range(len(self.bounds)):
            if self.bounds[ii].contains(value):
                bound = ii
                break
        if bound == None:
            return self.defaultColor
        else:
            colorfun = self.colors[bound]
            if colorfun:
                lb = self.bounds[bound].lower
                ub = self.bounds[bound].upper
                # TODO strongly need to consider how to handle None case
                if lb == None:
                    # TODO handle div by 0 case
                    relval = value / ub
                elif ub == None:
                    # TODO handle div by 0 case
                    relval = 1 - (lb / value)
                else:
                    relval = (value - lb) / (ub - lb)
                return colorfun(relval)
            else:
                # TODO for continuous color map, do we want to have a default constant color
                # or a default color function (ie grayscale or something?)
                return self.defaultColor

    def setMap(self, colorMap):
        pass

    def getMap(self):
        pass

    def setColor(self, contRange, colorfun = None):
        # if the input range overlaps an existing range, the new input range takes precedence
        numBounds = len(self.bounds)

        if contRange.lower == None:
            insertLoc = 0
        else:
            insertLoc = numBounds
            for ii in range(numBounds):
                if self.bounds[ii].lower == contRange.lower:
                    insertLoc = ii
                    break
                elif contRange.lower < self.bounds[ii].lower:
                    insertLoc = ii
                    break

        if insertLoc == numBounds:
            self.bounds.append(contRange)
            self.colors.append(colorfun)
            return
            
        if contRange.upper == None:
            finalLoc = numBounds-1
        else:
            finalLoc = 0
            for ii in range(numBounds):
                if self.bounds[ii].upper == contRange.upper:
                    finalLoc = ii+1
                    break
                elif self.bounds[ii].upper > contRange.upper:
                    finalLoc = ii-1
                    break

        if insertLoc < finalLoc:
            self.bounds = self.bounds[0:insertLoc] + self.bounds[finalLoc:]
            self.colors = self.colors[0:insertLoc] + self.colors[finalLoc:]
        if insertLoc > 0:
            if self.bounds[insertLoc-1].upper > contRange.lower:
                self.bounds[insertLoc-1].upper = contRange.lower
        if insertLoc + 1 < len(self.bounds):
            if self.bounds[insertLoc+1].lower < contRange.upper: 
                self.bounds[insertLoc+1].lower = contRange.upper
        self.bounds.insert(insertLoc, contRange)
        self.colors.insert(insertLoc, colorfun)

    def drawToFile(self, filename):
        import png
        if len(self.bounds) == 0:
            return
        numsamp = 1000
        numbounds = len(self.bounds)
        numsampperbound = numsamp / numbounds
        numsamp = numsampperbound * numbounds
        samps = []
        row = []

        b = self.bounds[0]
        if b.lower == None:
            lb = b.upper / 10
        else:
            lb = b.lower
        b = self.bounds[-1]
        if b.upper == None:
            ub = b.lower * 10
        else:
            ub = b.upper
        for i in range(numsamp):
            samps.append(lb + i * (ub-lb) / float(numsamp))

        for val in samps:
            color = self.getColor(val)
            row.append(int(color[0]))
            row.append(int(color[1]))
            row.append(int(color[2]))

        img = []
        for i in range(0, 50):
            img.append(row)

        f = open(filename, 'wb')
        w = png.Writer(numsamp,50,greyscale=False)
        w.write(f, img)
        f.close()

# some helper color utilities
def interp1(start, end, value, maximum):
    return start + (end - start) * value / maximum

def interp3(start, end, value, maximum):
    r0 = interp1(start[0], end[0], value, maximum)
    r1 = interp1(start[1], end[1], value, maximum)
    r2 = interp1(start[2], end[2], value, maximum)
    return (r0, r1, r2)

def lerp(start, end, value):
    # assumes inputs are RGB tuples
    # use algorithm from http://stackoverflow.com/questions/168838/color-scaling-function
    # convert everything to HSV
    # interpolate
    # convert back to RGB
    start_hsv = colorsys.rgb_to_hsv(start[0]/255.0,start[1]/255.0,start[2]/255.0)
    end_hsv = colorsys.rgb_to_hsv(end[0]/255.0,end[1]/255.0,end[2]/255.0)
    interp_hsv = interp3(start_hsv, end_hsv, value, 1)
    interp_rgb = colorsys.hsv_to_rgb(interp_hsv[0], interp_hsv[1], interp_hsv[2])
    return (int(interp_rgb[0] * 255), int(interp_rgb[1] * 255), int(interp_rgb[2] * 255))

def hex_to_rgb(hex):
    hex = hex.lstrip('#')
    lh = len(hex)
    return tuple(int(hex[i:i+lh/3], 16) for i in range(0,lh,lh/3))

# TODO create some default color functions here
# Note:  color functions assume that value will be in the range [0,1]
# This is done in order to work with the ContinuousColorMap concept above
def green_scale(value):
    return lerp((0,0,0), (0,255,0), value)

def green_to_red(value):
    return lerp((0,255,0), (255,0,0), value)

def red_to_blue(value):
    return lerp((255,0,0), (0,0,255), value)

def green(value):
    return (0, 255, 0)

class ColorMapWithCheckpoints:
    def __init__(self, colors = None):
        if colors:
            self.colors = colors
        else:
            # more yellowish to darker blue --- YlGnBu
            # take from MulteeSum, COLORMAP_2
            self.colors = ['#FFFFD9',
                           '#EDF8B1', 
                           '#C7E9B4', 
                           '#7FCDBB',
                           '#41B6C4',
                           '#1D91C0',
                           '#225EA8',
                           '#253494',
                           '#081D58']
        if len(self.colors) and self.colors[0][0] == '#':
            # convert to rgb tuple
            self.colors = [ hex_to_rgb(color) for color in self.colors ]

    def getColor(self, value):
        # pass this function into ContinuousColorMap.setColor as colorfun
        # value is in range 0 to 1
        # divide this range into equal pieces depending on number of self.colors
        numIntervals = len(self.colors) - 1
        interval = 1.0 / numIntervals
        for i in range(0, numIntervals):
            if value < (i+1) * interval:
                color = lerp(self.colors[i], self.colors[i+1], (value - (i)*interval) / interval)
                return color
        print 'no color found'

# TODO create some default color map constructors here
def categorical_map_1():
    # from MulteeSum
    return ['#FF7F00', 
            '#6A3D9A',
            '#1F78B4', 
            '#33A02C', 
            '#FB9A99',
            '#A6CEE3',
            '#B2DF8A',
            '#FDBF6F',
            '#CAB2D6']

def categorical_map_2():
    # from InSite
    return ['#1F78B4',   # blue
            '#33A02C',   # green
            '#E31A1C',   # red
            '#FF7F00',   # orange
            '#6A3D9A',   # purple
            '#D2D2D2', # clear old color (FEATURE_DEFAULT_COLOR)
            '#A6CEE3',   # lt blue
            '#B2DF8A',   # lt green
            '#FB9A99',   # lt red
            '#FDBF6F',   # lt orange
            '#CAB2D6',   # lt purple
            '#010101'] # clear all colors (FEATURE_CLEAR_COLOR
                                                                                   
def create_discrete_map(keys, cmap, cmap_type=None):
    if cmap_type == None:
        cmap_type = 'hex'
    if cmap_type == 'hex':
        cmap_rgb = [ hex_to_rgb(color) for color in cmap ]
    elif cmap_type == 'rgb':
        cmap_rgb = cmap
    else:
        # assume it will work
        cmap_rgb = cmap

    num_colors = len(cmap_rgb)
    cat_map = {}
    for key, idx in zip(keys, range(len(keys))):
        cat_map[key] = cmap_rgb[idx % num_colors]
    disc_map = DiscreteColorMap()
    disc_map.setMap(cat_map)
    return disc_map

if __name__ == "__main__":
    # png module is from http://pypi.python.org/pypi/pypng/0.0.13
    cmap1 = ContinuousColorMap()
    cmap1.setDefaultColor((130,130,130))
    crange = ContinuousRange()
    crange.lower = None
    crange.upper = .3
    cmap1.setColor(crange, green_scale)
    crange = ContinuousRange()
    crange.lower = .5
    crange.upper = .8
    cmap1.setColor(crange, green_to_red)
    crange = ContinuousRange()
    crange.lower = .9
    crange.upper = 1.5
    cmap1.setColor(crange, red_to_blue)
    crange = ContinuousRange()
    crange.lower = 1.6
    crange.upper = 1.9
    cmap1.setColor(crange, green)
    cmap1.drawToFile('custom_cont_map.png')

    cmap4 = ContinuousColorMap()
    checkpts = ColorMapWithCheckpoints()
    cmap4.setDefaultColor((130,130,130))
    crange = ContinuousRange()
    crange.lower = -10
    crange.upper = 20
    cmap4.setColor(crange, checkpts.getColor)
    cmap4.drawToFile('map_with_checkpoints.png')

    # create categorical map
    cat1 = ['a','b','c','d','e','f','g','h','i']
    cmap2 = create_discrete_map(cat1, categorical_map_1(),'hex')
    cmap2.drawToFile('cat1.png')
        
    cat2 = ['a','b','c','d','e','f','g','h','i','j','k','l']
    cmap3 = create_discrete_map(cat2, categorical_map_2(),'hex')
    cmap3.drawToFile('cat2.png')

