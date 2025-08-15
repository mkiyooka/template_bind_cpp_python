#include <iostream>

#include "rand.hpp"

int main() {
    Rand r(42);
    auto v1 = r.next();
    if (v1 < 0 || 1 < v1) {
        std::cout << "\nテスト失敗: 範囲外の値\n" << v1 << std::flush;
    } else {
        std::cout << "テスト成功: 値 " << v1 << " は範囲内です。\n" << std::flush;
    }
    r.set_seed(42);
    auto v2 = r.next();
    if (v1 != v2) {
        std::cout << "\nテスト失敗: 乱数が再現されません。" << std::endl;
    } else {
        std::cout << "\nテスト成功: 乱数生成は再現性があります。" << std::endl;
    }
    return 0;
}
