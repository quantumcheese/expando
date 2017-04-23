# inflato

[![Build Status](https://travis-ci.org/quantumcheese/inflato.svg?branch=master)](https://travis-ci.org/quantumcheese/inflato) [![codecov.io](https://codecov.io/gh/quantumcheese/inflato/branch/master/graphs/badge.svg)](https://codecov.io/gh/quantumcheese/inflato/branch/master)

----------

Encodes a single file using a very simple (de-)compression algorithm.

Usage:

    inflato [-c | -u] -i <input file> -o <output file>
        -c compress
        -u inflate (de-/un-compress)

    Future goals:
     - create compressed multi-file archives
     - use more concise file format
