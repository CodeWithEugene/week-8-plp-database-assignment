# Comprehensive Database and API Project: Library System & Task Manager

## Project Overview

This repository contains two distinct but related projects demonstrating database design and API development skills:

1.  **Library Management Database (MySQL):** A complete relational database schema designed and implemented purely in SQL for managing a library system. This includes tables, relationships, constraints, and sample data.
2.  **Task Manager CRUD API (FastAPI + MySQL):** A simple but functional web API built with Python (FastAPI) that connects to a MySQL database to perform Create, Read, Update, and Delete (CRUD) operations on tasks.

The goal is to showcase proficiency in database design using MySQL and backend API development integrating a database.

## Table of Contents

*   [Part 1: Library Management Database (MySQL)](#part-1-library-management-database-mysql)
    *   [Description](#description-library)
    *   [Database Schema / ERD](#database-schema--erd-library)
    *   [Setup and Usage](#setup-and-usage-library)
*   [Part 2: Task Manager CRUD API (FastAPI + MySQL)](#part-2-task-manager-crud-api-fastapi--mysql)
    *   [Description](#description-api)
    *   [Features](#features-api)
    *   [Technologies Used](#technologies-used-api)
    *   [Database Schema / ERD](#database-schema--erd-api)
    *   [Setup Instructions](#setup-instructions-api)
    *   [Running the API](#running-the-api)
    *   [API Endpoints & Documentation](#api-endpoints--documentation)
*   [Project Structure](#project-structure)
*   [Contributing](#contributing)
*   [License](#license)

--- 

## Part 1: Library Management Database (MySQL)

<a name="description-library"></a>
### Description

This component focuses solely on database design and implementation using SQL. It models a simplified Library Management System, capable of tracking books, authors, publishers, genres, library members, and book loans.

The primary deliverable for this part is the `library_db.sql` file, which contains all the necessary SQL statements to create the database structure and populate it with initial sample data.

<a name="database-schema--erd-library"></a>
### Database Schema / ERD

The database uses a relational model with the following core tables:

*   `Genres`: Stores book genres (e.g., Fiction, Science).
*   `Publishers`: Stores information about book publishers.
*   `Authors`: Stores author details.
*   `Books`: Stores details about each book title, including ISBN, copies, and links to Genre and Publisher.
*   `BookAuthors`: A junction table to manage the Many-to-Many relationship between Books and Authors.
*   `Members`: Stores information about library members.
*   `Loans`: Tracks which member has borrowed which book, including loan dates, due dates, and return status.

Relationships implemented include:
*   One-to-Many (e.g., Publisher to Books, Genre to Books, Member to Loans)
*   Many-to-Many (Books to Authors, implemented via `BookAuthors`)

Constraints like `PRIMARY KEY`, `FOREIGN KEY` (with appropriate `ON DELETE`/`ON UPDATE` actions), `UNIQUE`, `NOT NULL`, and `CHECK` are used to ensure data integrity.

*(For a visual ERD, you could generate one using tools like MySQL Workbench or online services like dbdiagram.io based on the `library_db.sql` schema and link/embed the image here if desired).*

The complete and detailed schema definition, including all constraints and relationships, can be found in the `library_db.sql` file.

<a name="setup-and-usage-library"></a>
### Setup and Usage

To create and populate the Library Management database:

1.  **Ensure MySQL is Running:** Make sure you have a MySQL server instance installed and running.
2.  **Connect to MySQL:** Use a MySQL client (like the `mysql` command-line tool, MySQL Workbench, DBeaver, etc.) to connect to your server.
3.  **Create Database (Optional):** You can create a dedicated database for this system:
    ```sql
    CREATE DATABASE IF NOT EXISTS library_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    ```
4.  **Select the Database:** Switch to the created database:
    ```sql
    USE library_system;
    ```
5.  **Execute the SQL Script:** Run the contents of the `library_db.sql` file.
    *   **Using Command Line:**
        ```bash
        mysql -u your_username -p library_system < /path/to/library_db.sql
        ```
        (Replace `your_username` and `/path/to/library_db.sql` accordingly. You will be prompted for the password.)
    *   **Using a GUI Tool:** Open the `library_db.sql` file in your GUI tool, ensure the correct database (`library_system`) is selected, and execute the entire script.

This will create all the tables, define the relationships and constraints, and insert the sample data provided within the script. You can then query the tables to explore the schema and data.

---

## Part 2: Task Manager CRUD API (FastAPI + MySQL)

<a name="description-api"></a>
### Description

This component is a functional web API for managing a simple list of tasks. It allows users to create, retrieve, update, and delete tasks through standard HTTP methods (POST, GET, PUT, DELETE). The API is built using the FastAPI framework in Python and persists data in a MySQL database.

<a name="features-api"></a>
### Features

*   **FastAPI Framework:** Utilizes the high-performance FastAPI web framework.
*   **Asynchronous Operations:** Leverages Python's `asyncio` and `aiomysql` for non-blocking database interactions.
*   **MySQL Integration:** Connects to and interacts with a MySQL database.
*   **CRUD Functionality:** Implements all four core CRUD operations for tasks.
*   **Pydantic Validation:** Uses Pydantic models for robust request data validation and response serialization.
*   **Dependency Injection:** Employs FastAPI's dependency injection system for managing database connections.
*   **Environment Variable Configuration:** Securely handles database credentials via a `.env` file.
*   **Automatic API Docs:** Provides interactive Swagger UI (`/docs`) and ReDoc (`/redoc`) documentation.

<a name="technologies-used-api"></a>
### Technologies Used

*   **Programming Language:** Python 3.8+
*   **Web Framework:** FastAPI
*   **ASGI Server:** Uvicorn
*   **Database:** MySQL
*   **Database Driver (Async):** aiomysql
*   **Data Validation:** Pydantic
*   **Environment Variables:** python-dotenv

<a name="database-schema--erd-api"></a>
### Database Schema / ERD

This API uses a single table named `tasks` to store task information.

| Column       | Type                                                                 |
|--------------|----------------------------------------------------------------------|
| `task_id`    | INT AUTO_INCREMENT PRIMARY KEY                                      |
| `title`      | VARCHAR(255) NOT NULL                                               |
| `description`| TEXT NULL                                                           |
| `status`     | ENUM('pending', 'in_progress', 'completed') NOT NULL DEFAULT 'pending' |
| `due_date`   | DATE NULL                                                           |
| `created_at` | TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP                        |
| `updated_at` | TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP |

The SQL script to create this table (and optionally add sample data) is located in `task-manager-api/schema.sql`.

<a name="setup-instructions-api"></a>
### Setup Instructions

Follow these steps to set up and run the Task Manager API locally:

1.  **Prerequisites:**
    *   Python 3.8 or newer installed.
    *   MySQL server installed and running.
    *   Git installed (for cloning the repository).

2.  **Clone the Repository:**
    ```bash
    git clone <your-repository-url>
    cd <repository-name>
    ```

3.  **Navigate to API Directory:**
    ```bash
    cd task-manager-api
    ```
    *(Assuming the API code resides within a `task-manager-api` subfolder. Adjust if your structure differs).*

4.  **Create and Activate Virtual Environment:**
    *   **Linux/macOS:**
        ```bash
        python3 -m venv venv
        source venv/bin/activate
        ```
    *   **Windows:**
        ```bash
        python -m venv venv
        .\venv\Scripts\activate
        ```

5.  **Install Dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

6.  **Set Up MySQL Database:**
    *   Connect to your MySQL server.
    *   Create the database for the API (e.g., `task_manager_db`):
        ```sql
        CREATE DATABASE IF NOT EXISTS task_manager_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        ```
    *   **(Optional but Recommended)** Create a dedicated user and grant privileges:
        ```sql
        CREATE USER 'task_user'@'localhost' IDENTIFIED BY 'your_secure_password';
        GRANT ALL PRIVILEGES ON task_manager_db.* TO 'task_user'@'localhost';
        FLUSH PRIVILEGES;
        ```
        (Replace `'task_user'` and `'your_secure_password'`.)
    *   Run the `schema.sql` script to create the `tasks` table within the `task_manager_db` database (use the command line or a GUI tool, similar to the Library DB setup). Make sure to `USE task_manager_db;` first.
        ```bash
        # Example using command line:
        mysql -u your_db_user -p task_manager_db < schema.sql
        ```

7.  **Configure Environment Variables:**
    *   In the `task-manager-api` directory, create a file named `.env`.
    *   Add your MySQL database connection details to this file. **DO NOT commit this file to Git.**
    *   Use the following template:
        ```ini
        # .env file contents
        MYSQL_HOST=localhost
        MYSQL_USER=task_user          # Replace with your MySQL username (e.g., task_user or root)
        MYSQL_PASSWORD=your_secure_password # Replace with your MySQL password
        MYSQL_DB=task_manager_db      # Replace with your database name
        MYSQL_PORT=3306               # Default MySQL port (change if necessary)
        ```

<a name="running-the-api"></a>
### Running the API

1.  Make sure you are in the `task-manager-api` directory with your virtual environment activated.
2.  Run the application using Uvicorn:
    ```bash
    uvicorn app.main:app --reload
    ```
    *   `app.main:app` points Uvicorn to the `app` instance inside the `app/main.py` file.
    *   `--reload` enables auto-reloading during development, so the server restarts when you save code changes.

3.  The API should now be running, typically at `http://127.0.0.1:8000`.

<a name="api-endpoints--documentation"></a>
### API Endpoints & Documentation

Once the server is running, you can interact with the API:

*   **Interactive Docs (Swagger UI):** [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
*   **Alternative Docs (ReDoc):** [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)

The main endpoints available are:

*   `POST /tasks/`: Create a new task.
*   `GET /tasks/`: Retrieve a list of tasks (supports pagination via `skip` and `limit` query parameters).
*   `GET /tasks/{task_id}`: Retrieve a specific task by its ID.
*   `PUT /tasks/{task_id}`: Update an existing task by its ID.
*   `DELETE /tasks/{task_id}`: Delete a task by its ID.

You can use tools like `curl`, Postman, Insomnia, or the interactive documentation itself to send requests to these endpoints.

---

## Project Structure

```
.
├── .gitignore                # Specifies intentionally untracked files that Git should ignore
├── library_db.sql            # SQL script for the Library Management database (Part 1)
├── README.md                 # This README file
└── task-manager-api/         # Root directory for the Task Manager API (Part 2)
    ├── .env                  # Local environment variables (DB credentials - MUST BE CREATED, NOT COMMITTED)
    ├── requirements.txt      # Python dependencies for the API
    ├── schema.sql            # SQL script for the Task Manager database table
    └── app/                  # Source code directory for the FastAPI application
        ├── __init__.py       # Makes 'app' a Python package
        ├── crud.py           # Contains database interaction functions (CRUD logic)
        ├── database.py       # Handles database connection setup and pooling (aiomysql)
        ├── main.py           # Main FastAPI application file (defines routes, app instance)
        └── models.py         # Pydantic models for data validation and serialization
```

*(Adjust the structure if your layout is different, e.g., if `library_db.sql` is inside its own folder).*

---

## Contributing

This project is primarily for demonstration purposes. However, if you find issues or have suggestions for improvements, feel free to open an issue or submit a pull request.

---

## License

This project is open-source. You can specify a license if desired (e.g., MIT License).
