# Debug executables for multi-module testing
# This directory contains debug programs that can test combinations of modules

# デバッグターゲットはscikit-build環境では除外
if(NOT SKBUILD)
    # Main debug program for multi-module testing
    add_executable(debug_main main_debug.cpp)
    target_link_libraries(debug_main PRIVATE cxx_core)
    target_include_directories(debug_main PUBLIC ${PROJECT_INCLUDE_DIR})
    
    # Add more debug executables as modules grow
    # Example for future modules:
    # add_executable(debug_module2 module2_debug.cpp)
    # target_link_libraries(debug_module2 PRIVATE cxx_core module2_lib)
    
    # Set output directory for all debug executables
    set_target_properties(debug_main PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/debug"
    )
endif()