defmodule ElixirApiJwt.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :email, :string
      add :hash_password, :text

      timestamps(type: :utc_datetime)
    end
  end
end
