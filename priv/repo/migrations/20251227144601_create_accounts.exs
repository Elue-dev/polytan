defmodule Polytan.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :status, :string, null: false

      add :owner_id,
          references(:users, type: :binary_id, on_delete: :nothing),
          null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounts, [:name])

    create index(:accounts, [:owner_id])
  end
end
