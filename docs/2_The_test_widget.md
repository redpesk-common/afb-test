# How to build the test binding using "AFB CMake Modules"

## Defining CMake targets

Now that the test tree has been created, in each directory you have to create
a `CMakeLists.txt` file to hold the CMake's target definition. For each target
you need to specify a **LABELS** depending on the purpose of the files for each
directory. There are more explanations about using the *afb-cmake-modules* in the ["AFB CMake Modules"]({% chapter_link cmake-apps-module.overview %}) chapter.

Here is a cheat sheet to map the **LABELS** target for each classic test tree
directory:

* `etc` uses the label **TEST-CONFIG**
* `fixtures` uses the label **TEST-DATA**
* `tests` uses the label **TEST-DATA**

i.e for the `etc` folder:

```cmake
PROJECT_TARGET_ADD(helloworld-config)

    file(GLOB CONF_FILES "*.json")

    add_input_files("${CONF_FILES}")

    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES
    LABELS "TEST-CONFIG"
    OUTPUT_NAME ${TARGET_NAME}
    )
```

> **CAUTION**: make sure that you have CMakeLists files that include your
> subdirectories target (cf: previous chapter ["Write the tests"](./1_Write_the_tests.html)).

## Build the test binding

By default, the test binding is built.
Therefore, simply build the binding as usual.

```bash
# Go in your project directory
cd <your_binding>/
# Make a build directory if it does not already exist
mkdir -p build
# Go in your build directory
cd build
# Run the cmake part
cmake ..
# Run the make part
make
```

After running the command lines given here above, in the `build/` directory, you can see now, the directories named `package/` and `package-test/`.
