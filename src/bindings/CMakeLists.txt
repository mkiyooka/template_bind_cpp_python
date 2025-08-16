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
