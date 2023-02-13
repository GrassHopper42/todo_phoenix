defmodule LiveViewTodos.TodoTest do
  use LiveViewTodos.DataCase
  alias LiveViewTodos.Todo

  describe "todos" do
    @valid_attrs %{content: "some content", status: 0, user_id: 1}
    @update_attrs %{content: "some updated content", status: 0}
    @invalid_attrs %{content: nil}

    def todo_fixture(attrs \\ %{}) do
      {:ok, todo} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Todo.create_todo()

      todo
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture(@valid_attrs)
      assert Todo.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      assert {:ok, %Todo{} = todo} = Todo.create_todo(@valid_attrs)
      assert todo.content == "some content"

      inserted_todo = List.first(Todo.list_todos())
      assert inserted_todo.content == @valid_attrs.content
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todo.create_todo(@invalid_attrs)
    end

    test "list_todos/0 returns a list of todo todos stored in the DB" do
      todo1 = todo_fixture()
      todo2 = todo_fixture()
      todos = Todo.list_todos()

      assert Enum.member?(todos, todo1)
      assert Enum.member?(todos, todo2)
    end

    test "update_todo/2 with valid data updates the todo todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{} = todo} = Todo.update_todo(todo, @update_attrs)
      assert todo.content == "some updated content"
    end

    test "delete_todo/1 soft-deletes an todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{} = deleted_todo} = Todo.delete_todo(todo.id)
      assert deleted_todo.status == 2
    end
  end
end
