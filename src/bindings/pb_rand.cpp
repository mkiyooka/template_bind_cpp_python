// rand.hppで宣言されたクラスをpybind11でバインドするコード

#include <pybind11/pybind11.h>

#include "rand.hpp"

namespace py = pybind11;

// module_coreはCMakeLists.txtで指定されたモジュール名と合わせる。
// 生成される共有ライブラリのプレフィックスにもこの名前が使用される。
PYBIND11_MODULE(_pybind11_module, m) {
    py::class_<Rand>(m, "Rand")
        .def(py::init<unsigned int>(), py::arg("seed") = 0, R"pbdoc(
            初期化乱数生成器をシードで初期化する(pybind11)

            Args:
                seed (int): 初期化に使用するシード値。デフォルトは0。
        )pbdoc")
        .def("set_seed", &Rand::set_seed, R"pbdoc(
            シード値を設定する

            Args:
                seed (int): 新しいシード値。
        )pbdoc")
        .def("next", &Rand::next, R"pbdoc(
            乱数を生成する

            Returns:
                int: 生成された乱数。
        )pbdoc");
}
