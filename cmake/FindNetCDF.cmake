# - Find NetCDF
# Find the native NetCDF includes and library
#
#  NETCDF_INCLUDE_DIR  - user modifiable choice of where netcdf headers are
#  NETCDF_LIBRARY      - user modifiable choice of where netcdf libraries are
#
# Your package can require certain interfaces to be FOUND by setting these
#
#  NETCDF_CXX         - require the C++ interface and link the C++ library
#  NETCDF_F77         - require the F77 interface and link the fortran library
#  NETCDF_F90         - require the F90 interface and link the fortran library
#
# Or equivalently by calling FindNetCDF with a COMPONENTS argument containing one or
# more of "CXX;F77;F90".
#
# When interfaces are requested the user has access to interface specific hints:
#
#  NETCDF_${LANG}_INCLUDE_DIR - where to search for interface header files
#  NETCDF_${LANG}_LIBRARY     - where to search for interface libraries
#
# This module returns these variables for the rest of the project to use.
#
#  NETCDF_FOUND          - True if NetCDF found including required interfaces (see below)
#  NETCDF_LIBRARIES      - All netcdf related libraries.
#  NETCDF_INCLUDE_DIRS   - All directories to include.
#  NETCDF_HAS_INTERFACES - Whether requested interfaces were found or not.
#  NETCDF_${LANG}_INCLUDE_DIRS/NETCDF_${LANG}_LIBRARIES - C/C++/F70/F90 only interface
#  NETCDF_HAS_PARALLEL   - Whether or not NetCDF was found with parallel IO support.
#
# Normal usage would be:
#  set (NETCDF_F90 "YES")
#  find_package (NetCDF REQUIRED)
#  target_link_libraries (uses_everthing ${NETCDF_LIBRARIES})
#  target_link_libraries (only_uses_f90 ${NETCDF_F90_LIBRARIES})

#search starting from user editable cache var
if (NETCDF_INCLUDE_DIR AND NETCDF_LIBRARY)
  # Already in cache, be silent
  set (NETCDF_FIND_QUIETLY TRUE)
endif ()

set(USE_DEFAULT_PATHS "NO_DEFAULT_PATH")
if(NETCDF_USE_DEFAULT_PATHS)
  set(USE_DEFAULT_PATHS "")
endif()

find_path (NETCDF_INCLUDE_DIR netcdf.h
  PATHS "${NetCDF_ROOT}/include")
mark_as_advanced (NETCDF_INCLUDE_DIR)
set (NETCDF_C_INCLUDE_DIRS ${NETCDF_INCLUDE_DIR})

find_library (NETCDF_LIBRARY NAMES netcdf
  PATHS "${NetCDF_ROOT}/lib"
  HINTS "${NETCDF_INCLUDE_DIR}/../lib")
mark_as_advanced (NETCDF_LIBRARY)

set (NETCDF_C_LIBRARIES ${NETCDF_LIBRARY})

#start finding requested language components
set (NetCDF_libs "")
set (NetCDF_includes "${NETCDF_INCLUDE_DIR}")

get_filename_component (NetCDF_lib_dirs "${NETCDF_LIBRARY}" PATH)
set (NETCDF_HAS_INTERFACES "YES") # will be set to NO if we're missing any interfaces

macro (NetCDF_check_interface lang header libs)
  if (NETCDF_${lang})
    #search starting from user modifiable cache var
    find_path (NETCDF_${lang}_INCLUDE_DIR NAMES ${header}
      HINTS "${NETCDF_INCLUDE_DIR}"
      HINTS "${NETCDF_${lang}_ROOT}/include"
      ${USE_DEFAULT_PATHS})
    find_library (NETCDF_${lang}_LIBRARY NAMES ${libs}
      HINTS "${NetCDF_lib_dirs}"
      HINTS "${NETCDF_${lang}_ROOT}/lib"
      ${USE_DEFAULT_PATHS})

    mark_as_advanced (NETCDF_${lang}_INCLUDE_DIR NETCDF_${lang}_LIBRARY)

    #export to internal varS that rest of project can use directly
    set (NETCDF_${lang}_LIBRARIES ${NETCDF_${lang}_LIBRARY})
    set (NETCDF_${lang}_INCLUDE_DIRS ${NETCDF_${lang}_INCLUDE_DIR})

    if (NETCDF_${lang}_INCLUDE_DIR AND NETCDF_${lang}_LIBRARY)
      list (APPEND NetCDF_libs ${NETCDF_${lang}_LIBRARY})
      list (APPEND NetCDF_includes ${NETCDF_${lang}_INCLUDE_DIR})
    else ()
      set (NETCDF_HAS_INTERFACES "NO")
      message (STATUS "Failed to find NetCDF interface for ${lang}")
    endif ()
  endif ()
endmacro ()

list (FIND NetCDF_FIND_COMPONENTS "CXX" _nextcomp)
if (_nextcomp GREATER -1)
  set (NETCDF_CXX 1)
endif ()
list (FIND NetCDF_FIND_COMPONENTS "F77" _nextcomp)
if (_nextcomp GREATER -1)
  set (NETCDF_F77 1)
endif ()
list (FIND NetCDF_FIND_COMPONENTS "F90" _nextcomp)
if (_nextcomp GREATER -1)
  set (NETCDF_F90 1)
endif ()
set( NETCDF_CXX_LIBRARY_NAMES_LIST netcdf_c++4 netcdf-cxx4 )
NetCDF_check_interface (CXX netcdf "${NETCDF_CXX_LIBRARY_NAMES_LIST}")
NetCDF_check_interface (F77 netcdf.inc  netcdff)
NetCDF_check_interface (F90 netcdf.mod  netcdff)

#export accumulated results to internal varS that rest of project can depend on
list (APPEND NetCDF_libs "${NETCDF_C_LIBRARIES}")
set (NETCDF_LIBRARIES ${NetCDF_libs})
set (NETCDF_INCLUDE_DIRS ${NetCDF_includes})

if(NETCDF_C_INCLUDE_DIRS)
  file(STRINGS "${NETCDF_C_INCLUDE_DIRS}/netcdf_meta.h" _netcdf_ver
    REGEX "#define[ \t]+NC_VERSION_(MAJOR|MINOR|PATCH|NOTE)")
  
  string(REGEX REPLACE ".*NC_VERSION_MAJOR *\([0-9]*\).*" "\\1" _netcdf_version_major "${_netcdf_ver}")
  string(REGEX REPLACE ".*NC_VERSION_MINOR *\([0-9]*\).*" "\\1" _netcdf_version_minor "${_netcdf_ver}")
  string(REGEX REPLACE ".*NC_VERSION_PATCH *\([0-9]*\).*" "\\1" _netcdf_version_patch "${_netcdf_ver}")
  string(REGEX REPLACE ".*NC_VERSION_NOTE *\"\([^\"]*\)\".*" "\\1" _netcdf_version_note "${_netcdf_ver}")
  set(NETCDF_VERSION "${_netcdf_version_major}.${_netcdf_version_minor}.${_netcdf_version_patch}${_netcdf_version_note}")
  unset(_netcdf_version_major)
  unset(_netcdf_version_minor)
  unset(_netcdf_version_patch)
  unset(_netcdf_version_note)
  unset(_netcdf_version_lines)
endif()

# handle the QUIETLY and REQUIRED arguments and set NETCDF_FOUND to TRUE if
# all listed variables are TRUE
include (FindPackageHandleStandardArgs)
find_package_handle_standard_args(NetCDF
  DEFAULT_MSG NETCDF_LIBRARIES NETCDF_INCLUDE_DIRS NETCDF_HAS_INTERFACES NETCDF_VERSION)

function(FindNetCDF_get_is_parallel_aware include_dir)
  file(STRINGS "${include_dir}/netcdf_meta.h" _netcdf_lines
    REGEX "#define[ \t]+NC_HAS_PARALLEL[ \t]")
  string(REGEX REPLACE ".*NC_HAS_PARALLEL[ \t]*([0-1]+).*" "\\1" _netcdf_has_parallel "${_netcdf_lines}")
  if (_netcdf_has_parallel)
    set(NETCDF_HAS_PARALLEL TRUE PARENT_SCOPE)
  else()
    set(NETCDF_HAS_PARALLEL FALSE PARENT_SCOPE)
  endif()
endfunction()

if (NETCDF_INCLUDE_DIR)
  FindNetCDF_get_is_parallel_aware("${NETCDF_INCLUDE_DIR}")
endif ()

if(NETCDF_FOUND)
  # Create NetCDF target
  add_library(NetCDF SHARED IMPORTED GLOBAL)
  target_include_directories(NetCDF INTERFACE "${NETCDF_INCLUDE_DIR}" "${NETCDF_CXX_INCLUDE_DIR}")
  target_link_libraries(NetCDF INTERFACE "${NETCDF_LIBRARY}" "${NETCDF_CXX_LIBRARY}")
  set_target_properties(NetCDF
      PROPERTIES
          IMPORTED_LOCATION "${NETCDF_LIBRARY}"
          IMPORTED_LOCATION "${NETCDF_CXX_LIBRARY}")
endif()
