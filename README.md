# Exclusions Database

This project builds a structured database for healthcare provider exclusion records from multiple sources, including the HHS-OIG exclusion list and the Georgia DCH OIG exclusion list.

The goal of this project is to clean raw exclusion data, organize it into a relational database, and make the records easier to search, manage, and analyze.

## Project Overview

Healthcare exclusion lists contain individuals or businesses that are excluded from participating in certain healthcare programs. Different sources often provide different columns and formats, so this project creates a consistent database structure that can handle data from multiple sources.

This project includes:

- Data cleaning with Python and Pandas
- A relational database design for excluded parties
- PostgreSQL as the database system
- Prisma for schema definition and database migration
- pgAdmin for viewing and managing the database
- CSV files for cleaned/imported data

## Data Sources

The database is designed around exclusion data from:

- HHS-OIG exclusion list
- Georgia DCH OIG exclusion list

These sources do not always contain the same fields. For example, one source may include individual names, while another may mainly include business or organization names. Some fields such as NPI, UPIN, specialty, address, exclusion type, and reinstatement date may also be missing depending on the source.

## Database Structure

The main tables include:

### `sources`

Stores information about each data source, such as the source name, file name, and source type.

### `import_logs`

Tracks each import process, including when data was imported and how many records were added.

### `parties`

Stores the excluded party information. A party can be either an individual or a business.

Examples:

- Individual: first name, last name, middle name
- Business: business name

### `identifiers`

Stores identifiers connected to each party, such as NPI, UPIN, or other ID values when available.

### `exclusions`

Stores exclusion-related information, such as exclusion type, specialty, exclusion date, reinstatement date, waiver date, and status.

## Technologies Used

- Python
- Pandas
- PostgreSQL
- Prisma
- SQL
- pgAdmin

## Project Files

```text
clean.py              # Cleans and prepares raw data
seed.py               # Imports cleaned data into the database
schema.prisma         # Defines the database models and relationships
migration.sql         # SQL generated from Prisma migration
exclusions.csv        # Cleaned exclusion records
identifiers.csv       # Identifier records such as NPI or UPIN
parties.csv           # Excluded individual or business records
sources.csv           # Source metadata
import_logs.csv       # Import tracking information
```

## How to Set Up This Project

Follow these steps to run the exclusions database project on your own device.

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/exclusions-database.git
cd exclusions-database
```

### 2. Install Required Tools

Make sure you have these installed:

- Python
- PostgreSQL
- pgAdmin 4
- Prisma

### 3. Create a Virtual Environment

```bash
python -m venv venv
```

Activate the virtual environment:

```bash
# Mac/Linux
source venv/bin/activate

# Windows
venv\Scripts\activate
```

### 4. Install Python Packages

```bash
pip install pandas prisma python-dotenv
```

### 5. Create a PostgreSQL Database

Open pgAdmin 4 and create a new database.

Example database name:

```text
exclusions_database
```

### 6. Create a `.env` File

In the main project folder, create a file named `.env`.

Add your PostgreSQL connection URL:

```env
DATABASE_URL="postgresql://username:password@localhost:5432/exclusions_database"
```

Replace:

- `username` with your PostgreSQL username
- `password` with your PostgreSQL password
- `exclusions_database` with your database name

### 7. Apply the Database Schema

Run:

```bash
prisma generate
prisma migrate dev
```

This uses `schema.prisma` to create the database tables in PostgreSQL.

### 8. Clean the Raw Data

```bash
python clean.py
```

This creates the cleaned CSV files from the raw exclusion data.

### 9. Import the Cleaned Data

```bash
python seed.py
```

This imports the cleaned CSV files into PostgreSQL.

### 10. View the Database

Open pgAdmin 4 and check the tables in your database.

Main tables include:

- `sources`
- `import_logs`
- `parties`
- `identifiers`
- `exclusions`
