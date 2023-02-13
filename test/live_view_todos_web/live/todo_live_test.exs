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

  test "Filter todo", %{conn: conn} do
    {:ok, todo1} = Todo.create_todo(%{"content" => "Learn Elixir"})
    {:ok, todo2} = Todo.create_todo(%{"content" => "Learn Phoenix"})

    {:ok, view, _html} = live(conn, "/")
    view
    |> element("#todo-#{todo1.id}")
    |> render_click(%{"id" => todo1.id, "value" => 1})
    |> (& assert &1 =~ "completed").()

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

    view
    |> element("#todo-#{todo1.id}")
    |> render_click(%{"id" => todo1.id, "value" => 1})
    |> (& assert &1 =~ "completed").()

    view = render_click(view, "clear-completed", %{})
    assert view =~ "Learn Phoenix"
    refute view =~ "Learn Elixir"
  end
end
