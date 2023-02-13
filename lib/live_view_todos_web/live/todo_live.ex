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
    LiveViewTodosWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle", data, socket) do
    status = if Map.has_key?(data, "value"), do: 1, else: 0
    todo = Todo.get_todo!(Map.get(data, "id"))
    Todo.update_todo(todo, %{id: todo.id, status: status})
    socket = assign(socket, todos: Todo.list_todos(), active: %Todo{})
    LiveViewTodosWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", data, socket) do
    Todo.delete_todo(Map.get(data, "id"))
    socket = assign(socket, todos: Todo.list_todos(), active: %Todo{})
    LiveViewTodosWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit-todo", data, socket) do
    {:noreply, assign(socket, editing: String.to_integer(Map.get(data, "id")))}
  end

  @impl true
  def handle_event("update-todo", %{"id" => todo_id, "content" => content}, socket) do
    current_todo = Todo.get_todo!(todo_id)
    Todo.update_todo(current_todo, %{content: content})
    todos = Todo.list_todos()
    socket = assign(socket, todos: todos, editing: nil)
    LiveViewTodosWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "update", payoad: %{todos: todos}}, socket) do
    {:noreply, assign(socket, todos: todos)}
  end

  def checked?(todo) do
    not is_nil(todo.status) and todo.status > 0
  end

  def completed?(todo) do
    if not is_nil(todo.status) and todo.status > 0, do: "completed", else: ""
  end
end
