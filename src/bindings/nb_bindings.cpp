#include <nanobind/nanobind.h>
#include <nanobind/stl/vector.h>

#include "fast_class.hpp"
#include "simple_function.hpp"

namespace nb = nanobind;
using namespace nb::literals;

NB_MODULE(_nanobind_module, m) {
    m.doc() = R"nbdoc(
        C++ Template Binding Project

        Fast Class (Hamming Distance Calculator) と Simple Function の例を含むC++テンプレートプロジェクトです。
    )nbdoc";

    // Fast Class module bindings
    nb::class_<fast_class::HammingDistanceCalculator>(
        m, "HammingDistanceCalculator",
        R"nbdoc(
            ハミング距離計算クラス

            2つの64bit整数配列のハミング距離を効率的に計算します。
            
            このクラスは、C++で実装された高速なハミング距離計算アルゴリズムを
            提供します。ハミング距離とは、同じ長さの2つの文字列（ここでは
            ビット列）で異なる位置の数を表します。

            Example:
                >>> calc = HammingDistanceCalculator([0xFF, 0x00], [0x0F, 0xFF])
                >>> result = calc.calculate()
                >>> size = calc.size()
                >>> print(f"Calculated {result} for {size} elements")
        )nbdoc"
    )
        .def(
            nb::init<const std::vector<uint64_t> &, const std::vector<uint64_t> &>(), "a"_a, "b"_a,
            R"nbdoc(
                ハミング距離計算の初期化

                2つの整数配列を受け取り、ハミング距離計算の準備を行います。

                Args:
                    a: 第1の64bit整数配列。計算対象となる整数のリスト
                    b: 第2の64bit整数配列。aと同じサイズである必要があります

                Raises:
                    ValueError: 配列aとbのサイズが異なる場合

                Note:
                    配列の各要素は64bit整数として扱われ、
                    対応する要素同士のビット差分が計算されます。

                Example:
                    >>> calc = HammingDistanceCalculator([5, 3], [1, 7])
                    >>> # 5 XOR 1 = 4 (binary: 100) -> 1 bit different
                    >>> # 3 XOR 7 = 4 (binary: 100) -> 1 bit different
                    >>> # Total: 1 + 1 = 2
            )nbdoc"
        )
        .def(
            "calculate", &fast_class::HammingDistanceCalculator::calculate,
            R"nbdoc(
                ハミング距離の合計を計算

                初期化時に設定した2つの配列の対応する要素間のハミング距離を
                すべて計算し、その合計値を返します。

                各要素ペアに対してビット単位でXOR演算を行い、結果の1の個数
                （ハミング距離）を数えます。全要素ペアの距離を合計して返します。

                Returns:
                    int: 全要素ペアのハミング距離の合計値

                Example:
                    >>> calc = HammingDistanceCalculator([5, 3], [1, 7])
                    >>> result = calc.calculate()  # Returns: 2
                    >>> print(f"Total hamming distance: {result}")
            )nbdoc"
        )
        .def(
            "size", &fast_class::HammingDistanceCalculator::size,
            R"nbdoc(
                データサイズを取得

                初期化時に設定した配列の要素数を返します。

                Returns:
                    int: 配列の要素数

                Example:
                    >>> calc = HammingDistanceCalculator([1, 2, 3], [4, 5, 6])
                    >>> size = calc.size()  # Returns: 3
                    >>> print(f"Processing {size} elements")
            )nbdoc"
        );

    // Simple Function module bindings
    m.def(
        "add_integers", &simple_function::addIntegers, "Add two integers", "a"_a, "b"_a,
        R"nbdoc(
              整数の足し算

              2つの整数を受け取り、その和を返します。

              Args:
                  a: 第1の整数
                  b: 第2の整数

              Returns:
                  int: a + b の結果

              Example:
                  >>> result = add_integers(5, 3)
                  >>> print(result)  # 8
          )nbdoc"
    );

    m.def(
        "add_doubles", &simple_function::addDoubles, "Add two doubles", "a"_a, "b"_a,
        R"nbdoc(
              浮動小数点数の足し算

              2つの倍精度浮動小数点数を受け取り、その和を返します。

              Args:
                  a: 第1の浮動小数点数
                  b: 第2の浮動小数点数

              Returns:
                  float: a + b の結果

              Example:
                  >>> result = add_doubles(5.5, 3.2)
                  >>> print(result)  # 8.7
          )nbdoc"
    );

    // Template function instantiations for common types
    m.def(
        "add_generic_int", &simple_function::addGeneric<int>, "Add two integers using generic template", "a"_a, "b"_a,
        R"nbdoc(
              汎用テンプレート関数による整数の足し算

              テンプレート関数を使用した整数の足し算です。

              Args:
                  a: 第1の整数
                  b: 第2の整数

              Returns:
                  int: a + b の結果
          )nbdoc"
    );

    m.def(
        "add_generic_double", &simple_function::addGeneric<double>, "Add two doubles using generic template", "a"_a,
        "b"_a,
        R"nbdoc(
              汎用テンプレート関数による倍精度浮動小数点数の足し算

              テンプレート関数を使用した倍精度浮動小数点数の足し算です。

              Args:
                  a: 第1の倍精度浮動小数点数
                  b: 第2の倍精度浮動小数点数

              Returns:
                  float: a + b の結果
          )nbdoc"
    );
}
