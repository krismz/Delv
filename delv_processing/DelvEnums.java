// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

// implement AttributeType enum as a straight class since processing.js doesn't like enums
class AttributeType {
    public static final String[] _types = new String[] { "UNSTRUCTURED", "CATEGORICAL", "CONTINUOUS", "FLOAT_ARRAY" };
    public static final AttributeType UNSTRUCTURED = new AttributeType(_types[0]);
    public static final AttributeType CATEGORICAL = new AttributeType(_types[1]);
    public static final AttributeType CONTINUOUS = new AttributeType(_types[2]);
    public static final AttributeType FLOAT_ARRAY = new AttributeType(_types[3]);

    String _val;

    AttributeType() {
        this(UNSTRUCTURED);
    }

    AttributeType(AttributeType val) {
        _val = val._val;
    }

    AttributeType(String val) {
        boolean found = false;
        for (int i = 0; i < _types.length; i++) {
            if (val.equals(_types[i])) {
                found = true;
                break;
            }
        }
        if (!found) {
            throw new IllegalArgumentException(val+" is not a valid AttributeType");
        }
        _val = val;
    }

    boolean equals(AttributeType other) {
        if (_val.equals(other._val)) {
            return true;
        } else {
            return false;
        }
    }
}

