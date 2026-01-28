"""
Data ingestion script to load Kaggle CSV files into PostgreSQL.

This script reads all 8 CSV files from the Brazilian E-Commerce dataset
and loads them into PostgreSQL tables with appropriate data types.
"""

import logging
import os
from pathlib import Path
from typing import Dict, List, Optional

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()


def get_connection_string() -> str:
    """
    Build PostgreSQL connection string from environment variables.
    
    Returns:
        Connection string for SQLAlchemy
        
    Raises:
        ValueError: If required environment variables are missing
    """
    user = os.getenv('POSTGRES_USER')
    password = os.getenv('POSTGRES_PASSWORD')
    host = os.getenv('POSTGRES_HOST', 'localhost')
    port = os.getenv('POSTGRES_PORT', '5432')
    db = os.getenv('POSTGRES_DB')
    
    if not all([user, password, db]):
        raise ValueError(
            "Missing required environment variables. "
            "Please set POSTGRES_USER, POSTGRES_PASSWORD, and POSTGRES_DB in .env file"
        )
    
    return f"postgresql://{user}:{password}@{host}:{port}/{db}"


def get_csv_files(data_dir: Path) -> List[Path]:
    """
    Get list of CSV files from data directory.
    
    Args:
        data_dir: Path to directory containing CSV files
        
    Returns:
        List of CSV file paths
        
    Raises:
        FileNotFoundError: If data directory doesn't exist
    """
    if not data_dir.exists():
        raise FileNotFoundError(
            f"Data directory not found at {data_dir}. "
            "Did you download the Kaggle dataset to data/raw/?"
        )
    
    csv_files = list(data_dir.glob("*.csv"))
    
    if not csv_files:
        raise FileNotFoundError(
            f"No CSV files found in {data_dir}. "
            "Please download the Kaggle dataset and place CSV files in data/raw/"
        )
    
    logger.info(f"Found {len(csv_files)} CSV files")
    return csv_files


def infer_table_name(csv_path: Path) -> str:
    """
    Infer PostgreSQL table name from CSV filename.
    
    Args:
        csv_path: Path to CSV file
        
    Returns:
        Table name (lowercase, underscores)
    """
    # Remove .csv extension and convert to lowercase with underscores
    table_name = csv_path.stem.lower().replace('-', '_')
    return table_name


def read_csv_with_types(csv_path: Path) -> pd.DataFrame:
    """
    Read CSV file with appropriate data type handling.
    
    Args:
        csv_path: Path to CSV file
        
    Returns:
        DataFrame with optimized data types
        
    Raises:
        ValueError: If CSV is empty or cannot be read
    """
    try:
        # Read CSV with low_memory=False to avoid mixed type warnings
        df = pd.read_csv(csv_path, low_memory=False)
        
        if df.empty:
            raise ValueError(f"CSV file {csv_path} is empty")
        
        # Convert date columns (common patterns in this dataset)
        date_columns = [col for col in df.columns if 'date' in col.lower() or 'timestamp' in col.lower()]
        for col in date_columns:
            df[col] = pd.to_datetime(df[col], errors='coerce', infer_datetime_format=True)
        
        # Convert numeric columns to appropriate types
        numeric_columns = df.select_dtypes(include=['object']).columns
        for col in numeric_columns:
            # Try to convert to numeric if possible
            if df[col].dtype == 'object':
                try:
                    pd.to_numeric(df[col], errors='raise')
                    df[col] = pd.to_numeric(df[col], errors='coerce')
                except (ValueError, TypeError):
                    pass
        
        logger.info(f"Read {len(df)} rows from {csv_path.name}")
        return df
        
    except Exception as e:
        logger.error(f"Error reading {csv_path}: {str(e)}")
        raise


def table_exists(engine, table_name: str) -> bool:
    """
    Check if table already exists in database.
    
    Args:
        engine: SQLAlchemy engine
        table_name: Name of table to check
        
    Returns:
        True if table exists, False otherwise
    """
    try:
        with engine.connect() as conn:
            result = conn.execute(
                text(
                    "SELECT EXISTS ("
                    "SELECT FROM information_schema.tables "
                    "WHERE table_schema = 'public' AND table_name = :table_name"
                    ")"
                ),
                {"table_name": table_name}
            )
            return result.scalar()
    except SQLAlchemyError as e:
        logger.error(f"Error checking if table {table_name} exists: {str(e)}")
        return False


def load_csv_to_postgres(
    csv_path: Path,
    engine,
    table_name: str,
    if_exists: str = 'replace'
) -> None:
    """
    Load CSV data into PostgreSQL table.
    
    Args:
        csv_path: Path to CSV file
        engine: SQLAlchemy engine
        table_name: Target table name
        if_exists: What to do if table exists ('replace', 'append', 'fail')
        
    Raises:
        SQLAlchemyError: If database operation fails
    """
    try:
        df = read_csv_with_types(csv_path)
        
        # Using bulk insert with method='multi' for better performance
        # This is 10x faster than row-by-row insertion
        df.to_sql(
            table_name,
            engine,
            if_exists=if_exists,
            index=False,
            method='multi',
            chunksize=1000
        )
        
        logger.info(f"Successfully loaded {len(df)} rows into {table_name}")
        
    except Exception as e:
        logger.error(f"Error loading {csv_path} to {table_name}: {str(e)}")
        raise


def main() -> None:
    """
    Main function to orchestrate data ingestion.
    
    Reads all CSV files from data/raw/ and loads them into PostgreSQL.
    """
    try:
        # Get connection
        connection_string = get_connection_string()
        engine = create_engine(connection_string)
        
        # Test connection
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        logger.info("Successfully connected to PostgreSQL")
        
        # Get CSV files
        data_dir = Path(__file__).parent.parent / "data" / "raw"
        csv_files = get_csv_files(data_dir)
        
        # Load each CSV file
        for csv_path in csv_files:
            table_name = infer_table_name(csv_path)
            
            # Check if table exists
            exists = table_exists(engine, table_name)
            if exists:
                logger.info(f"Table {table_name} already exists. Replacing with new data.")
            
            load_csv_to_postgres(csv_path, engine, table_name, if_exists='replace')
        
        logger.info("Data ingestion completed successfully!")
        
    except Exception as e:
        logger.error(f"Data ingestion failed: {str(e)}")
        raise


if __name__ == "__main__":
    main()
