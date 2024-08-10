cd(@__DIR__)
using Relationals
using MySQL
using DBInterface

@source DBInterface.connect(
    MySQL.Connection,
    "127.0.0.1", 
    "root", 
    "password123";
    db="widgets",
    port=3306,
)

@source :sqlite SQLite.DB("orders.db")