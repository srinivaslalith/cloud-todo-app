from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from .database import Base, engine, get_db
from . import models, schemas

# Create tables on startup (for demo/local). In prod, use Alembic migrations.
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Cloud Todo API", version="1.0.0")

# CORS for local dev & frontend svc
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Prometheus metrics
from prometheus_fastapi_instrumentator import Instrumentator
Instrumentator().instrument(app).expose(app, endpoint="/metrics")

@app.get("/healthz")
def healthz():
    return {"status": "ok"}

@app.post("/todos", response_model=schemas.TodoRead, status_code=201)
def create_todo(payload: schemas.TodoCreate, db: Session = Depends(get_db)):
    todo = models.Todo(title=payload.title)
    db.add(todo)
    db.commit()
    db.refresh(todo)
    return todo

@app.get("/todos", response_model=list[schemas.TodoRead])
def list_todos(db: Session = Depends(get_db)):
    return db.query(models.Todo).order_by(models.Todo.id.desc()).all()

@app.patch("/todos/{todo_id}", response_model=schemas.TodoRead)
def update_todo(todo_id: int, payload: schemas.TodoUpdate, db: Session = Depends(get_db)):
    todo = db.get(models.Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    if payload.title is not None:
        todo.title = payload.title
    if payload.completed is not None:
        todo.completed = payload.completed
    db.commit()
    db.refresh(todo)
    return todo

@app.delete("/todos/{todo_id}", status_code=204)
def delete_todo(todo_id: int, db: Session = Depends(get_db)):
    todo = db.get(models.Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    db.delete(todo)
    db.commit()
    return
