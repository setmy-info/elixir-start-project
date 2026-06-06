defmodule SetmyInfo.Ecto.Persons do
  @moduledoc """
  Context for managing `Person` records.

  All database access goes through `SetmyInfo.Ecto.Repo`.  Call site code
  should only depend on this context, not on the schema or the repo directly.

  ## Usage

      alias SetmyInfo.Ecto.Persons

      {:ok, person} = Persons.create_person(%{first_name: "Alice", last_name: "Smith"})
      persons = Persons.list_persons()
  """

  alias SetmyInfo.Ecto.{Person, Repo}

  @doc "Insert a new person from the given attributes."
  @spec create_person(map()) :: {:ok, Person.t()} | {:error, Ecto.Changeset.t()}
  def create_person(attrs) do
    %Person{}
    |> Person.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Return all persons in insertion order."
  @spec list_persons() :: [Person.t()]
  def list_persons do
    Repo.all(Person)
  end

  @doc "Return a single person by id, or `nil` if not found."
  @spec get_person(integer()) :: Person.t() | nil
  def get_person(id), do: Repo.get(Person, id)

  @doc "Delete a person by struct."
  @spec delete_person(Person.t()) :: {:ok, Person.t()} | {:error, Ecto.Changeset.t()}
  def delete_person(%Person{} = person), do: Repo.delete(person)
end
