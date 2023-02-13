defmodule LiveViewTodos.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :content, :string
      add :user_id, :integer
      add :status, :integer, default: 0

      timestamps()
    end
  end
end
