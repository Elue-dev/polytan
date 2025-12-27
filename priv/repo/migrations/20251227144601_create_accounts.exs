defmodule Polytan.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :status, :string
      add :owner_id, :uuid

      timestamps(type: :utc_datetime)
    end
  end
end
