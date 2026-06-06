defmodule SetmyInfo.Ecto.Person do
  @moduledoc """
  Ecto schema for the `persons` table.

  ## Fields

  - `first_name` — required string
  - `last_name`  — required string
  - `inserted_at` / `updated_at` — auto-managed timestamps

  ## Usage

      alias SetmyInfo.Ecto.Person

      changeset = Person.changeset(%Person{}, %{first_name: "Alice", last_name: "Smith"})
      changeset.valid?  # => true
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "persons" do
    field(:first_name, :string)
    field(:last_name, :string)
    timestamps()
  end

  @doc "Build a validated changeset for inserting or updating a `Person`."
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end
