# setmy_info_lessons

Executable Elixir learning examples covering data types, collections, algorithms, and bitwise operations.

Each module contains runnable code that doubles as ExUnit tests — the test runner is the execution environment.

Part of the [elixir-start-project](https://github.com/setmy-info/elixir-start-project) umbrella.

## Installation

```elixir
def deps do
  [
    {:setmy_info_lessons, "~> 0.1"}
  ]
end
```

## Modules covered

| Module | Topics |
|---|---|
| `DataTypes` | Booleans, integers, floats, atoms, strings, nil, charlists |
| `DataStructures` | Tuples, lists, maps, keyword lists, structs, Date/DateTime |
| `FlowControl` | `if/else`, `cond`, `case`, `with`, `for`, tail recursion |
| `Operators` | Arithmetic, comparison, logical, pipe `\|>`, pattern match |
| `BitwiseOps` | `&&&/\|\|\|/^^^/~~~`, shifts, flag ops, XOR cipher, popcount |
| `Functions` | Named, multi-clause, defaults, anonymous, captures, recursion |
| `Algorithms` | Fibonacci, factorial, binary search, palindrome, GCD/LCM, primes |
| `Collections` | `Enum.map/filter/reduce`, `Map.*`, lazy `Stream` |

## Running

```sh
# All lessons
mix test apps/lessons/test

# One lesson
mix test apps/lessons/test/lessons/data_types_test.exs
```

## License

MIT — see [LICENSE](LICENSE).
