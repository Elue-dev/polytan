defmodule Polytan.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, :uuid
      add :email, :string
      add :role, :string
      add :token, :string
      add :expires_at, :utc_datetime
      add :invited_by, :uuid
      add :accepted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
