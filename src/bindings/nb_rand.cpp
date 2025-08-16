// rand.hppで宣言されたクラスをpybind11でバインドするコード

#include <nanobind/nanobind.h>

#include "rand.hpp"

namespace nb = nanobind;

// module_coreはCMakeLists.txtで指定されたモジュール名と合わせる。
// 生成される共有ライブラリのプレフィックスにもこの名前が使用される。
NB_MODULE(_nanobind_module, m) {
    m.doc() = "nanobind lib";

    nb::class_<Rand>(m, "Rand")
        .def(nb::init<unsigned int>(), nb::arg("seed") = 0, R"nbdoc(
            初期化乱数生成器をシードで初期化する(nanobind)

            Args:
                seed (int): 初期化に使用するシード値。デフォルトは0。
        )nbdoc")
        .def("set_seed", &Rand::set_seed, R"nbdoc(
            シード値を設定する

            Args:
                seed (int): 新しいシード値。
        )nbdoc")
        .def("next", &Rand::next, R"nbdoc(
            乱数を生成する

            Returns:
                int: 生成された乱数。
        )nbdoc");
}
