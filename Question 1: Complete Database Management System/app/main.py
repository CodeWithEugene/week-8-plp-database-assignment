from fastapi import FastAPI, Depends, HTTPException, status, Query
from typing import List, Optional
import aiomysql # Import necessary library
import logging

from . import crud, models, database

# Configure logging (optional but recommended)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app instance
app = FastAPI(
    title="Task Manager API",
    description="A simple API to manage tasks using FastAPI and MySQL.",
    version="1.0.0"
)

# --- Dependency ---
# This dependency ensures we get a connection for each request
# that needs one. The connection is automatically released.
async def get_db():
    pool = await database.get_db_pool()
    async with pool.acquire() as connection:
        try:
            yield connection
        finally:
            # The connection is automatically released back to the pool
            pass

# --- Event Handlers ---
@app.on_event("startup")
async def startup_event():
    logger.info("Application startup...")
    await database.get_db_pool() # Initialize pool on startup
    logger.info("Database pool initialized.")


@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Application shutdown...")
    await database.close_db_pool()
    logger.info("Database pool closed.")


# --- API Endpoints ---

# CREATE Task
@app.post("/tasks/", response_model=models.Task, status_code=status.HTTP_201_CREATED, summary="Create a new task")
async def create_new_task(task: models.TaskCreate, db: aiomysql.Connection = Depends(get_db)):
    """
    Creates a new task with the provided details.
    - **title**: The mandatory title of the task.
    - **description**: Optional description.
    - **status**: Status ('pending', 'in_progress', 'completed'), defaults to 'pending'.
    - **due_date**: Optional due date in YYYY-MM-DD format.
    """
    created_task = await crud.create_task(db=db, task=task)
    if created_task is None:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Could not create task")
    return created_task

# READ All Tasks (with optional filtering and pagination)
@app.get("/tasks/", response_model=List[models.Task], summary="Retrieve multiple tasks")
async def read_tasks(
    skip: int = Query(0, ge=0, description="Number of tasks to skip"),
    limit: int = Query(100, ge=1, le=200, description="Maximum number of tasks to return"),
    db: aiomysql.Connection = Depends(get_db)
):
    """
    Retrieves a list of tasks, supporting pagination.
    """
    tasks = await crud.get_tasks(db=db, skip=skip, limit=limit)
    return tasks

# READ Single Task
@app.get("/tasks/{task_id}", response_model=models.Task, summary="Retrieve a single task by ID")
async def read_task(task_id: int, db: aiomysql.Connection = Depends(get_db)):
    """
    Retrieves the details of a specific task by its unique ID.
    """
    db_task = await crud.get_task(db=db, task_id=task_id)
    if db_task is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    return db_task

# UPDATE Task
@app.put("/tasks/{task_id}", response_model=models.Task, summary="Update an existing task")
async def update_existing_task(task_id: int, task: models.TaskUpdate, db: aiomysql.Connection = Depends(get_db)):
    """
    Updates the details of an existing task. Provide only the fields you want to change.
    """
    updated_task = await crud.update_task(db=db, task_id=task_id, task_update=task)
    if updated_task is None:
        # Distinguish between not found and other update errors if needed
        # Check if the task existed before update attempt if crud doesn't return None on success
        existing = await crud.get_task(db=db, task_id=task_id)
        if existing is None:
             raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
        else:
             # If task exists but update failed for other reason (rare with this setup)
             raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Could not update task")
    return updated_task

# DELETE Task
@app.delete("/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Delete a task")
async def delete_existing_task(task_id: int, db: aiomysql.Connection = Depends(get_db)):
    """
    Deletes a specific task by its unique ID. Returns 204 No Content on success.
    """
    success = await crud.delete_task(db=db, task_id=task_id)
    if not success:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    # No content to return on successful delete
    return None # FastAPI handles the 204 response code correctly here

# Health Check Endpoint (Optional)
@app.get("/health", status_code=status.HTTP_200_OK, summary="Health check endpoint")
async def health_check():
    return {"status": "healthy"}
