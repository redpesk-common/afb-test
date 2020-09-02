# Binding tester

You'll find the doc [here](http://docs.automotivelinux.org/docs/en/master/apis_services/reference/afb-test/0_Installation.html)

## Coverage deployment

In order to generate the test coverage report for your binding you should activate the cmake coverage option.

```sh
mkdir build
cd build
cmake -DBUILD_TEST_WGT=TRUE -DCMAKE_BUILD_TYPE=coverage ..
make widget
```

Then you can use the coverage deployment option of the afm-test util.
```sh
afm-test package package-test -c
```

Once the coverage report has been deployed you can open the user friendly html report with:

```sh
xdg-open /build/coverage/index.html
```
