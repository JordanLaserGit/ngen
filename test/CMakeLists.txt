
project(TestNextGen)

add_subdirectory(googletest)
include_directories(${gtest_SOURCE_DIR}/include ${gtest_SOURCE_DIR})
include_directories(${gmock_SOURCE_DIR}/include ${gmock_SOURCE_DIR})
include_directories(${PROJ_ROOT_INCLUDE_DIR})


if (NGEN_ACTIVATE_PYTHON)
    include_directories(${PROJECT_SOURCE_DIR}/extern/pybind11/include)
    add_compile_definitions(NGEN_BMI_PY_TESTS_ACTIVE)
endif()

if(MPI_ACTIVE)
    add_compile_definitions(NGEN_MPI_TESTS_ACTIVE)
endif()


add_compile_definitions(NGEN_BMI_CPP_LIB_TESTS_ACTIVE)


if(BMI_C_LIB_ACTIVE)
    add_compile_definitions(NGEN_BMI_C_LIB_TESTS_ACTIVE)
endif()


if(BMI_FORTRAN_ACTIVE)
    add_compile_definitions(NGEN_BMI_FORTRAN_LIB_TESTS_ACTIVE)
endif()


if(LSTM_TORCH_LIB_ACTIVE)
    add_compile_definitions(LSTM_TORCH_LIB_TESTS_ACTIVE)
endif()


if(NGEN_ACTIVATE_ROUTING)
    add_compile_definitions(ROUTING_PYBIND_TESTS_ACTIVE)
endif()


if(NETCDF_ACTIVE)
    add_compile_definitions(NETCDF_ACTIVE)
endif()


# Coverage
# add_definitions(-fprofile-arcs -ftest-coverage)
set(CMAKE_CXX_FLAGS "-std=c++14 -g -O0 -Wall -fprofile-arcs -ftest-coverage")
set(CMAKE_CXX_OUTPUT_EXTENSION_REPLACE ON)


# Get test coverage for test_all
function(get_coverage TESTNAME)

    # Create the gcov target. Run coverage tests with 'make gcov_${TESTNAME}'
    add_custom_target("gcov"        
        COMMAND ${CMAKE_MAKE_PROGRAM} test
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )  

    add_dependencies("gcov" ${TESTNAME})

    # Create the lcov target. Run result tests with 'make lcov_${TESTNAME}'
    add_custom_target("lcov"
        COMMAND mkdir -p "lcoverage_${TESTNAME}"
        )

    add_custom_command(TARGET "lcov"
        COMMAND echo "=================== LCOV ===================="
        COMMAND echo "Cleaning previous lcov"
        COMMAND rm -f "lcoverage_${TESTNAME}/main_coverage.info"
        COMMAND echo "-- Passing lcov tool under code coverage"
        COMMAND lcov --capture --directory ../ --output-file "lcoverage_${TESTNAME}/main_coverage.info" --rc lcov_branch_coverage=1
        COMMAND echo "-- Extracting"
        COMMAND lcov -e "lcoverage_${TESTNAME}/main_coverage.info" '${CMAKE_SOURCE_DIR}/src/*' -o "lcoverage_${TESTNAME}/main_coverage.info" --rc lcov_branch_coverage=1
        COMMAND echo "-- Removing non-ngen files"
        COMMAND lcov --remove "lcoverage_${TESTNAME}/main_coverage.info" '${CMAKE_SOURCE_DIR}/test/googletest/*' --output-file "lcoverage_${TESTNAME}/main_coverage.info" --rc lcov_branch_coverage=1
        COMMAND echo "-- Generating HTML output files"
        COMMAND genhtml "lcoverage_${TESTNAME}/main_coverage.info" --output-directory "lcoverage_${TESTNAME}" --rc lcov_branch_coverage=1 --legend
    )

    enable_testing()

    add_test(${TESTNAME} ${CMAKE_CURRENT_BINARY_DIR}/${TESTNAME})

    target_link_libraries(${TESTNAME} gmock)
    target_link_libraries(${TESTNAME} pthread)
    target_link_libraries(${TESTNAME} -fprofile-arcs)

endfunction()


# Add test source files (e.g., test1.cpp)
#add_executable(test_hymod models/hymod/include/HymodTest.cpp)
#target_link_libraries(test_hymod gtest gtest_main)


function(add_test_custom TESTNAME NUM_FILES)
    math(EXPR NUM_LINKS "${ARGC} - ${NUM_FILES}")
    # message(STATUS "${TESTNAME} ${NUM_FILES} ${NUM_LINKS}")
    list(SUBLIST ARGN 0 ${NUM_FILES} SOURCE_FILES)
    list(SUBLIST ARGN ${NUM_FILES} ${NUM_LINKS} LINKED_LIBS)

    # Also link these testing libraries for anything
    # TODO: verify these do not remove current value at i = 0, but instead push it forward
    list(INSERT LINKED_LIBS 0 gtest gtest_main)
    message(STATUS "Generating ${TESTNAME}")

    # Sanity check for duplicates
    list(REMOVE_DUPLICATES LINKED_LIBS)

    # Create the testing executable target and link the libraries
    add_executable(${TESTNAME} ${SOURCE_FILES})
    target_link_libraries(${TESTNAME} ${LINKED_LIBS})  

    # Test coverage
    if(COVERAGE)
        # message(STATUS "Preparing code coverage for test: ${TESTNAME}")
        get_coverage(${TESTNAME})
    endif()
    # endif()


    # Perform the final GoogleTest boilerplate steps
    gtest_discover_tests(${TESTNAME}
            WORKING_DIRECTORY ${PROJECT_DIR}
            PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY "${PROJECT_DIR}"
            )
    set_target_properties(${TESTNAME} PROPERTIES FOLDER test)
endfunction()


# If TEST_FILE is provided, only run this test 
# generates automatic test coverage report
if (TEST_FILE)
    file(READ ${TEST_FILE} FILESTR)
    string(REPLACE "\n" ";" FILESTR_LIST ${FILESTR})
    list(APPEND ${NETCDF_LIBRARIES} FILESTR_LIST)

    add_test_custom(${FILESTR_LIST})

elseif()

    ########################## Individual tests ##########################


    # add_automated_test(test_hymod models/hymod/include/HymodTest.cpp)

    # add_automated_test(
    #        test_tshirt
    #        models/tshirt/include/TshirtTest.cpp
    #        realizations/catchments/Tshirt_C_Realization_Test.cpp
    # )


    ######################### GeoJSON Unit Tests


    add_test_custom(test_geojson
            4
            geojson/JSONProperty_Test.cpp
            geojson/JSONGeometry_Test.cpp
            geojson/Feature_Test.cpp
            geojson/FeatureCollection_Test.cpp
            NGen::geojson
            )


    ########################## Realization Config Unit Tests
    add_test_custom(test_realization_config
            1
            realizations/Formulation_Manager_Test.cpp
            NGen::core
            NGen::realizations_catchment
            NGen::core_mediator
            NGen::forcing
            libudunits2
            ${NETCDF_LIBRARIES}
    )


    ########################## GIUH Unit Tests
    add_test_custom(
            test_giuh
            1
            core/catchment/giuh/GIUH_Test.cpp
            NGen::core_catchment_giuh
    )


    ########################## Nexus Tests
    add_test_custom(
            test_nexus
            1
            core/nexus/NexusTests.cpp
            NGen::core_nexus
    )


    ########################## MPI Remote Nexus Tests
    if(MPI_ACTIVE)
    add_test_custom(
            test_remote_nexus
            1
            core/nexus/NexusRemoteTests.cpp
            NGen::core_nexus
    )
    endif()


    ########################## Partitioning Tests
    #if(MPI_ACTIVE)
    #TODO this test depends on a "reference hydrofabric" that is rather large
    #and the path to that reference is absolute in the test code.  Need to rethink this.
    add_test_custom(
            test_partition
            1
            utils/Partition_Test.cpp
            NGen::core
            NGen::geojson
    )


    ########################## BMI C++ Tests
    add_test_custom(
            test_bmi_cpp
            2
            realizations/catchments/Bmi_Cpp_Adapter_Test.cpp
            realizations/catchments/Bmi_Cpp_Formulation_Test.cpp
            NGen::core
            NGen::realizations_catchment
            NGen::core_mediator
            NGen::forcing
            libudunits2
            ${NETCDF_LIBRARIES}
    )


    ########################## BMI C Tests
    if(BMI_C_LIB_ACTIVE)
        add_test_custom(
                test_bmi_c
                2
                realizations/catchments/Bmi_C_Adapter_Test.cpp
                realizations/catchments/Bmi_C_Formulation_Test.cpp
                NGen::core
                NGen::realizations_catchment
                NGen::core_mediator
                NGen::forcing
                libudunits2
                ${NETCDF_LIBRARIES}
        )
    endif()


    ########################## BMI Fortran Tests
    if (${BMI_FORTRAN_ACTIVE})
    message(STATUS "ADDING FORTRAN TEST")
        add_test_custom(
                test_bmi_fortran
                2
                realizations/catchments/Bmi_Fortran_Adapter_Test.cpp
                realizations/catchments/Bmi_Fortran_Formulation_Test.cpp
                NGen::core
                NGen::realizations_catchment
                NGen::core_mediator
                NGen::forcing
                libudunits2
                ${NETCDF_LIBRARIES}
        )
    endif()


    ########################## BMI Python Tests
    if (${NGEN_ACTIVATE_PYTHON})
        add_test_custom(
                test_bmi_python
                2
                realizations/catchments/Bmi_Py_Adapter_Test.cpp
                realizations/catchments/Bmi_Py_Formulation_Test.cpp
                NGen::core
                NGen::realizations_catchment
                NGen::core_mediator
                NGen::forcing
                libudunits2
                ${NETCDF_LIBRARIES}
        )
    endif()


    ########################## BMI Multi Tests
    add_test_custom(
            test_bmi_multi
            2
            realizations/catchments/Bmi_Multi_Formulation_Test.cpp
            realizations/catchments/Bmi_Cpp_Multi_Array_Test.cpp
            NGen::core
            NGen::realizations_catchment
            NGen::core_mediator
            NGen::forcing
            libudunits2
            ${NETCDF_LIBRARIES}
    )


    ########################## All BMI Unit Tests
    if(BMI_C_LIB_ACTIVE)
        if (${BMI_FORTRAN_ACTIVE})
            if (${NGEN_ACTIVATE_PYTHON})
                add_test_custom(
                        test_bmi_unit_all
                        7
                        realizations/catchments/Bmi_C_Adapter_Test.cpp
                        realizations/catchments/Bmi_C_Formulation_Test.cpp
                        realizations/catchments/Bmi_Fortran_Adapter_Test.cpp
                        realizations/catchments/Bmi_Fortran_Formulation_Test.cpp
                        realizations/catchments/Bmi_Py_Adapter_Test.cpp
                        realizations/catchments/Bmi_Py_Formulation_Test.cpp
                        realizations/catchments/Bmi_Multi_Formulation_Test.cpp
                        NGen::core
                        NGen::realizations_catchment
                        NGen::core_mediator
                        NGen::forcing
                        libudunits2
                        ${NETCDF_LIBRARIES}
                )
            endif()
        endif()
    endif()


    ########################## Comparison tests for the BMI CFE implementation
    # TODO: this probably needs to be added to integration testing also
    add_test_custom(
            compare_cfe
            1
            realizations/catchments/Bmi_C_Cfe_IT.cpp
            NGen::core
            NGen::realizations_catchment
            NGen::core_mediator
            NGen::forcing
            libudunits2
            ${NETCDF_LIBRARIES}
    )


    ########################## Comparison tests for the BMI PET implementation
    # TODO: this probably needs to be added to integration testing also
    add_test_custom(
            compare_pet
            1
            routing/Routing_Py_Bind_Test.cpp
            NGen::core # for filechecker utility
            NGen::routing
            pybind11::embed
    )


    ########################## Internal Torchlib LSTM Tests
    if(LSTM_TORCH_LIB_ACTIVE)
        add_test_custom(
                test_lstm
                2
                models/lstm/include/LSTM_Test.cpp
                realizations/catchments/LSTM_Realization_Test.cpp
                NGen::core
                NGen::realizations_catchment
                NGen::core_mediator
                libudunits2
                ${NETCDF_LIBRARIES}
        )
    endif()


    ########################## Routing Tests
    if(NGEN_ACTIVATE_ROUTING)
        add_test_custom(
                test_routing_pybind
                1
                routing/Routing_Py_Bind_Test.cpp
                NGen::routing
                pybind11::embed
        )
    endif()


    ########################## Network Class Tests
    add_test_custom(
            test_network
            1
            core/NetworkTests.cpp
            NGen::core
            NGen::geojson
    )


    ########################### Netcdf Forcing Tests
    if(NETCDF_ACTIVE)
    add_test_custom(
            test_netcdf_forcing
            1
            forcing/NetCDFPerFeatureDataProvider_Test.cpp
            NGen::core
            NGen::core_nexus
            NGen::core_mediator
            NGen::forcing
            NGen::geojson
            NGen::realizations_catchment
            libudunits2
            ${NETCDF_LIBRARIES}
    )
    endif()


    ########################## Primary Combined Unit Test Target
    add_test_custom(
            test_unit
            19
            models/hymod/include/HymodTest.cpp
            models/hymod/include/Reservoir_Test.cpp
            models/hymod/include/Reservoir_Timeless_Test.cpp
            models/tshirt/include/TshirtTest.cpp
            realizations/catchments/Tshirt_C_Realization_Test.cpp
            geojson/JSONProperty_Test.cpp
            geojson/JSONGeometry_Test.cpp
            geojson/Feature_Test.cpp
            geojson/FeatureCollection_Test.cpp
            forcing/CsvPerFeatureForcingProvider_Test.cpp
            forcing/OptionalWrappedDataProvider_Test.cpp
            forcing/NetCDFPerFeatureDataProvider_Test.cpp
            core/mediator/UnitsHelper_Tests.cpp
            simulation_time/Simulation_Time_Test.cpp
            core/catchment/giuh/GIUH_Test.cpp
            core/NetworkTests.cpp
            utils/include/StreamOutputTest.cpp
            realizations/Formulation_Manager_Test.cpp
            utils/Partition_Test.cpp
            NGen::core
            NGen::core_nexus
            NGen::core_mediator
            NGen::forcing
            NGen::geojson
            NGen::realizations_catchment
            libudunits2
            ${NETCDF_LIBRARIES}
    )


        # Add for integration tests once we have some
        #add_automated_test(test_it models/hymod/include/HymodTest.cpp)


    # All automated tests
    add_test_custom(
            test_all
            18
            models/hymod/include/HymodTest.cpp
            models/hymod/include/Reservoir_Test.cpp
            models/hymod/include/Reservoir_Timeless_Test.cpp
            models/tshirt/include/TshirtTest.cpp
            realizations/catchments/Tshirt_C_Realization_Test.cpp
            geojson/JSONProperty_Test.cpp
            geojson/JSONGeometry_Test.cpp
            geojson/Feature_Test.cpp
            geojson/FeatureCollection_Test.cpp
            forcing/CsvPerFeatureForcingProvider_Test.cpp
            forcing/OptionalWrappedDataProvider_Test.cpp
            forcing/NetCDFPerFeatureDataProvider_Test.cpp
            simulation_time/Simulation_Time_Test.cpp
            core/catchment/giuh/GIUH_Test.cpp
            core/mediator/UnitsHelper_Tests.cpp
            realizations/Formulation_Manager_Test.cpp
            core/nexus/NexusTests.cpp
            utils/Partition_Test.cpp
            NGen::core
            gmock
            NGen::core_nexus
            NGen::core_mediator
            NGen::forcing
            NGen::geojson
            NGen::realizations_catchment
            libudunits2
            ${NETCDF_LIBRARIES}
    )

endif()

# message(STATUS "Here are the CXX flags! ${CMAKE_CXX_FLAGS}")
