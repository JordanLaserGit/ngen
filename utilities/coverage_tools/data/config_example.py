""""
An example config with option explanations


    "test_name"      : "test_everything",       # The name of the test, will be in the build folder and output files.
    "verbose"        : "true",                  # Verbose for file print outs. 

    "options"        : {                        # CMake directive options. Make sure you edit the shell script 
                                                  to reflect these options if used on a project other than NGen. 
                                                  Will fix this in future updates.

        "DBMI_C_LIB_ACTIVE"      : "TRUE",
        "DBMI_FORTRAN_ACTIVE"    : "TRUE",
        "DCMAKE_BUILD_TYPE"      : "Debug",
        "DCOVERAGE"              : "TRUE",
        "DET_QUIET"              : "FALSE",
        "DLSTM_TORCH_LIB_ACTIVE" : "FALSE",
        "DMPI_ACTIVE"            : "TRUE",
        "DNETCDF_ACTIVE"         : "FALSE",
        "DNGEN_ACTIVATE_PYTHON"  : "FALSE",
        "DNGEN_ACTIVATE_ROUTING" : "FALSE",
        "DNGEN_QUIET"            : "FALSE",
        "DUDUNITS_ACTIVE"        : "TRUE",
        "DDUDUNITS_QUIET"        : "TRUE",
        "DQUIET"                 : "FALSE"

    },

    "gtest_dirs_leave_out" : [                  # Any GoogleTests directories to be ignored
        "simulation_time",
        "utils/include"
    ],

    "gtest_leave_out" : [                       # Specific GoogleTest files to be ignored
        "Schaake_Partitioning_Test.cpp",
        "HymodTest.cpp",
        "Pdm03_Test.cpp",
        "Et_Calc_Function_Test.cpp",
        "Et_All_Methods_Test.cpp"
                    
    ],

    "libs_add"       : [                        # Dynamic libraries that are linked to the target test
    "NGen::core",
    "NGen::core_catchment",
    "NGen::core_nexus",
    "NGen::geojson",
    "NGen::models_tshirt",
    "NGen::realizations_catchment",
    "NGen::kernels_reservoir",
    "NGen::kernels_evapotranspiration",
    "NGen::forcing",
    "NGen::core_mediator",
    "gmock",
    "libudunits2"
    ]



        # The below fields are not currently used.
        # The intention with these is to build a single dynamic library that encompasses all header files in project.
            This way, the user doesn't have to manually build each dynamic library
            WIP
    "target_dirs":[                             
        "include/",
        "models/"
    ],

    "target_dirs_leave_out":{
        "include" : ["/include/utilities"],
        "models"  : []
    },

    "target_dirs_add":[
        "extern/pybind11/include"

    ],






"""