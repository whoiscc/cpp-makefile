# cpp-makefile

Makefile template for C++ project. The original Makefile is extracted from [specpaxos].

[specpaxos]: https://github.com/UWSysLab/specpaxos/blob/master/Makefile

Features:
* Allow append flags (e.g. `-O3`) from command line.
* Out-of-tree building, default build to `.obj` directory.
* Automatically dependency management for source files, only need to list dependent objects for each target.
* Googletest integrated.
* Pretty printing.
* Extensible by including sub-Makefiles.
