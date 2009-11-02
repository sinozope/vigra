# - Find VIGRANUMPY_DEPENDENCIES
# 
FIND_PACKAGE(PythonInterp)

IF(PYTHONINTERP_FOUND)
    VIGRA_FIND_PACKAGE( Boost COMPONENTS python )

    FIND_PACKAGE(PythonLibs)

    IF(NOT DEFINED VIGRANUMPY_INSTALL_DIR OR VIGRANUMPY_INSTALL_DIR MATCHES "^$")
        execute_process ( COMMAND ${PYTHON_EXECUTABLE} -c 
                         "from distutils.sysconfig import *; print get_python_lib()"
                          OUTPUT_VARIABLE PYTHON_SITE_PACKAGES OUTPUT_STRIP_TRAILING_WHITESPACE)
        FILE(TO_CMAKE_PATH ${PYTHON_SITE_PACKAGES} VIGRANUMPY_INSTALL_DIR)
    ENDIF()
    SET(VIGRANUMPY_INSTALL_DIR ${VIGRANUMPY_INSTALL_DIR}
        CACHE PATH "where to install the VIGRA Python package" FORCE)

    MESSAGE(STATUS "Searching for numpy")
    execute_process ( COMMAND ${PYTHON_EXECUTABLE} -c 
                     "from numpy.distutils.misc_util import *; print ' '.join(get_numpy_include_dirs())" 
                      RESULT_VARIABLE PYTHON_NUMPY_NOT_FOUND
                      OUTPUT_VARIABLE PYTHON_NUMPY_INCLUDE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)

    IF(NOT PYTHON_NUMPY_NOT_FOUND)
        FILE(TO_CMAKE_PATH ${PYTHON_NUMPY_INCLUDE_DIR} PYTHON_NUMPY_INCLUDE_DIR)
    ELSE()
        MESSAGE(STATUS "Could NOT find Python numpy module")
    ENDIF()

    execute_process ( COMMAND ${PYTHON_EXECUTABLE} -c 
                     "import sys; print sys.platform" 
                      OUTPUT_VARIABLE PYTHON_PLATFORM OUTPUT_STRIP_TRAILING_WHITESPACE)

    MESSAGE(STATUS "Searching for nosetests")
    STRING(REGEX REPLACE "/[^/]*$" "" NOSETESTS_SEARCH_DIR ${PYTHON_EXECUTABLE})
    SET(NOSETESTS_SEARCH_DIR ${NOSETESTS_SEARCH_DIR} ${NOSETESTS_SEARCH_DIR}/Scripts)
    find_program(NOSETESTS_EXECUTABLE nosetests
                 PATHS ${NOSETESTS_SEARCH_DIR} ENV PATH
                 DOC "nosetests program (required for Python testing)")
                 
    IF(NOT NOSETESTS_EXECUTABLE)
        MESSAGE(STATUS "Could NOT find nosetests executable")
    ELSEIF(MSVC OR MINGW)
        IF(NOT NOSETESTS_EXECUTABLE MATCHES ".exe$" AND NOT NOSETESTS_EXECUTABLE MATCHES ".bat$")
            SET(NOSETESTS_EXECUTABLE "${PYTHON_EXECUTABLE} ${NOSETESTS_EXECUTABLE}")
        ENDIF()
    ENDIF()
    
    # handle the QUIETLY and REQUIRED arguments and set VIGRANUMPY_DEPENDENCIES_FOUND to TRUE if 
    # all listed variables are TRUE
    INCLUDE(FindPackageHandleStandardArgs)
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(VIGRANUMPY_DEPENDENCIES DEFAULT_MSG 
                         PYTHONINTERP_FOUND PYTHONLIBS_FOUND
                         Boost_PYTHON_FOUND PYTHON_NUMPY_INCLUDE_DIR VIGRANUMPY_INSTALL_DIR)

    SET(VIGRANUMPY_INCLUDE_DIR ${PYTHON_INCLUDE_PATH} ${Boost_INCLUDE_DIR} ${PYTHON_NUMPY_INCLUDE_DIR}
        CACHE PATH "include directories needed by VIGRA Python bindings")
    SET(VIGRANUMPY_LIBRARIES ${PYTHON_LIBRARY} ${Boost_PYTHON_LIBRARIES}
        CACHE FILEPATH "libraries needed by VIGRA Python bindings")
ENDIF()
