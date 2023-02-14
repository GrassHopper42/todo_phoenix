defmodule LiveViewTodosWeb.TodoLive do
  use LiveViewTodosWeb, :live_view
  alias LiveViewTodos.Todo

  @topic "live"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: LiveViewTodosWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, todos: Todo.list_todos(), editing: nil)}
  end

  @impl true
  def handle_event("create", %{"content" => content}, socket) do
    Todo.create_todo(%{content: content})
    socket = assign(socket, todos: Todo.list_todos(), active: %Todo{})
    LiveViewTodosWeb.Endpoint.broadcast(@topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear-completed", _data, socket) do
    Todo.clear_completed()
    socket = assign(socket, todos: Todo.list_todos(), active: %Todo{})
    LiveViewTodosWeb.Endpoint.broadcast(@topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("complete-all", _data, socket) do
    Todo.complete_all()
    socket = assign(socket, todos: Todo.list_todos(), active: %Todo{})
    LiveViewTodosWeb.Endpoint.broadcast(@topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "update", payload: %{todos: todos}}, socket) do
    {:noreply, assign(socket, todos: todos)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    todos = Todo.list_todos()

    case params["filter_by"] do
      "completed" ->
        completed = Enum.filter(todos, &(&1.status == 1))
        {:noreply, assign(socket, todos: completed)}

      "active" ->
        active = Enum.filter(todos, &(&1.status == 0))
        {:noreply, assign(socket, todos: active)}

      _ ->
        {:noreply, assign(socket, todos: todos)}
    end
  end

  def completed_all?(todos) do
    Enum.all?(todos, &(&1.status != 0))
  end

  def count_todos() do
    Todo.count_todos()
  end
end
