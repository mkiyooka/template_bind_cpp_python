# Python bindings
# include directories are inherited from cxx_core

message(STATUS "Building nanobind bindings")

# nanobind module using cxx_core library
nanobind_add_module(${NANOBIND_MODULE_NAME}
    STABLE_ABI
    NB_STATIC
    nb_bindings.cpp
)

# Link with cxx_core library and set include directories
target_link_libraries(${NANOBIND_MODULE_NAME} PRIVATE cxx_core)
target_include_directories(${NANOBIND_MODULE_NAME} PRIVATE
    ${PROJECT_INCLUDE_DIR}
)

# stub生成
nanobind_add_stub(${NANOBIND_MODULE_NAME}_stub
    MODULE ${NANOBIND_MODULE_NAME}
    OUTPUT ${NANOBIND_MODULE_NAME}.pyi
    MARKER_FILE py.typed
    PYTHON_PATH $<TARGET_FILE_DIR:${NANOBIND_MODULE_NAME}>
    DEPENDS ${NANOBIND_MODULE_NAME}
)
