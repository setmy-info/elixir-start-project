defmodule SetmyInfo.CoreLogic.Persons do
  alias SetmyInfo.CoreLogic.{Repo, Person}

  def create_person(attrs) do
    %Person{}
    |> Person.changeset(attrs)
    |> Repo.insert()
  end

  def list_persons do
    Repo.all(Person)
  end
end
