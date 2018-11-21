# How to build the test widget using app-templates/cmake-apps-module

## Defining CMake targets

Now that the test tree has been created, in each directory you have to create
a `CMakeLists.txt` file to hold the CMake's target definition. For each target
you need to specify a **LABELS** depending on the purpose of the files for each
directory. There are more explanations about using the *cmake-apps-module* (the
former *app-templates* submodule) in the [documentation website](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/sdk-devkit/docs/part-2/2_4-Use-app-templates.html#using-cmake-template-macros).

Here is a cheat sheet to map the **LABELS** target for each classic test tree
directory:

* `etc` uses the label **TEST-CONFIG**
* `fixtures` uses the label **TEST-DATA**
* `tests` uses the label **TEST-DATA**

i.e for the `etc` folder:

```cmake
PROJECT_TARGET_ADD(afb-test-config)

    file(GLOB CONF_FILES "*.json")

    add_input_files("${CONF_FILES}")

    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES
        LABELS "TEST-CONFIG"
        OUTPUT_NAME ${TARGET_NAME}
    )
```

> **CAUTION**: make sure that you have CMakeLists files that include your
> subdirectories target (cf: previous chapter `Write the tests`).

## Build the test widget

By default, the test widget is not built, you have to specify that you want to
build it or use a special target.

### Building at the same time than classic widget

Specify the option `BUILD_TEST_WGT=TRUE` when you configure your build.

ie:

```bash
cd build
cmake -DBUILD_TEST_WIDGET=TRUE ..
make
make widget
```

### Building separately only the test widget

Just use the target `test_widget` after a classic build.

ie:

```bash
cd build
cmake ..
make
make test_widget
```