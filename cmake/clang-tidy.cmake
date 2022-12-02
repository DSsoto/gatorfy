include_guard()

function(setup_clang_tidy)
    find_program(CLANG_TIDY_PATH clang-tidy
      NAMES
        clang-tidy-10
        clang-tidy-9
        clang-tidy-8
        clang-tidy-7
        clang-tidy-6
        clang-tidy-5
      DOC "Path to clang-tidy executable"
    )
    if (CLANG_TIDY_PATH)
        message(STATUS "Found clang-tidy ${CLANG_TIDY_PATH}")
        foreach(lang C CXX CUDA)
          set(CMAKE_${lang}_CLANG_TIDY
            "${CLANG_TIDY_PATH}"
            "-header-filter=$CMAKE_CURRENT_SOURCE_DIR}"
            "-p=${CMAKE_BINARY_DIR}"
            PARENT_SCOPE)
        endforeach()
    else()
        message(WARNING "Could not find clang-tidy")
        set(USE_CLANG_TIDY FALSE)
    endif()
endfunction()

set(USE_CLANG_TIDY YES CACHE BOOL "Use clang-tidy")
if (USE_CLANG_TIDY)
    setup_clang_tidy()
endif()

message(STATUS "USE_CLANG_TIDY: \"${USE_CLANG_TIDY}\"")
