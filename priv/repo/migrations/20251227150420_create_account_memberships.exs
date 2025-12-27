defmodule Polytan.Repo.Migrations.CreateAccountMemberships do
  use Ecto.Migration

  def change do
    create table(:account_memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, :uuid
      add :user_id, :uuid
      add :permissions, {:array, :text}
      add :status, :string
      add :invited_at, :utc_datetime
      add :joined_at, :utc_datetime
      add :invited_by, :uuid
      add :removed_by, :uuid
      add :removed_reason, :text

      timestamps(type: :utc_datetime)
    end
  end
end
