#!/usr/bin/env elixir

# 1. LOAD Counter plugin
Code.require_file("counter.ex", __DIR__)
{:ok, _} = Counter.start_link(nil)

# USE Counter plugin
text = Counter.inc_text("Hello")

# PURGE Counter plugin
:code.delete(Counter)
:code.purge(Counter)


# 2. LOAD StringProcessor plugin
Code.require_file("string_processor.ex", __DIR__)

# USE StringProcessor plugin
result =
  text
  |> StringProcessor.add_word()
  |> StringProcessor.add_suffix()

# PURGE StringProcessor plugin
:code.delete(StringProcessor)
:code.purge(StringProcessor)

# ONLY OUTPUT
IO.puts(result)
