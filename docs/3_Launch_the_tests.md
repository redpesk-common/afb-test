# How to launch the tests?

## Natively during the development

It could be convenient to be able to test the software that you are currently
developing. Then you can ensure that your modifications haven't introduced
regressions, bugs, etc. This depends upon your tests of course.

As previously saw, you need the `test binding` to be able to launch the tests and
you need also to have the `afb-test` binding installed and the `afb-binder` to be able to execute your tests.

Please refer to the [previous chapter](./2_The_test_widget.html#build-the-test-binding) in order to build your project natively.

To prepare all files needed for the test launch then use the `afm-test` script:

```bash
$ afm-test --help

# Usage of afm-test command line utility
Usage: afm-test <binding-rootdir> <test-rootdir> [-a|--allinone] [-p|--clean-previous] [-t|--timeout <X>] [-l|--lavaoutput] [-c|--coverage] [-o|--coverage-dir <X>] [-e|--exclude <X>] [-i|--include <X>] [-h|--help] [-d|--debug]
binding-rootdir: path to the binding folder
test-rootdir: path to the test binding folder file
-a|--allinone: All In One (1 binder for the test) for some specific debug, use carefully.
-p|--clean-previous: Clean previous test and coverage results and exit.
-t|--timeout: timeout in second. (Default 300 seconds)
-l|--lavaoutput: Flags indicating the binding to add Lava special test markers.
-c|--coverage: Deploy coverage reports once the tests are completed.
-o|--coverage-dir: Choose coverage directory
-e|--exclude: exclude a test, can be use more than one time. (disabled if only one test verb found)
-i|--include: only include a test, can be use more than one time. (disabled if only one test verb found)
-d|--debug: debug mode.
-h|--help: Print help

# Launching the tests inside your build project directory
afm-test package package-test
```

### Example with the helloworld-binding test suite

Prepare the launch building the `test binding`:

```bash
$ cd build
# Cleaning the previous build files
$ rm -rf *
# Configuration step
$ cmake -DBUILD_TEST_WGT=TRUE ..
CMake Warning (dev) in CMakeLists.txt:
  No project() command is present.  The top-level CMakeLists.txt file must
  contain a literal, direct call to the project() command.  Add a line of
  code such as

    project(ProjectName)

  near the top of the file, but after cmake_minimum_required().

  CMake is pretending there is a "project(Project)" command on the first
  line.
This warning is for project developers.  Use -Wno-dev to suppress it.

-- The C compiler identification is GNU 11.3.0
-- The CXX compiler identification is GNU 11.3.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
Distribution detected (separated by ';' choose one of them) debian
Include: /usr/share/cmake-3.22/Modules/CMakeAfbTemplates/cmake/cmake.d/01-build_options.cmake
-- Found PkgConfig: /usr/bin/pkg-config (found version "0.29.2") 
-- Checking for module 'json-c'
--   Found json-c, version 0.15
-- Checking for module 'afb-binding'
--   Found afb-binding, version 4.1.0
-- Checking for module 'afb-libhelpers'
--   Found afb-libhelpers, version 10.0.0
-- Checking for module 'libsystemd'
--   Found libsystemd, version 249
Include: /usr/share/cmake-3.22/Modules/CMakeAfbTemplates/cmake/cmake.d/02-variables.cmake
-- Check gcc_minimal_version (found gcc version 11.3.0)         (found g++ version 11.3.0)
Include: /usr/share/cmake-3.22/Modules/CMakeAfbTemplates/cmake/cmake.d/03-macros.cmake
Include: /usr/share/cmake-3.22/Modules/CMakeAfbTemplates/cmake/cmake.d/04-extra_targets.cmake
-- Overwrite the CMAKE default install prefix with /root/opt
.. Warning: RSYNC_TARGET RSYNC_PREFIX not defined 'make remote-target-populate' not instanciated
-- Notice: Using default test widget configuration\'s file.
-- If you want to use a customized test-config.xml template then specify TEST_WIDGET_CONFIG_TEMPLATE in your config.cmake file.
.. Warning: RSYNC_TARGET not defined 'make widget-target-install' not instanciated
-- Configuring done
-- Generating done
-- Build files have been written to: /root/helloworld-binding/build

# Run make
$ make
[  3%] Built target autobuild
[  7%] Generating test-files
Warning: LUA_CHECKER not found. Not verification made on files !
[  7%] Built target test-files
[ 11%] Generating package-test/var/test-files
[ 11%] Built target project_populate_test-files
[ 14%] Generating package
[ 18%] Generating package/bin
[ 22%] Generating package/etc
[ 25%] Generating package/lib
[ 29%] Generating package/htdocs
[ 33%] Generating package/var
[ 33%] Built target prepare_package
[ 37%] Generating package-test/bin
[ 40%] Generating package-test/etc
[ 44%] Generating package-test/lib
[ 48%] Generating package-test/htdocs
[ 55%] Built target prepare_package_test
[ 59%] Building C object helloworld-skeleton/CMakeFiles/helloworld-skeleton.dir/helloworld-service-binding.c.o
[ 62%] Linking C shared module afb-helloworld-skeleton.so
[ 62%] Built target helloworld-skeleton
[ 66%] Generating package/lib/afb-helloworld-skeleton.so
[ 66%] Built target project_populate_helloworld-skeleton
[ 70%] Building C object helloworld-subscribe-event/CMakeFiles/helloworld-subscribe-event.dir/helloworld-event-service-binding.c.o
/root/helloworld-binding/helloworld-subscribe-event/helloworld-event-service-binding.c: In function 'timerCount':
/root/helloworld-binding/helloworld-subscribe-event/helloworld-event-service-binding.c:33:13: warning: variable 'listeners' set but not used [-Wunused-but-set-variable]
   33 |         int listeners;
      |             ^~~~~~~~~
[ 74%] Linking C shared module afb-helloworld-subscribe-event.so
[ 74%] Built target helloworld-subscribe-event
[ 77%] Generating package/lib/afb-helloworld-subscribe-event.so
[ 77%] Built target project_populate_helloworld-subscribe-event
[ 81%] Generating htdocs
[ 81%] Built target htdocs
[ 85%] Generating package/htdocs/htdocs
[ 85%] Built target project_populate_htdocs
[ 88%] Generating helloworld-config
Warning: JSON_CHECKER not found. Not verification made on files !
[ 88%] Built target helloworld-config
[ 92%] Generating package-test/etc/helloworld-config
[ 92%] Built target project_populate_helloworld-config
[ 96%] Generating fixture-files
Warning: LUA_CHECKER not found. Not verification made on files !
[ 96%] Built target fixture-files
[100%] Generating package-test/var/fixture-files
[100%] Built target project_populate_fixture-files
[100%] Built target populate
++ Debug from afb-binder --port=1234  --ldpaths=package --workdir=. --roothttp=../htdocs --verbose 
[100%] Built target helloworld-binding_build_done

# Run make widget
$ make widget
Warning: LUA_CHECKER not found. Not verification made on files !
[  2%] Built target test-files
[  5%] Generating package-test/var/test-files
[  5%] Built target project_populate_test-files
[  8%] Generating package/bin
[ 11%] Generating package/etc
[ 22%] Built target prepare_package
[ 25%] Generating package-test/bin
[ 27%] Generating package-test/lib
[ 38%] Built target prepare_package_test
Consolidate compiler generated dependencies of target helloworld-skeleton
[ 44%] Built target helloworld-skeleton
[ 47%] Built target project_populate_helloworld-skeleton
Consolidate compiler generated dependencies of target helloworld-subscribe-event
[ 52%] Built target helloworld-subscribe-event
[ 55%] Built target project_populate_helloworld-subscribe-event
[ 58%] Built target htdocs
[ 61%] Generating package/htdocs/htdocs
[ 61%] Built target project_populate_htdocs
Warning: JSON_CHECKER not found. Not verification made on files !
[ 63%] Built target helloworld-config
[ 66%] Generating package-test/etc/helloworld-config
[ 66%] Built target project_populate_helloworld-config
Warning: LUA_CHECKER not found. Not verification made on files !
[ 69%] Built target fixture-files
[ 72%] Generating package-test/var/fixture-files
[ 72%] Built target project_populate_fixture-files
[ 72%] Built target populate
[ 75%] Generating package/icon.png
[ 77%] Generating package/config.xml
[ 80%] Built target widget_files
[ 83%] Generating package-test/icon.png
[ 86%] Generating package-test/config.xml
[ 88%] Generating package-test/bin
[ 91%] Generating package-test/bin/launcher
[ 94%] Built target test_widget_files
[ 97%] Generating helloworld-binding-test.wgt
Warning: Test widget will be built using Zip, NOT using the Application Framework widget pack command.
  adding: bin/ (stored 0%)
  adding: bin/launcher (deflated 50%)
  adding: config.xml (deflated 57%)
  adding: etc/ (stored 0%)
  adding: etc/aft-helloworld.json (deflated 73%)
  adding: htdocs/ (stored 0%)
  adding: icon.png (stored 0%)
  adding: lib/ (stored 0%)
  adding: var/ (stored 0%)
  adding: var/mapi_helloworld.lua (deflated 43%)
  adding: var/mapi_tests.lua (deflated 50%)
  adding: var/helloworld.lua (deflated 54%)
[ 97%] Built target test_widget
[100%] Generating helloworld-binding.wgt
Warning: Widget will be built using Zip, NOT using the Application Framework widget pack command.
  adding: bin/ (stored 0%)
  adding: config.xml (deflated 52%)
  adding: etc/ (stored 0%)
  adding: htdocs/ (stored 0%)
  adding: htdocs/assets/ (stored 0%)
  adding: htdocs/assets/background_iot_bzh_light.jpg (deflated 16%)
  adding: htdocs/assets/favicon.ico (deflated 39%)
  adding: htdocs/assets/iot-bzh-logo-small.png (deflated 0%)
  adding: htdocs/index.html (deflated 62%)
  adding: htdocs/AFB-websock.js (deflated 70%)
  adding: htdocs/iotbzh-Binding.js (deflated 64%)
  adding: htdocs/iotbzh-Binding.css (deflated 47%)
  adding: icon.png (stored 0%)
  adding: lib/ (stored 0%)
  adding: lib/afb-helloworld-skeleton.so (deflated 66%)
  adding: lib/afb-helloworld-subscribe-event.so (deflated 63%)
  adding: var/ (stored 0%)
++ Install widget file using in the target : afm-util install helloworld-binding.wgt
[100%] Built target widget
```

From now, you can now start the tests with the `afm-test` script of `afb-test` package

```bash
$ afm-test package package-test/
/usr/bin/afm-test: line 241: 14342 Killed                  "${BINDER}" --name="${PROCNAME}" --port=${PORTSERVICE} --workdir="${SERVICEPACKAGEDIR}" --ldpaths=. "${SOCKETSERVER[@]}" -vvv &> "${LOGFILESERVICE}"
---------------- Test result ------------------
Test result from: /root/helloworld-binding/build/package-test/mapi_tests.tap
# Ran 4 tests in 0.001 seconds, 4 successes, 0 failures, 1 skipped

Test result from: /root/helloworld-binding/build/package-test/helloworld.tap
# Ran 5 tests in 0.001 seconds, 5 successes, 0 failures

-----------------------------------------------
To see which test passed or not, see test files.
```

## Launch test on a target board

### Using Redtests

If you want to launch your tests on target, the easier option is to pass through [Redtests]({% chapter_link redtests-quickstart-doc.introduction %}).
Indeed, in this case, the only things you need to do is to run the run-redtest script, provided by the redtest package.

For the `helloworld-binding` package, the steps to follow are listed here below.

```bash
# Installation of the helloworld-binding
$ sudo dnf install helloworld-binding
# Installation of the redtest corresponding package
$ sudo dnf install helloworld-binding-redtest
# Run the tests (through redtests)
$ /usr/libexec/redtest/helloworld-binding/run-redtest
find: ‘/home/0/app-data/helloworld-binding-test’: No such file or directory
PASS: helloworld-binding-test started with pid=9425
~~~~~ Begin testPingSuccess ~~~~~
~~~~~ End testPingSuccess ~~~~~
PASS: 1 testPingSuccess.testFunction
PASS: 2 testPingSuccessAndResponse.testFunction
PASS: 3 testPingSuccessCallback.testFunction
PASS: 4 testPingError.testFunction
PASS: 5 testPingErrorAndResponse.testFunction
# Ran 5 tests in 0.001 seconds, 5 successes, 0 error
PASS: 1 TestListSuccess.testFunction
PASS: 2 TestSubscribeSuccess.testFunction
PASS: 3 TestUnsubscribeSuccess.testFunction
PASS: 4 TestWrongVerbError.testFunction
PASS: 5 # SKIP Test (mapi-helloworld, skipped_verb, { } , nil) is skipped
# Ran 4 tests in 0.001 seconds, 4 successes, 0 failures, 1 skipped
PASS: helloworld-binding-test killed
```

### Manually

If you do not want to use Redtests, you can also build the test package and then run your tests manually on the target.
Once you have built your test package, and that you have added your repository to the target, you can install your package as well as its "test" sub-package.

From that, you can follow the steps here below to run manually the tests on the target. The example taken here is still helloworld-binding.

```bash
# Installation of the main binding
$ sudo dnf install helloworld-binding

# Installation of the test binding
$ sudo dnf install helloworld-binding-test

# List the available bindings on target
$ afm-util list
[
  {
    "description":"Provide an Helloworld Binding",
    "name":"helloworld-binding",
    "shortname":"",
    "id":"helloworld-binding",
    "version":"0.0",
    "author":"Iot-Team <frederic.marec@iot.bzh>",
    "author-email":"",
    "width":"",
    "height":"",
    "icon":"/var/local/lib/afm/applications/helloworld-binding/icon.png",
    "http-port":30002
  },
  {
    "description":"Test widget used to launch tests for the project helloworld-binding",
    "name":"helloworld-binding-test",
    "shortname":"",
    "id":"helloworld-binding-test",
    "version":"0.0",
    "author":"Romain Forlot <romain.forlot@iot.bzh>",
    "author-email":"",
    "width":"",
    "height":"",
    "icon":"/var/local/lib/afm/applications/helloworld-binding-test/icon.png",
    "http-port":30003
  }
]

# Check that our main binding is running
$ afm-util ps
[
]

# If the binding is not in the list before, start it here
$ afm-util start helloworld-binding
9312
$ afm-util ps
[
  {
    "runid":9312,
    "pids":[
      9312
    ],
    "state":"running",
    "id":"helloworld-binding"
  }
]

# Start the tests here
$ afm-test helloworld-binding-test
find: ‘/home/0/app-data/helloworld-binding-test’: No such file or directory
PASS: helloworld-binding-test started with pid=9356
~~~~~ Begin testPingSuccess ~~~~~
~~~~~ End testPingSuccess ~~~~~
PASS: 1 testPingSuccess.testFunction
PASS: 2 testPingSuccessAndResponse.testFunction
PASS: 3 testPingSuccessCallback.testFunction
PASS: 4 testPingError.testFunction
PASS: 5 testPingErrorAndResponse.testFunction
# Ran 6 tests in 0.001 seconds, 5 successes, 0 error
PASS: 1 TestListSuccess.testFunction
PASS: 2 TestSubscribeSuccess.testFunction
PASS: 3 TestUnsubscribeSuccess.testFunction
PASS: 4 TestWrongVerbError.testFunction
PASS: 5 # SKIP Test (mapi-helloworld, skipped_verb, { } , nil) is skipped
# Ran 4 tests in 0.001 seconds, 4 successes, 0 failures, 1 skipped
PASS: helloworld-binding-test killed

# End the main binding
$ afm-util terminate helloworld-binding
true
```
