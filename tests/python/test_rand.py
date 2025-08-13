from template_bind_cpp_python import Rand


def test_rand() -> None:
    """Test Rand class"""
    r = Rand(42)
    v1 = r.next()
    assert v1 is not None
    assert 0 < v1 < 1

    r.set_seed(42)
    v2 = r.next()
    assert v1 == v2
