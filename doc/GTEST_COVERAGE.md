# Code Coverage of GoogleTests using gcov and lcov

## Steps to generate code coverage for any test built in ngen/test/CMakeLists.txt


1. From the ngen root folder, construct the build system with:

`
cmake -DCMAKE_BUILD_TYPE=Debug -DCOVERAGE=true -B cmake-build-debug -S .
`

2. From the binary directory `cmake-build-debug`, make the gcov target specific to the test you want coverage of:

`
make gcov_${TEST_NAME}
`

For example with test_all: `make gcov_test_all`


3. Then call lcov to create the code coverage report:

`
make lcov_${TEST_NAME}
`

For example with test_all: `make lcov_test_all`

4. To view the code coverage report open the following file in a web browser:

`
/ngen/cmake-build-debug/test/lcoverage_${TESTNAME}/index.html
`

For example with test_all: `/ngen/cmake-build-debug/test/lcoverage_test_all/index.html`