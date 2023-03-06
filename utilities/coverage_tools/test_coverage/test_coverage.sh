# Usage:
# command <arg1> <arg2> <arg3>
# bash test_coverage.sh <path to test_coverage.json> <path to test_libs.json> <path to project>

# Read in json
# Need jq for this! sudo yum install jq
typeset -A build_options
while IFS== read -r key value; do
    build_options["$key"]="$value"
done < <(jq -r '.options | to_entries | .[] | .key + "=" + .value ' $1)

test_name=($(jq -r '.test_name' $1))
verbose=($(jq -r '.verbose' $1))

config=$1
project_root=$2

echo "CONFIG:        $config"
echo "PROJECT ROOT:  $project_root"

# Create folder to store test files
mkdir -p "$project_root/test/coverage"

# Generate test -text.txt to be read by CMakeLists.txt
cov_dir=$(dirname "$config")
echo "COVERAGE DIR:  $cov_dir"
python_script="$cov_dir/test_coverage.py"
python -u $python_script $config $project_root

# Change working directory to project root
cd $project_root

# Remove any previous build
build_name=$test_name"-build"
build_folder="$PWD/$build_name"
echo "Build folder $build_folder"

# Generate the build folder
test_txt_file="coverage/$test_name-text.txt"
cmake -DTEST_FILE=$test_txt_file -DBMI_C_LIB_ACTIVE=${build_options[DBMI_C_LIB_ACTIVE]} -DBMI_FORTRAN_ACTIVE=${build_options[DBMI_FORTRAN_ACTIVE]} -DCMAKE_BUILD_TYPE=${build_options[DCMAKE_BUILD_TYPE]} -DCOVERAGE=${build_options[DCOVERAGE]} -DET_QUIET=${build_options[DET_QUIET]} -DLSTM_TORCH_LIB_ACTIVE=${build_options[DLSTM_TORCH_LIB_ACTIVE]} -DMPI_ACTIVE=${build_options[DMPI_ACTIVE]}  -DNGEN_ACTIVATE_PYTHON=${build_options[DNGEN_ACTIVATE_PYTHON]} -DNGEN_ACTIVATE_ROUTING=${build_options[DNGEN_ACTIVATE_ROUTING]} -DNGEN_QUIET=${build_options[DNGEN_QUIET]} -DUDUNITS_ACTIVE=${build_options[DUDUNITS_ACTIVE]} -DUDUNITS_QUIET=${build_options[DDUDUNITS_QUIET]} -DQUIET=${build_options[DQUIET]} -B $build_name -S .

# Build test
cmake --build $build_folder --target test-$test_name -- -j 4

# Execute test and get coverage
cd $build_folder && make "gcov_$test_name" || make "lcov_$test_name"
