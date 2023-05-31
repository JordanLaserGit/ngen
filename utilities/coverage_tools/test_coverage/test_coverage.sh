# Usage:
# command <arg1> <arg2> <arg3>
# bash test_coverage.sh <path to test_coverage.json> <path to test_libs.json> <path to project>

# Read in json
# Need jq for this! sudo yum install jq
test_name=($(jq -r '.test_name' $1))
verbose=($(jq -r '.verbose' $1))

test_txt_file="coverage/$test_name-text.txt"
build_args=()
build_args+=("-DTEST_FILE=${test_txt_file}")
while IFS== read -r key value; do
    build_args+=("-$key=$value")
done < <(jq -r '.options | to_entries | .[] | .key + "=" + .value ' $1)

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
build_args+=("-B")
build_args+=("$build_name")
build_args+=("-S")
build_args+=(".")
cmake "${build_args[@]}" \
|| { echo 'Generating build folder failed' ; exit 1; }

# Build test
echo "Building test"
cmake --build $build_folder --target $test_name -- -j 4 \
|| { echo 'Building the test failed' ; exit 1; }

# Execute test and get coverage
echo "Generating coverage report"
cd $build_folder
make "gcov_$test_name" || make "lcov_$test_name"
