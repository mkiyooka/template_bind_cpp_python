"""basic usage of this package"""

import template_bind_cpp_python as m

if m.Rand is None:
    print("nanobind module is not available.")
else:
    rng = m.Rand(42)
    print(f"Rand: {rng.next()=:.3}, {rng.next()=:.3}, {rng.next()=:.3}")
    rng.set_seed(42)
    print(f"Rand: {rng.next()=:.3}, {rng.next()=:.3}, {rng.next()=:.3}")
