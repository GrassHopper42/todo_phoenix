defmodule LiveViewTodosWeb.TodoComponent do
  use LiveViewTodosWeb, :live_component
  alias LiveViewTodos.Todo

  @topic "live"

  attr(:todos, :list, default: [])
  attr(:editing, :string, default: nil)

  def render(assigns) do
    ~H"""
    <ul class="todo-list">
      <%= for todo <- @todos do %>
        <%= if todo.id == @editing do %>
          <form phx-submit="update-todo" id="form-update" phx-target={@myself}>
            <input
              id="update_todo"
              class="new-todo"
              type="text"
              name="content"
              required="required"
              value={todo.content}
              phx-hook="FocusInputItem"
            />
            <input type="hidden" name="id" value={todo.id} />
          </form>
        <% else %>
          <li data-id={todo.id} class={completed?(todo)}>
            <div class="view">
              <input
                class="toggle"
                type="checkbox"
                phx-value-id={todo.id}
                phx-click="toggle"
                checked={checked?(todo)}
                phx-target={@myself}
                id={"todo-#{todo.id}"}
              />
              <label
                phx-click="edit-todo"
                phx-value-id={todo.id}
                phx-target={@myself}
                id={"edit-todo-#{todo.id}"}
              >
                <%= todo.content %>
              </label>
              <button
                class="destroy"
                phx-click="delete"
                phx-value-id={todo.id}
                phx-target={@myself}
                id={"delete-todo-#{todo.id}"}
              >
              </button>
            </div>
          </li>
        <% end %>
      <% end %>
    </ul>
    """
  end

  @impl true
  def handle_event("toggle", data, socket) do
    status = if Map.has_key?(data, "value"), do: 1, else: 0
    todo = Todo.get_todo!(Map.get(data, "id"))
    Todo.update_todo(todo, %{id: todo.id, status: status})
    socket = assign(socket, todos: Todo.list_todos(), active: %Todo{})
    LiveViewTodosWeb.Endpoint.broadcast(@topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", data, socket) do
    Todo.delete_todo(Map.get(data, "id"))
    socket = assign(socket, todos: Todo.list_todos(), active: %Todo{})
    LiveViewTodosWeb.Endpoint.broadcast(@topic, "update", socket.assigns)
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
    socket = assign(socket, todos: Todo.list_todos(), editing: nil)
    LiveViewTodosWeb.Endpoint.broadcast(@topic, "update", socket.assigns)
    {:noreply, socket}
  end

  def checked?(todo) do
    not is_nil(todo.status) and todo.status > 0
  end

  def completed?(todo) do
    if not is_nil(todo.status) and todo.status > 0, do: "completed", else: ""
  end
end
