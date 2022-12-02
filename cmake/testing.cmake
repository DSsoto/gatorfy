include_guard()

# GoogleTest Setup: inspired by:
# https://cliutils.gitlab.io/modern-cmake/chapters/testing/googletest.html
#include(CTest)
message(STATUS "BUILD_TESTING: \"${BUILD_TESTING}\"")

# Download and unpack googletest at configure time
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/googletest/download/CMakeLists.txt.in
[=[
cmake_minimum_required(VERSION 2.8.2)

project(googletest-download NONE)

include(ExternalProject)
ExternalProject_Add(googletest
  GIT_REPOSITORY    https://github.com/google/googletest.git
  GIT_TAG           origin/main
  SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/googletest/src"
  BINARY_DIR        "${CMAKE_CURRENT_BINARY_DIR}/googletest/build"
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     ""
  INSTALL_COMMAND   ""
  TEST_COMMAND      ""
)
]=])
configure_file(
  ${CMAKE_CURRENT_BINARY_DIR}/googletest/download/CMakeLists.txt.in
  ${CMAKE_CURRENT_BINARY_DIR}/googletest/download/CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
  RESULT_VARIABLE result
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/googletest/download)
if(result)
  message(FATAL_ERROR "CMake step for googletest failed: ${result}")
endif()
execute_process(COMMAND ${CMAKE_COMMAND} --build .
  RESULT_VARIABLE result
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/googletest/download)
if(result)
  message(FATAL_ERROR "Build step for googletest failed: ${result}")
endif()

# Add googletest directly to our build. This defines
# the gtest and gtest_main targets.
add_subdirectory(${CMAKE_CURRENT_BINARY_DIR}/googletest/src
                 ${CMAKE_CURRENT_BINARY_DIR}/googletest/build
                 EXCLUDE_FROM_ALL)

# For keeping the cache cleaner
mark_as_advanced(
  BUILD_GMOCK BUILD_GTEST BUILD_SHARED_LIBS
  gmock_buld_tests gtest_build_samples gtest_build_tests
  gtest_desavle_pthreads gtest_force_shared_crt gtest_hide_internal_symbols
)

# For not having these be top level entities in IDEs
set_target_properties(gtest PROPERTIES FOLDER extern)
set_target_properties(gtest_main PROPERTIES FOLDER extern)
set_target_properties(gmock PROPERTIES FOLDER extern)
set_target_properties(gmock_main PROPERTIES FOLDER extern)

# Adds gtest with an extra target that runs the test individually
function(add_gtest)
  if(NOT BUILD_TESTING)
    return()
  endif()

  cmake_parse_arguments(ARG
    ""
    ""
    "DEPENDS;LABELS"
    ${ARGN}
  )
  list(GET ARG_UNPARSED_ARGUMENTS 0 BUILD_TARGET)
  list(REMOVE_AT ARG_UNPARSED_ARGUMENTS 0)
  set(BUILD_TARGET test_${BUILD_TARGET})
  set(TEST_SOURCES ${ARG_UNPARSED_ARGUMENTS})

  # Build test
  add_executable(${BUILD_TARGET} ${TEST_SOURCES})
  target_link_libraries(${BUILD_TARGET}
    gtest gmock gtest_main ${ARG_DEPENDS})
  set_target_properties(${BUILD_TARGET} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    RUNTIME_OUTPUT_NAME ${BUILD_TARGET}
    FOLDER "$<TARGET_PROPERTY:${BUILD_TARGET},FOLDER>/test"
  )

  # Register test
  add_test(NAME ${BUILD_TARGET} COMMAND ${BUILD_TARGET})
  if (ARG_LABELS)
      set_tests_properties(${BUILD_TARGET} PROPERTIES
        LABELS ${ARG_LABELS})
  endif()

  # Make runnable target
  set(RUN_TARGET "run_${BUILD_TARGET}")
  add_custom_target(${RUN_TARGET} USES_TERMINAL
    COMMAND ${CMAKE_CTEST_COMMAND} "$<TARGET_FILE:${BUILD_TARGET}>" --output-on-failure
    DEPENDS ${BUILD_TARGET}
  )
  set_target_properties(${RUN_TARGET} PROPERTIES
    FOLDER "$<TARGET_PROPERTY:${RUN_TARGET},FOLDER>/test")
endfunction()
