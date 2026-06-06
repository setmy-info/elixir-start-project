defmodule SetmyInfo.Ecto.Repo.Migrations.CreatePersons do
  use Ecto.Migration

  def change do
    create table(:persons) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      timestamps()
    end
  end
end
