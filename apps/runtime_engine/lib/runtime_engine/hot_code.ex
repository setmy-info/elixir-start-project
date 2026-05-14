defmodule SetmyInfo.RuntimeEngine.HotCode do
  @moduledoc """
  Utilities for hot code loading into the running BEAM VM.

  ## How Erlang hot code loading works

  The BEAM supports two live versions of any module simultaneously — the
  "current" version and the "old" version. Calling `Module.function()` always
  dispatches to the **current** version loaded in the code server. This means:

    * After a hot swap, existing Worker processes automatically call new code
      on their next `handle_call` — no restart needed.
    * The Worker stores `impl_module` as an atom; dispatch uses `apply/3`, so
      the dynamic lookup happens at call time, not at Worker start time.

  ## Entry points

    * `load_from_source/1` — compile Elixir source at runtime (via
      `Code.compile_string/1`) and load into the VM. Useful for tests and
      REPL-driven development.

    * `load_from_beam/2` — load a pre-compiled BEAM binary (e.g. received
      over the network or read from disk at runtime).

    * `load_from_file/1` — load a .beam file from the local filesystem.

    * `purge/1` — soft-purge the old version of a module after a hot swap.

  ## Reload vs restart

  | Method               | Worker restarts? | In-flight calls safe? |
  |----------------------|------------------|-----------------------|
  | `load_from_source/1` | No               | Yes (finish on old code) |
  | `Loader.reload/1`    | Yes              | Drain then terminate |
  """

  require Logger

  @doc """
  Compile Elixir source code and load all defined modules into the VM.

  Returns `{:ok, [{module, binary}]}` on success. The modules are
  immediately callable after this returns.
  """
  @spec load_from_source(String.t()) :: {:ok, [{module(), binary()}]} | {:error, term()}
  def load_from_source(elixir_source) when is_binary(elixir_source) do
    modules = Code.compile_string(elixir_source)

    Logger.info(
      "[HotCode] loaded #{length(modules)} module(s) from source: #{module_names(modules)}"
    )

    {:ok, modules}
  rescue
    e ->
      Logger.warning("[HotCode] compile error: #{Exception.message(e)}")
      {:error, e}
  end

  @doc """
  Load a pre-compiled BEAM binary for `module_name` into the VM.

  Use when you have the beam bytes (e.g. distributed over the network).
  """
  @spec load_from_beam(module(), binary()) :: :ok | {:error, term()}
  def load_from_beam(module_name, beam_binary)
      when is_atom(module_name) and is_binary(beam_binary) do
    filename = ~c"#{module_name}.beam"

    case :code.load_binary(module_name, filename, beam_binary) do
      {:module, ^module_name} ->
        Logger.info("[HotCode] loaded #{module_name} from BEAM binary")
        :ok

      {:error, reason} ->
        Logger.warning("[HotCode] failed to load #{module_name}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Load a module from a .beam file path (without the .beam extension).

  Example: `load_from_file("/app/ebin/my_module")`
  """
  @spec load_from_file(Path.t()) :: {:ok, module()} | {:error, term()}
  def load_from_file(path) when is_binary(path) do
    charpath = String.to_charlist(Path.rootname(path))

    case :code.load_abs(charpath) do
      {:module, module_name} ->
        Logger.info("[HotCode] loaded #{module_name} from #{path}")
        {:ok, module_name}

      {:error, reason} ->
        Logger.warning("[HotCode] failed to load from #{path}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Soft-purge the old version of a module from the code server.

  Returns `true` if purged, `false` if old-version processes were still running
  (the purge is skipped in that case — call again later or use `:code.purge/1`
  for a hard purge that kills those processes).
  """
  @spec purge(module()) :: boolean()
  def purge(module_name) do
    result = :code.soft_purge(module_name)
    Logger.debug("[HotCode] soft_purge #{module_name}: #{result}")
    result
  end

  @doc "Delete a module from the code server entirely (stops the module)."
  @spec delete(module()) :: boolean()
  def delete(module_name) do
    :code.delete(module_name)
  end

  @doc "Return the MD5 hash of the currently loaded version of a module."
  @spec module_md5(module()) :: String.t() | nil
  def module_md5(module_name) do
    module_name.module_info(:md5) |> Base.encode16()
  rescue
    _ -> nil
  end

  # ── Private ───────────────────────────────────────────────────────────────

  defp module_names(modules) do
    modules |> Enum.map(fn {name, _} -> name end) |> Enum.join(", ")
  end
end
