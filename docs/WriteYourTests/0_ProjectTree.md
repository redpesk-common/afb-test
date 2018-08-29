# Test architecture

## Files tree and organization

```tree

"test"
   +-- etc
   |   +-- aft-aftest-self.json
   |   +-- CMakeLists.txt
   +-- fixture
   |   +-- a-script.sh
   |   +-- any-needed.data
   |   +-- CMakeLists.txt
   |   +-- data.json
   +-- tests
   |   +-- CMakeLists.txt
   |   +-- test01.lua
   |   +-- test02.lua
   |   ...

```

To integrate tests in your project, create a **test** subfolder at your project
root directory and fulfill it with appropriate files like shown as above.

To make it quick you'll have to write your tests using lua language and store it
in the **tests** (with an "s") folder (as shown above) and change *aft-aftest-self.json* or make a new .json
file to be able to launch your tests. Note that if you make a new json file,
its name has to start with "aft-" followed by the binder's name. (e.g.
aft-low-can for the low-level-can-service)

*aft-aftest-self.json* is a conguration file. You'll see in the next section
how to write a proper configuration file.

## Integration with CMake using App-templates

To make the link between your test files, config files, data files
and the test binding,
you will have to integrate them with CMake using the App-templates.

First you will have to create your CMake target using **PROJECT_TARGET_ADD**
with your target name as parameter, it will include the target to
your project.

Then add your data files using **add_input_files** with your files in
parameter.

Use **SET_TARGET_PROPERTIES** to fit the targets properties for macros
usage. Here you have to specify what type of your targets you want to include
in the widget package using the property **LABELS**. It will most likely either
be *TEST-DATA* or *TEST-CONFIG*.

Here is the LABELS list:

- **TEST-CONFIG**: JSON configuration files that will be used by the afb-test
 binding to know how to execute tests.
- **TEST-DATA**: Resources used to test your binding. It is at least your test
 plan and also could be fixtures and any files needed by your tests. These files
 will appear in a separate test widget.
- **TEST-PLUGIN**: Shared library meant to be used as a binding
 plugin. Binding would load it as a plugin to extend its functionalities. It
 should be named with a special extension that you choose with SUFFIX cmake
 target property or it'd be **.ctlso** by default.
- **TEST-HTDOCS**: Root directory of a web app. This target has to build its
 directory and put its files in the ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
- **TEST-EXECUTABLE**: Entry point of your application executed by the AGL
 Application Framework
- **TEST-LIBRARY**: An external 3rd party library bundled with the binding for its
 own use in case the platform doesn't provide it.

Here is a mapping between LABELS and directories where files will be placed in
the widget:

- **EXECUTABLE** : \<wgtrootdir\>/bin
- **BINDING-CONFIG** : \<wgtrootdir\>/etc
- **BINDING** | **BINDINGV2** | **BINDINGV3** | **LIBRARY** : \<wgtrootdir\>/lib
- **PLUGIN** : \<wgtrootdir\>/lib/plugins
- **HTDOCS** : \<wgtrootdir\>/htdocs
- **BINDING-DATA** : \<wgtrootdir\>/var
- **DATA** : \<wgtrootdir\>/var

And about test dedicated **LABELS**:

- **TEST-EXECUTABLE** : \<TESTwgtrootdir\>/bin
- **TEST-CONFIG** : \<TESTwgtrootdir\>/etc
- **TEST-PLUGIN** : \<TESTwgtrootdir\>/lib/plugins
- **TEST-HTDOCS** : \<TESTwgtrootdir\>/htdocs
- **TEST-DATA** : \<TESTwgtrootdir\>/var

> **TIP** you should use the prefix _afb-_ with your **BINDING* targets which
> stand for **Application Framework Binding**.

You will find in depth explanations about it [here](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/sdk-devkit/docs/part-2/2_4-Use-app-templates.html#targets-properties).

Here is an example of a proper CMake file:

```CMake
PROJECT_TARGET_ADD(test-files)

    file(GLOB LUA_FILES "*.lua")
    add_input_files("${LUA_FILES}")

    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES
    LABELS "TEST-DATA"
    OUTPUT_NAME ${TARGET_NAME}
    )
```