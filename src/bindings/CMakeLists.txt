# Python bindings
# include directories are inherited from rand_core

if(${nanobind_FOUND})
    message(STATUS "Building nanobind bindings")
    nanobind_add_module(${NANOBIND_MODULE_NAME}
        STABLE_ABI
        NB_STATIC
        nb_rand.cpp
    )
    target_link_libraries(${NANOBIND_MODULE_NAME} PRIVATE
        rand_core
    )
    nanobind_add_stub(${NANOBIND_MODULE_NAME}_stub
        MODULE ${NANOBIND_MODULE_NAME}
        OUTPUT ${NANOBIND_MODULE_NAME}.pyi
        MARKER_FILE py.typed
        PYTHON_PATH $<TARGET_FILE_DIR:${NANOBIND_MODULE_NAME}>
        DEPENDS ${NANOBIND_MODULE_NAME}
    )
endif()

if(${pybind11_FOUND})
    message(STATUS "Building pybind11 bindings")
    pybind11_add_module(${PYBIND11_MODULE_NAME}
        MODULE
        pb_rand.cpp
    )
    target_link_libraries(${PYBIND11_MODULE_NAME} PRIVATE
        pybind11::headers
        rand_core
    )
endif()
