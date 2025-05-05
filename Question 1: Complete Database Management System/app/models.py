from pydantic import BaseModel, Field
from typing import Optional, Literal
from datetime import date, datetime

# Define possible task statuses
TaskStatus = Literal['pending', 'in_progress', 'completed']

class TaskBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255, description="The title of the task")
    description: Optional[str] = Field(None, description="A detailed description of the task")
    status: TaskStatus = Field(default='pending', description="The current status of the task")
    due_date: Optional[date] = Field(None, description="The date the task is due")

    # Example for validation (optional)
    # @validator('due_date')
    # def due_date_must_be_in_future(cls, v):
    #     if v and v < date.today():
    #         raise ValueError('Due date must be today or in the future')
    #     return v

class TaskCreate(TaskBase):
    # Inherits all fields from TaskBase
    pass # No additional fields needed for creation

class TaskUpdate(BaseModel):
    # All fields are optional for updates
    title: Optional[str] = Field(None, min_length=1, max_length=255, description="The title of the task")
    description: Optional[str] = Field(None, description="A detailed description of the task")
    status: Optional[TaskStatus] = Field(None, description="The current status of the task")
    due_date: Optional[date] = Field(None, description="The date the task is due")


class Task(TaskBase):
    task_id: int = Field(..., description="The unique identifier for the task")
    created_at: datetime = Field(..., description="Timestamp when the task was created")
    updated_at: datetime = Field(..., description="Timestamp when the task was last updated")

    class Config:
        from_attributes = True # Pydantic V2 uses this instead of orm_mode
