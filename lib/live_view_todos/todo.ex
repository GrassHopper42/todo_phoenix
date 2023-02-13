defmodule LiveViewTodos.Todo do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias LiveViewTodos.Repo
  alias __MODULE__

  schema "todos" do
    field :content, :string
    field :status, :integer, default: 0
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:content, :user_id, :status])
    |> validate_required([:content])
  end

  @doc """
  Creates a todo.

  ## Examples

  iex> create_todo(%{content: "Learn LiveView"})
  {:ok, %Todo{}}

  iex> create_todo(%{content: nil})
  {:error, %Ecto.Changeset{}}

  """
  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

  iex> get_todo!(123)
  %Todo{}

  iex> get_todo!(456)
  ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  @doc """
  Returns the list of todos.

  ## Examples

  iex> list_todos()
  [%Todo{}, ...]

  """
  def list_todos do
    Todo
    |> order_by(desc: :inserted_at)
    |> where([t], is_nil(t.status) or t.status != 2)
    |> Repo.all()
  end

  @doc """
  Updates a todo.

  ## Examples

  iex> update_todo(todo, %{field: new_value})
  {:ok, %Todo{}}

  iex> update_todo(todo, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Todo.

  ## Examples

  iex> delete_todo(id)
  {:ok, %Todo{}}
  """
  def delete_todo(id) do
    get_todo!(id)
    |> changeset(%{status: 2})
    |> Repo.update()
  end

  def complete_all do
    Repo.update_all(
      from(t in Todo, where: t.status == 0),
      set: [status: 1]
    )
  end

  def clear_completed do
    completed_todos = from(t in Todo, where: t.status == 1)
    Repo.update_all(completed_todos, [set: [status: 2]])
  end
end
