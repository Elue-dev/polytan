defmodule Polytan.Repo.Migrations.CreateAccountMemberships do
  use Ecto.Migration

  def change do
    create table(:account_memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :account_id,
          references(:accounts, type: :binary_id, on_delete: :delete_all),
          null: false

      add :user_id,
          references(:users, type: :binary_id, on_delete: :delete_all),
          null: false

      add :permissions, {:array, :text}
      add :status, :string

      add :invited_at, :utc_datetime
      add :joined_at, :utc_datetime

      add :invited_by,
          references(:users, type: :binary_id, on_delete: :nothing)

      add :removed_by,
          references(:users, type: :binary_id, on_delete: :nothing)

      add :removed_reason, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(
             :account_memberships,
             [:account_id, :user_id]
           )

    create index(:account_memberships, [:user_id])
    create index(:account_memberships, [:account_id])
  end
end
