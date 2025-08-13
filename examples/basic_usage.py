"""basic usage of this package"""

import template_bind_cpp_python as m

rng = m.Rand(42)
print(f"{rng.next()=:.3}, {rng.next()=:.3}, {rng.next()=:.3}")
rng.set_seed(42)
print(f"{rng.next()=:.3}, {rng.next()=:.3}, {rng.next()=:.3}")
