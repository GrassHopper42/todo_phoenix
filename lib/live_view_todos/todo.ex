defmodule LiveViewTodos.Todo do
  use Ecto.Schema
  import Ecto.Changeset
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
    Repo.all(Todo)
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
end
