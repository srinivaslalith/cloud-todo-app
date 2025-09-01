const API_BASE = (window.API_BASE || "http://localhost:8000");

async function fetchTodos() {
  const res = await fetch(`${API_BASE}/todos`);
  const data = await res.json();
  const list = document.getElementById("todo-list");
  list.innerHTML = "";
  data.forEach(todo => {
    const li = document.createElement("li");
    const left = document.createElement("div");
    left.className = "left";
    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.checked = todo.completed;
    checkbox.addEventListener("change", () => toggle(todo.id, checkbox.checked));
    const title = document.createElement("span");
    title.textContent = todo.title;
    if (todo.completed) title.style.textDecoration = "line-through";
    const idBadge = document.createElement("span");
    idBadge.className = "badge";
    idBadge.textContent = `#${todo.id}`;
    left.appendChild(checkbox);
    left.appendChild(idBadge);
    left.appendChild(title);

    const actions = document.createElement("div");
    actions.className = "actions";
    const doneBtn = document.createElement("button");
    doneBtn.className = "done";
    doneBtn.textContent = "Toggle";
    doneBtn.onclick = () => toggle(todo.id, !todo.completed);
    const delBtn = document.createElement("button");
    delBtn.className = "delete";
    delBtn.textContent = "Delete";
    delBtn.onclick = () => remove(todo.id);
    actions.appendChild(doneBtn);
    actions.appendChild(delBtn);

    li.appendChild(left);
    li.appendChild(actions);
    list.appendChild(li);
  });
}

async function addTodo() {
  const title = document.getElementById("todo-title").value.trim();
  if (!title) return;
  await fetch(`${API_BASE}/todos`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title })
  });
  document.getElementById("todo-title").value = "";
  fetchTodos();
}

async function toggle(id, completed) {
  await fetch(`${API_BASE}/todos/${id}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ completed })
  });
  fetchTodos();
}

async function remove(id) {
  await fetch(`${API_BASE}/todos/${id}`, { method: "DELETE" });
  fetchTodos();
}

document.getElementById("add-btn").addEventListener("click", addTodo);
document.getElementById("todo-title").addEventListener("keydown", (e) => {
  if (e.key === "Enter") addTodo();
});

fetchTodos();
