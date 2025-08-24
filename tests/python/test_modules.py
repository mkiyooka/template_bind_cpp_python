import template_bind_cpp_python as mod  # ignore[import]


def test_HammingDistanceCalculator() -> None:
    """Test HammingDistanceCalculator class"""
    calculator = mod.HammingDistanceCalculator([0x1248], [0x0000])
    result = calculator.calculate()
    assert result == 4
    assert calculator.size() == 1


def test_add_functions() -> None:
    """Test add function bindings"""
    # Test integer addition
    result_int = mod.add_integers(5, 3)
    assert result_int == 8

    # Test double addition
    result_double = mod.add_doubles(5.5, 3.2)
    assert abs(result_double - 8.7) < 1e-10

    # Test generic template functions
    result_generic_int = mod.add_generic_int(10, 20)
    assert result_generic_int == 30

    result_generic_double = mod.add_generic_double(7.7, 2.3)
    assert abs(result_generic_double - 10.0) < 1e-10
