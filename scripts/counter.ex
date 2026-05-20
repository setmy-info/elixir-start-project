defmodule Counter do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def inc_text(text) do
    count = inc()
    text <> " | counter: #{count}"
  end

  def inc() do
    Agent.get_and_update(__MODULE__, fn state ->
      new_state = state + 1
      {new_state, new_state}
    end)
  end
end
