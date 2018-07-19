# afb-test architecture

```tree
+-- afb_helpers
+-- app-controller-submodule
+-- build
+-- conf.d
|    +-- app-templates
|    +-- autobuild
|    +-- cmake
|    +-- controller
|    |  +-- etc
|    |  |   +-- aft-mapis.json
|    |  |   +-- aft-test.json
|    |  |   +-- CMakeLists.txt
|    |  +-- lua.d
|    |  |   +--aft.lua
|    |  |   +--aftTest.lua
|    |  |   ...
|    |  +-- CMakeLists.txt
|    +--wgt
+-- src
+-- .gitignore
+-- .gitmodules
+-- .gitreview
+-- CMakeLists.txt
+-- LICENSE-2.0.txt
+-- README.md
```

To write your tests we will only touch to the **controller** folder, specifically
to the **lua.d** and to the **etc** folders.

To make it quick you'll have to write your tests using lua language and store it
in the lua.d folder and change aft-test.json or make a new .json file to be able
to launch your tests, not that if you make a new json file, his name has to start
with "aft-" followed by the binder's name. (e.g. aft-test for the afb-test)