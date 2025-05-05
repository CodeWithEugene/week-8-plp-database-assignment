import aiomysql
import os
from dotenv import load_dotenv
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables from .env file
load_dotenv()

# Database configuration
DB_CONFIG = {
    'host': os.getenv('MYSQL_HOST', 'localhost'),
    'port': int(os.getenv('MYSQL_PORT', 3306)),
    'user': os.getenv('MYSQL_USER'),
    'password': os.getenv('MYSQL_PASSWORD'),
    'db': os.getenv('MYSQL_DB'),
    'autocommit': True, # Important for CRUD operations without explicit commit
    'cursorclass': aiomysql.DictCursor # Return rows as dictionaries
}

pool = None

async def get_db_pool():
    """Creates and returns an aiomysql connection pool."""
    global pool
    if pool is None:
        logger.info(f"Creating database connection pool for {DB_CONFIG['db']} on {DB_CONFIG['host']}")
        try:
            pool = await aiomysql.create_pool(**DB_CONFIG, minsize=1, maxsize=10)
            logger.info("Database connection pool created successfully.")
        except Exception as e:
            logger.error(f"Failed to create database connection pool: {e}")
            raise # Re-raise the exception to halt startup if connection fails
    return pool

async def close_db_pool():
    """Closes the database connection pool."""
    global pool
    if pool:
        pool.close()
        await pool.wait_closed()
        logger.info("Database connection pool closed.")
        pool = None

async def get_db_connection():
    """ Dependency to get a database connection from the pool """
    db_pool = await get_db_pool()
    async with db_pool.acquire() as conn:
        yield conn # Provide the connection to the route

async def get_db_cursor(conn: aiomysql.Connection):
     """ Utility to get a cursor from a connection """
     async with conn.cursor() as cursor:
         yield cursor
