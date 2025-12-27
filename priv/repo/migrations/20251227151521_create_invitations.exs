defmodule Polytan.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :account_id,
          references(:accounts, type: :binary_id, on_delete: :delete_all),
          null: false

      add :email, :string, null: false
      add :permissions, {:array, :text}

      add :token, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :accepted_at, :utc_datetime

      add :invited_by,
          references(:users, type: :binary_id, on_delete: :nothing),
          null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:invitations, [:token])
    create index(:invitations, [:account_id])
    create index(:invitations, [:email])
  end
end
