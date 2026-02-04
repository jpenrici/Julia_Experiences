# db_manager.jl

using SQLite
using DataFrames
using Dates


function init_database(db_path::String)
    db = SQLite.DB(db_path)

    # Create Table
    # Columns: id, timestamp, user_id, activity
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        user_id TEXT NOT NULL,
        activity TEXT NOT NULL
        );
    """
    SQLite.execute(db, create_table_sql)

    return db
end


function insert_activity(db::SQLite.DB, user::String, activity::String)
    insert_sql = "INSERT INTO activities (timestamp, user_id, activity) VALUES (?, ?, ?)"
    SQLite.execute(db, insert_sql, [Dates.format(now(), "yyyy-mm-dd HH:MM:SS"), user, activity])
    println("Activity registered successfully for user: $user")
end


function query_activities_by_date(db::SQLite.DB, start_date::String, end_date::String)
    query = "SELECT * FROM activities WHERE timestamp BETWEEN ? AND ?"
    result = SQLite.DBInterface.execute(db, query, [start_date, end_date])
    return DataFrame(result)
end
