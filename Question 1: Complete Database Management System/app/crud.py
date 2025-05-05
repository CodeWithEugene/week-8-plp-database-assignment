import aiomysql
from .models import TaskCreate, TaskUpdate, Task
from typing import List, Optional
import logging

logger = logging.getLogger(__name__)

async def create_task(db: aiomysql.Connection, task: TaskCreate) -> Optional[Task]:
    """Creates a new task in the database."""
    query = """
        INSERT INTO tasks (title, description, status, due_date)
        VALUES (%s, %s, %s, %s)
    """
    values = (task.title, task.description, task.status, task.due_date)
    try:
        async with db.cursor() as cursor:
            await cursor.execute(query, values)
            # await db.commit() # Not needed if autocommit=True in pool config
            new_task_id = cursor.lastrowid
            logger.info(f"Task created with ID: {new_task_id}")
            return await get_task(db, new_task_id) # Fetch the created task
    except Exception as e:
        logger.error(f"Error creating task: {e}")
        # await db.rollback() # Rollback might be needed if autocommit=False
        return None

async def get_task(db: aiomysql.Connection, task_id: int) -> Optional[Task]:
    """Retrieves a single task by its ID."""
    query = "SELECT * FROM tasks WHERE task_id = %s"
    try:
        async with db.cursor(aiomysql.DictCursor) as cursor: # Ensure DictCursor here too
            await cursor.execute(query, (task_id,))
            result = await cursor.fetchone()
            if result:
                return Task(**result)
            return None
    except Exception as e:
        logger.error(f"Error retrieving task {task_id}: {e}")
        return None

async def get_tasks(db: aiomysql.Connection, skip: int = 0, limit: int = 100) -> List[Task]:
    """Retrieves a list of tasks with pagination."""
    query = "SELECT * FROM tasks ORDER BY created_at DESC LIMIT %s OFFSET %s"
    tasks = []
    try:
        async with db.cursor(aiomysql.DictCursor) as cursor:
            await cursor.execute(query, (limit, skip))
            results = await cursor.fetchall()
            for row in results:
                tasks.append(Task(**row))
            return tasks
    except Exception as e:
        logger.error(f"Error retrieving tasks: {e}")
        return []

async def update_task(db: aiomysql.Connection, task_id: int, task_update: TaskUpdate) -> Optional[Task]:
    """Updates an existing task."""
    # Fetch existing task first to make sure it exists
    existing_task = await get_task(db, task_id)
    if not existing_task:
        return None # Task not found

    # Build the update query dynamically based on provided fields
    update_data = task_update.model_dump(exclude_unset=True) # Get only fields that were provided
    if not update_data:
        return existing_task # No changes provided, return existing task

    set_clause = ", ".join([f"{key} = %s" for key in update_data.keys()])
    query = f"UPDATE tasks SET {set_clause} WHERE task_id = %s"
    values = list(update_data.values()) + [task_id]

    try:
        async with db.cursor() as cursor:
            await cursor.execute(query, tuple(values))
            # await db.commit() # Not needed if autocommit=True
            if cursor.rowcount == 0:
                 logger.warning(f"Update attempted but no rows affected for task_id: {task_id}")
                 # This might happen in a race condition, refetch or return None/existing
                 return await get_task(db, task_id) # Re-fetch to be safe
            logger.info(f"Task {task_id} updated successfully.")
            return await get_task(db, task_id) # Fetch the updated task
    except Exception as e:
        logger.error(f"Error updating task {task_id}: {e}")
        # await db.rollback() # Consider rollback if autocommit=False
        return None

async def delete_task(db: aiomysql.Connection, task_id: int) -> bool:
    """Deletes a task by its ID."""
    query = "DELETE FROM tasks WHERE task_id = %s"
    try:
        async with db.cursor() as cursor:
            await cursor.execute(query, (task_id,))
            # await db.commit() # Not needed if autocommit=True
            if cursor.rowcount > 0:
                logger.info(f"Task {task_id} deleted successfully.")
                return True
            else:
                logger.warning(f"Delete attempted but task_id {task_id} not found.")
                return False # Task not found
    except Exception as e:
        logger.error(f"Error deleting task {task_id}: {e}")
        # await db.rollback() # Consider rollback if autocommit=False
        return False
