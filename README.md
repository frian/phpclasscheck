phpclasstest.pl
===============

A perl script that checks if method parameters and properties are declared in PHP classes.

what it does
------------

* list methods
* list properties
* check if method parameters are declared
* check if properties are declared

usage
-----

usage : ./phpclasscheck.pl [-c|-l] [-m|-p] [-v] file or folder

    -c    check
    -l    list (default)
    -m    methods only
    -p    properties only
    -v    verbose

examples
--------

list properties and methods

    phpclasscheck.pl tests/dummy/

list methods only

    phpclasscheck.pl -m tests/dummy/

check properties and methods

    phpclasscheck.pl -c tests/dummy/ClassParamterNotDeclared.php

check properties only

    phpclasscheck.pl -cp tests/dummy/ClassParamterNotDeclared.php
