defmodule LiveViewTodosWeb.TodoLiveTest do
  use LiveViewTodosWeb.ConnCase
  import Phoenix.LiveViewTest
  alias LiveViewTodos.Todo

  test "disconnected and connected mount", %{conn: conn} do
    {:ok, todo_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Todo"
    assert render(todo_live) =~ "What needs to be done"
  end

  test "connect and create a todo", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert render_submit(view, :create, %{"content" => "Learn LiveView"}) =~ "Learn LiveView"
  end

  test "toggle an todo", %{conn: conn} do
    {:ok, todo} = Todo.create_todo(%{"content" => "Learn Elixir"})
    assert todo.status == 0

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :toggle, %{"id" => todo.id, "value" => 1}) =~ "completed"

    updated_todo = Todo.get_todo!(todo.id)
    assert updated_todo.status == 1
  end

  test "delete an todo", %{conn: conn} do
    {:ok, todo} = Todo.create_todo(%{"content" => "Learn Elixir"})
    assert todo.status == 0

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :delete, %{"id" => todo.id})

    updated_todo = Todo.get_todo!(todo.id)
    assert updated_todo.status == 2
  end

  test "edit todo", %{conn: conn} do
    {:ok, todo} = Todo.create_todo(%{"content" => "Learn Elixir"})

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, "edit-todo", %{"id" => Integer.to_string(todo.id)}) =~ "<form phx-submit=\"update-todo\" id=\"form-update\">"
  end

  test "update an todo", %{conn: conn} do
    {:ok, todo} = Todo.create_todo(%{"content" => "Learn Elixir"})

    {:ok, view, _html} = live(conn, "/")

    assert render_submit(view, "update-todo", %{"id" => todo.id, "content" => "Learn more Elixir"}) =~ "Learn more Elixir"

    updated_todo = Todo.get_todo!(todo.id)
    assert updated_todo.content == "Learn more Elixir"
  end

  test "Filter todo", %{conn: conn} do
    {:ok, todo1} = Todo.create_todo(%{"content" => "Learn Elixir"})
    {:ok, todo2} = Todo.create_todo(%{"content" => "Learn Phoenix"})

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :toggle, %{"id" => todo1.id, "value" => 1}) =~ "completed"

    {:ok, view, _html} = live(conn, "/?filter_by=completed")
    assert render(view) =~ "Learn Elixir"
    refute render(view) =~ "Learn Phoenix"

    {:ok, view, _html} = live(conn, "/?filter_by=active")
    refute render(view) =~ "Learn Elixir"
    assert render(view) =~ "Learn Phoenix"

    {:ok, view, _html} = live(conn, "/?filter_by=all")
    assert render(view) =~ "Learn Elixir"
    assert render(view) =~ "Learn Phoenix"
  end

  test "clear completed todos", %{conn: conn} do
    {:ok, todo1} = Todo.create_todo(%{"content" => "Learn Elixir"})
    {:ok, _todo2} = Todo.create_todo(%{"content" => "Learn Phoenix"})

    {:ok, view, _html} = live(conn, "/")
    assert render(view) =~ "Learn Elixir"
    assert render(view) =~ "Learn Phoenix"

    assert render_click(view, :toggle, %{"id" => todo1.id, "value" => 1}) =~ "completed"

    view = render_click(view, "clear-completed", %{})
    assert view =~ "Learn Phoenix"
    refute view =~ "Learn Elixir"
  end
end
