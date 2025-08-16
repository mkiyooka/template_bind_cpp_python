"""basic usage of this package"""

import template_bind_cpp_python as m

if m.nb_rand is None:
    print("nanobind module is not available.")
else:
    rng = m.nb_rand(42)
    print(f"nb_rand: {rng.next()=:.3}, {rng.next()=:.3}, {rng.next()=:.3}")
    rng.set_seed(42)
    print(f"nb_rand: {rng.next()=:.3}, {rng.next()=:.3}, {rng.next()=:.3}")

if m.pb_rand is None:
    print("pybind11 module is not available.")
else:
    rng = m.pb_rand(42)
    print(f"pb_rand: {rng.next()=:.3}, {rng.next()=:.3}, {rng.next()=:.3}")
    rng.set_seed(42)
    print(f"pb_rand: {rng.next()=:.3}, {rng.next()=:.3}, {rng.next()=:.3}")
