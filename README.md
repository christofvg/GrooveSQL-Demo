# GrooveSQL-Demo
Demo repository to demonstrate the ease of using SQL Server to support PowerShell in processing data

The repository contains a module and a test script

## Prerequisites

This demo is created on the AdventureWorks2017 database, created by Microsoft.

All requirements:

* SQL Server (e.g. SQL Express 2017 - [Download](https://www.microsoft.com/en-us/download/details.aspx?id=55994))
* SQL Server Management Studio (e.g. SQL Server Management Studio 17.9 - [Download](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017))
* AdventureWorks2017 database - [Installation](https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-2017)

## Connection String

The connection string, used in the module, uses a TCP connection. The server needs to be passed in the format \<server\>\\\<instance\>. Integrated security is used.

Of course, other ways of connecting to SQL server can be used. You can change the function to have a parameter to pass the connection string, use a PowerShell Data file, or change the function itself.

More information about the connection string: [https://www.connectionstrings.com/sql-server/](https://www.connectionstrings.com/sql-server/)

## TimeComparison.ps1

This script compares the time to perform a task (combine employee data with persons data).

The first measurement of time is the execution of the Stored Procedure. It only takes one line of code to invoke the Stored Procedure.

The second measurement of time is the execution of the combination with PowerShell. The script iterates over all employees and uses Where-Object to combine the Employee and Persons ID's. An object with all properties is made and added to an initialized array.

After these tasks, a report is written to the output.

## GrooveSQL.psm1

### Invoke-StoredProcedure

This function runs a Stored Procedure in SQL Server. Each parameter that is passed with the SQLParameters parameter

Parameters:

* [string]Server
* [String]Database
* [String]StoredProcedure
* [HashTable]SQLParameters

The function iterates over all parameters and converts the data type names automatically to SQL data type names using the internal function Convert-SQLDataType.

### Convert-SQLDataType

This function converts the PowerShell data type to a SQL server data type. Following data types are supported:

    * Int32
    * String
    * Boolean
    * DateTime
    * Decimal
    * Double

Following conversions are made:

* int32    -> [system.data.SqlDbType]::Int
* string   -> [system.data.SqlDbType]::NVarChar
* Boolean  -> [system.data.SqlDbType]::Bit
* DateTime -> [system.data.SqlDbType]::DateTime2
* Decimal  -> [system.data.SqlDbType]::Decimal
* Double   -> [system.data.SqlDbType]::Float