defmodule SetmyInfo.Integration.EctoPersonsTest do
  use ExUnit.Case, async: false

  alias SetmyInfo.Ecto.{Person, Persons, Repo}

  setup_all do
    migrations_path = Application.app_dir(:calculator_app, "priv/repo/migrations")
    Ecto.Migrator.run(Repo, migrations_path, :up, all: true)
    :ok
  end

  setup do
    Repo.delete_all(Person)
    :ok
  end

  describe "Person changeset" do
    test "valid when both fields are present" do
      cs = Person.changeset(%Person{}, %{first_name: "Alice", last_name: "Smith"})
      assert cs.valid?
    end

    test "invalid when first_name is missing" do
      cs = Person.changeset(%Person{}, %{last_name: "Smith"})
      refute cs.valid?
      assert cs.errors[:first_name]
    end

    test "invalid when last_name is missing" do
      cs = Person.changeset(%Person{}, %{first_name: "Alice"})
      refute cs.valid?
      assert cs.errors[:last_name]
    end

    test "invalid when both fields are missing" do
      cs = Person.changeset(%Person{}, %{})
      refute cs.valid?
      assert cs.errors[:first_name]
      assert cs.errors[:last_name]
    end
  end

  describe "Persons.create_person/1" do
    test "inserts a valid person and returns {:ok, person}" do
      assert {:ok, %Person{id: id, first_name: "Alice", last_name: "Smith"}} =
               Persons.create_person(%{first_name: "Alice", last_name: "Smith"})

      assert is_integer(id)
    end

    test "returns {:error, changeset} for missing fields" do
      assert {:error, changeset} = Persons.create_person(%{first_name: "Alice"})
      refute changeset.valid?
      assert changeset.errors[:last_name]
    end

    test "sets timestamps on insert" do
      {:ok, person} = Persons.create_person(%{first_name: "Alice", last_name: "Smith"})
      assert %NaiveDateTime{} = person.inserted_at
      assert %NaiveDateTime{} = person.updated_at
    end
  end

  describe "Persons.list_persons/0" do
    test "returns empty list when no persons exist" do
      assert Persons.list_persons() == []
    end

    test "returns all inserted persons" do
      {:ok, _} = Persons.create_person(%{first_name: "Alice", last_name: "Smith"})
      {:ok, _} = Persons.create_person(%{first_name: "Bob", last_name: "Jones"})
      {:ok, _} = Persons.create_person(%{first_name: "Carol", last_name: "White"})

      persons = Persons.list_persons()
      assert length(persons) == 3
      names = Enum.map(persons, & &1.first_name)
      assert "Alice" in names
      assert "Bob" in names
      assert "Carol" in names
    end
  end

  describe "Persons.get_person/1" do
    test "returns the person with the given id" do
      {:ok, created} = Persons.create_person(%{first_name: "Alice", last_name: "Smith"})
      found = Persons.get_person(created.id)
      assert found.id == created.id
      assert found.first_name == "Alice"
    end

    test "returns nil for a non-existent id" do
      assert Persons.get_person(999_999) == nil
    end
  end

  describe "Persons.delete_person/1" do
    test "removes the person from the database" do
      {:ok, person} = Persons.create_person(%{first_name: "Alice", last_name: "Smith"})
      assert {:ok, _deleted} = Persons.delete_person(person)
      assert Persons.get_person(person.id) == nil
    end
  end
end
