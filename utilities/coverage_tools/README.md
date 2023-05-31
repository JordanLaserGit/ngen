This tool set is designed to produce automated test coverage report using lcov that is based on the cmake options for a given c++ project, with specific design decisions made with the Next Generation Water Model in mind. The aim is for this tool to generate a test coverage report using all googletests that should be executed given the cmake options for a partiular build. The project was built to run on Linux, specifically Fedora although the distro shouldn't matter.

# Intructions
1) Ensure [Dependencies](#dependencies) have been installed.
2) Adjust options in [config](#/test_coverage/test_coverage.json), see [config example](https://github.com/JordanLaserGit/coverage_tools/blob/main/data/config_example.py)
3) [Run it!](#run-it)

## Run it
```shell
bash test_coverage.sh test_coverage.json project_path
```
## Dependencies
1) jq
2) python 3.8

```shell
sudo yum install jq python38
```

# Workflow explanation
A shell script, test_coverage.sh manages the main workflow. The steps are:
1) Search project directory for all test files
2) Cull list of test files based on cmake options
3) Create a text file that cmake will read in that is formatted for input into add_custom_test() ('test_name'-text.txt)
4) Create a text file that summarizes the test files (which were used and which were not) ('test_name'_file_summary.txt)
5) Generate the cmake build system
6) Execute test, collect coverage data, and generate a html of the coverage report.

# Notes
The output text file will be placed in test/coverage and is designed to be read by /test/CMakeLists.txt. See the [example](https://github.com/JordanLaserGit/coverage_tools/blob/main/data/CMakeLists_example.txt)

The code coverage report is output to project_path/"'test_name'-build"/test/lcoverage_'test_name'/index.html



