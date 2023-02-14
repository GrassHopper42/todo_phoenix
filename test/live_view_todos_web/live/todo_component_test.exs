defmodule LiveViewTodosWeb.TodoComponentTest do
  use LiveViewTodosWeb.ConnCase
  import Phoenix.LiveViewTest
  alias LiveViewTodos.Todo

  test "disconnected and connected mount", %{conn: conn} do
    {:ok, todo_live, html} = live(conn, "/")

    html =
      todo_live
      |> element(".todo-list")
      |> render()

    assert html =~ "class=\"todo-list\""
    refute html =~ "What needs to be done"
  end

  test "toggle an todo", %{conn: conn} do
    {:ok, todo} = Todo.create_todo(%{"content" => "Learn LiveViewTest"})
    assert todo.status == 0

    assert Todo.count_todos() == 1

    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#todo-#{todo.id}")
    |> render_click(%{"id" => todo.id, "value" => 1})
    |> (&assert(&1 =~ "completed")).()

    updated_todo = Todo.get_todo!(todo.id)
    assert updated_todo.status == 1

    assert Todo.count_todos() == 0
  end

  test "delete an todo", %{conn: conn} do
    {:ok, todo} = Todo.create_todo(%{"content" => "Learn Elixir"})
    assert todo.status == 0

    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#delete-todo-#{todo.id}")
    |> render_click(%{"id" => todo.id})
    |> (&assert(&1)).()

    updated_todo = Todo.get_todo!(todo.id)
    assert updated_todo.status == 2
  end

  test "edit todo", %{conn: conn} do
    {:ok, todo} = Todo.create_todo(%{"content" => "Learn Elixir"})

    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#edit-todo-#{todo.id}")
    |> render_click(%{"id" => Integer.to_string(todo.id)})
    |> (&assert(&1 =~ "<form phx-submit=\"update-todo\" id=\"form-update\"")).()
  end

  test "update an todo", %{conn: conn} do
    {:ok, todo} = Todo.create_todo(%{"content" => "Learn Elixir"})

    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#edit-todo-#{todo.id}")
    |> render_click(%{"id" => Integer.to_string(todo.id)})
    |> (&assert(&1 =~ "<form phx-submit=\"update-todo\" id=\"form-update\"")).()

    view
    |> element("#form-update")
    |> render_submit(%{"id" => todo.id, "content" => "Learn more Elixir"})
    |> (&assert(&1 =~ "Learn more Elixir")).()

    updated_todo = Todo.get_todo!(todo.id)
    assert updated_todo.content == "Learn more Elixir"
  end
end
