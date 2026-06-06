#!/usr/bin/env elixir

scripts_dir = __DIR__

# ── COMPILE: .ex → .beam files on disk ───────────────────────────────────────
# Unload any stale modules and remove their .beam files before recompiling.
# The scripts dir is in Elixir's code path, so modules from a previous run
# would be in memory; if not purged before Code.compile_file, the compiler
# issues a "redefining module" warning when it encounters defmodule.
Path.wildcard(Path.join(scripts_dir, "Elixir.*.beam"))
|> Enum.each(fn beam_path ->
  module = beam_path |> Path.basename(".beam") |> String.to_atom()
  :code.purge(module)
  :code.delete(module)
  File.rm!(beam_path)
end)

# Code.compile_file also loads the freshly compiled module into memory,
# so we purge/delete after writing the .beam to leave memory clean.
for source <- ["counter.ex", "string_processor.ex"] do
  [{module, binary}] = Code.compile_file(source, scripts_dir)
  File.write!(Path.join(scripts_dir, "#{module}.beam"), binary)
  :code.purge(module)
  :code.delete(module)
end

# ── 1. LOAD SetmyInfo.Scripts.Counter from .beam ─────────────────────────────
{:module, SetmyInfo.Scripts.Counter} =
  :code.load_abs(Path.join(scripts_dir, "Elixir.SetmyInfo.Scripts.Counter") |> String.to_charlist())

{:ok, _} = SetmyInfo.Scripts.Counter.start_link(nil)
text = SetmyInfo.Scripts.Counter.inc_text("Hello")

:code.purge(SetmyInfo.Scripts.Counter)
:code.delete(SetmyInfo.Scripts.Counter)

# ── 2. LOAD SetmyInfo.Scripts.StringProcessor from .beam ─────────────────────
{:module, SetmyInfo.Scripts.StringProcessor} =
  :code.load_abs(Path.join(scripts_dir, "Elixir.SetmyInfo.Scripts.StringProcessor") |> String.to_charlist())

result =
  text
  |> SetmyInfo.Scripts.StringProcessor.add_word()
  |> SetmyInfo.Scripts.StringProcessor.add_suffix()

:code.purge(SetmyInfo.Scripts.StringProcessor)
:code.delete(SetmyInfo.Scripts.StringProcessor)

# ── OUTPUT ────────────────────────────────────────────────────────────────────
IO.puts(result)
