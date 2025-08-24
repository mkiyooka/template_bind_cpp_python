# File: cmake/quality-tools.cmake
# Quality management tools configuration (separated from build toolchain)
# Usage: include(cmake/quality-tools.cmake)

# Platform-specific quality tools search paths
function(setup_quality_tools)
    # clang-format search
    if(DEFINED CLANG_FORMAT_SEARCH_PATHS)
        string(REPLACE ";" ";" CLANG_FORMAT_PATHS "${CLANG_FORMAT_SEARCH_PATHS}")
        find_program(CLANG_FORMAT_EXE 
            NAMES clang-format
            PATHS ${CLANG_FORMAT_PATHS}
            NO_DEFAULT_PATH
        )
    else()
        # Platform-specific default search
        if(APPLE)
            # macOS: Homebrew paths
            set(DEFAULT_CLANG_FORMAT_PATHS
                "/opt/homebrew/bin"
                "/opt/homebrew/opt/llvm/bin"
                "/opt/homebrew/opt/llvm@*/bin"
            )
        elseif(UNIX)
            # Linux: Package manager and manual install paths
            set(DEFAULT_CLANG_FORMAT_PATHS
                "/usr/bin"
                "/usr/local/bin"
                "/usr/lib/llvm-*/bin"                        # Ubuntu/Debian
                "/opt/rh/llvm-toolset-*/root/usr/bin"        # RHEL SCL
            )
        endif()
        
        if(DEFINED DEFAULT_CLANG_FORMAT_PATHS)
            find_program(CLANG_FORMAT_EXE 
                NAMES clang-format
                PATHS ${DEFAULT_CLANG_FORMAT_PATHS}
                NO_DEFAULT_PATH
            )
        endif()
        
        # Fallback to system PATH
        if(NOT CLANG_FORMAT_EXE)
            find_program(CLANG_FORMAT_EXE NAMES clang-format)
        endif()
    endif()

    # clang-tidy search  
    if(DEFINED CLANG_TIDY_SEARCH_PATHS)
        string(REPLACE ";" ";" CLANG_TIDY_PATHS "${CLANG_TIDY_SEARCH_PATHS}")
        find_program(CLANG_TIDY_EXE 
            NAMES clang-tidy
            PATHS ${CLANG_TIDY_PATHS}
            NO_DEFAULT_PATH
        )
    else()
        # Platform-specific default search
        if(APPLE)
            # macOS: Homebrew LLVM only (not in /opt/homebrew/bin)
            set(DEFAULT_CLANG_TIDY_PATHS
                "/opt/homebrew/opt/llvm/bin"
                "/opt/homebrew/opt/llvm@*/bin"
            )
        elseif(UNIX)
            # Linux: LLVM-specific paths preferred
            set(DEFAULT_CLANG_TIDY_PATHS
                "/usr/lib/llvm-*/bin"                        # Ubuntu/Debian  
                "/opt/rh/llvm-toolset-*/root/usr/bin"        # RHEL SCL
                "/usr/bin"                                   # System fallback
                "/usr/local/bin"                             # Manual install
            )
        endif()
        
        if(DEFINED DEFAULT_CLANG_TIDY_PATHS)
            find_program(CLANG_TIDY_EXE 
                NAMES clang-tidy
                PATHS ${DEFAULT_CLANG_TIDY_PATHS}
                NO_DEFAULT_PATH
            )
        endif()
        
        # Fallback to system PATH
        if(NOT CLANG_TIDY_EXE)
            find_program(CLANG_TIDY_EXE NAMES clang-tidy)
        endif()
    endif()

    # scan-build (clang static analyzer) search
    if(DEFINED SCAN_BUILD_SEARCH_PATHS)
        string(REPLACE ";" ";" SCAN_BUILD_PATHS "${SCAN_BUILD_SEARCH_PATHS}")
        find_program(SCAN_BUILD_EXE
            NAMES scan-build
            PATHS ${SCAN_BUILD_PATHS}
            NO_DEFAULT_PATH
        )
    else()
        # Platform-specific default search (same paths as clang-tidy)
        if(APPLE)
            set(DEFAULT_SCAN_BUILD_PATHS
                "/opt/homebrew/opt/llvm/bin"
                "/opt/homebrew/opt/llvm@*/bin"
            )
        elseif(UNIX)
            set(DEFAULT_SCAN_BUILD_PATHS
                "/usr/lib/llvm-*/bin"                        # Ubuntu/Debian
                "/opt/rh/llvm-toolset-*/root/usr/bin"        # RHEL SCL
                "/usr/bin"                                   # System fallback
                "/usr/local/bin"                             # Manual install
            )
        endif()
        
        if(DEFINED DEFAULT_SCAN_BUILD_PATHS)
            find_program(SCAN_BUILD_EXE
                NAMES scan-build
                PATHS ${DEFAULT_SCAN_BUILD_PATHS}
                NO_DEFAULT_PATH
            )
        endif()
        
        # Fallback to system PATH
        if(NOT SCAN_BUILD_EXE)
            find_program(SCAN_BUILD_EXE NAMES scan-build)
        endif()
    endif()

    # Display found tools
    message(STATUS "Quality tools configuration:")
    if(CLANG_FORMAT_EXE)
        message(STATUS "  clang-format: ${CLANG_FORMAT_EXE}")
    else()
        message(WARNING "  clang-format: NOT FOUND")
    endif()
    
    if(CLANG_TIDY_EXE)
        message(STATUS "  clang-tidy: ${CLANG_TIDY_EXE}")
    else()
        message(WARNING "  clang-tidy: NOT FOUND")
    endif()
    
    if(SCAN_BUILD_EXE)
        message(STATUS "  scan-build: ${SCAN_BUILD_EXE}")
    else()
        message(WARNING "  scan-build: NOT FOUND")
    endif()
    
    # Set variables for parent scope
    set(CLANG_FORMAT_EXE "${CLANG_FORMAT_EXE}" PARENT_SCOPE)
    set(CLANG_TIDY_EXE "${CLANG_TIDY_EXE}" PARENT_SCOPE)
    set(SCAN_BUILD_EXE "${SCAN_BUILD_EXE}" PARENT_SCOPE)
endfunction()

# Setup quality tools targets
function(setup_quality_targets SOURCE_FILES)
    if(CLANG_FORMAT_EXE)
        add_custom_target(format
            COMMAND ${CLANG_FORMAT_EXE} -i ${SOURCE_FILES}
            COMMENT "Formatting source code with clang-format"
        )
        add_custom_target(format-dry
            COMMAND ${CLANG_FORMAT_EXE} --dry-run --Werror ${SOURCE_FILES}
            COMMENT "Checking formatting (dry-run)"
        )
    else()
        add_custom_target(format
            COMMAND ${CMAKE_COMMAND} -E echo "clang-format not available"
            COMMENT "clang-format not found - skipping format"
        )
        add_custom_target(format-dry
            COMMAND ${CMAKE_COMMAND} -E echo "clang-format not available"
            COMMENT "clang-format not found - skipping format check"
        )
    endif()

    if(CLANG_TIDY_EXE)
        set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}" PARENT_SCOPE)
        
        # Filter out binding files for clang-tidy
        set(LINT_SOURCE_FILES)
        foreach(src ${SOURCE_FILES})
            if (NOT src MATCHES "/src/bindings/")
                list(APPEND LINT_SOURCE_FILES ${src})
            endif()
        endforeach()
        
        add_custom_target(lint
            COMMAND ${CLANG_TIDY_EXE} ${LINT_SOURCE_FILES}
            COMMENT "Running clang-tidy"
        )
    else()
        add_custom_target(lint
            COMMAND ${CMAKE_COMMAND} -E echo "clang-tidy not available"
            COMMENT "clang-tidy not found - skipping lint"
        )
    endif()

    if(SCAN_BUILD_EXE)
        # Static analysis with scan-build
        # Create clean analysis directory
        set(ANALYSIS_OUTPUT_DIR "${CMAKE_BINARY_DIR}/static-analysis")
        
        add_custom_target(static-analysis
            COMMAND ${CMAKE_COMMAND} -E remove_directory "${ANALYSIS_OUTPUT_DIR}"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${ANALYSIS_OUTPUT_DIR}"
            COMMAND ${SCAN_BUILD_EXE} 
                -o "${ANALYSIS_OUTPUT_DIR}"
                --status-bugs
                --use-analyzer=${CMAKE_CXX_COMPILER}
                cmake --build ${CMAKE_BINARY_DIR} --target cxx_core
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Running clang static analyzer (scan-build)"
        )
        
        # Viewer target to open analysis results
        add_custom_target(view-analysis
            COMMAND ${SCAN_BUILD_EXE} 
                --view "${ANALYSIS_OUTPUT_DIR}"
            COMMENT "Opening static analysis results in browser"
            DEPENDS static-analysis
        )
        
        # Quick analysis (without full rebuild)
        add_custom_target(quick-analysis
            COMMAND ${CMAKE_COMMAND} -E remove_directory "${ANALYSIS_OUTPUT_DIR}"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${ANALYSIS_OUTPUT_DIR}"
            COMMAND ${SCAN_BUILD_EXE}
                -o "${ANALYSIS_OUTPUT_DIR}"
                --status-bugs
                -k
                cmake --build ${CMAKE_BINARY_DIR} --target cxx_core
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Running quick static analysis (keep going on errors)"
        )
    else()
        add_custom_target(static-analysis
            COMMAND ${CMAKE_COMMAND} -E echo "scan-build not available"
            COMMENT "scan-build not found - skipping static analysis"
        )
        add_custom_target(view-analysis
            COMMAND ${CMAKE_COMMAND} -E echo "scan-build not available"
            COMMENT "scan-build not found - skipping analysis viewer"
        )
        add_custom_target(quick-analysis
            COMMAND ${CMAKE_COMMAND} -E echo "scan-build not available"
            COMMENT "scan-build not found - skipping quick analysis"
        )
    endif()
endfunction()