include(${PROJECT_SOURCE_DIR}/cmake/testing.cmake)
include(${PROJECT_SOURCE_DIR}/cmake/catch2.cmake)

add_gtest(blah blah_test.cpp
  DEPENDS fmt::fmt
)
