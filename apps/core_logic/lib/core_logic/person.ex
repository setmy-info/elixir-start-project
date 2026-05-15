defmodule SetmyInfo.CoreLogic.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "persons" do
    field(:first_name, :string)
    field(:last_name, :string)
    timestamps()
  end

  def changeset(person, attrs) do
    person
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end
