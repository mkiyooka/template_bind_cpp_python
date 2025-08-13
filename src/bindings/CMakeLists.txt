# Python bindings
# include directories are inherited from rand_core
if($ENV{WITH_PYBIND11})
    message(STATUS "Building pybind11 bindings")
    pybind11_add_module(${MODULE_NAME}
        MODULE
        pb_rand.cpp
    )
    target_link_libraries(${MODULE_NAME} PRIVATE 
        pybind11::headers
        rand_core
    )
else()
    message(STATUS "Building nanobind bindings")
    nanobind_add_module(${MODULE_NAME}
        STABLE_ABI
        NB_STATIC
        nb_rand.cpp
    )
    target_link_libraries(${MODULE_NAME} PRIVATE
        rand_core
    )
endif()
