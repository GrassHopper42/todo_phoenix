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
end
