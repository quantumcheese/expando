# expando

[![Build Status](https://travis-ci.org/quantumcheese/expando.svg?branch=master)](https://travis-ci.org/quantumcheese/expando) [![codecov.io](https://codecov.io/gh/quantumcheese/expando/branch/master/graphs/badge.svg)](https://codecov.io/gh/quantumcheese/expando/branch/master)

----------

Encodes a single file using a very simple (de-)compression algorithm.

Usage:

    expando [-c | -u] -i <input file> -o <output file>
        -c compress
        -u expand (de-/un-compress)

    Future goals:
     - create compressed multi-file archives
     - use more concise file format
