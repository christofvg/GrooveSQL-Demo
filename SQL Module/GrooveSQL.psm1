function Invoke-StoredProcedure {
    <#
    .SYNOPSIS
        This function runs a Stored Procedure in SQL Server.
    .DESCRIPTION
        This function runs a Stored Procedure in SQL Server. It uses integrated security, so the user running the script should have access to the database.
    .PARAMETER Server
        Hostname or IP of the SQL server
    .PARAMETER Database
        Name of the database
    .PARAMETER StoredProcedure
        Name of the Stored Procedure
    .PARAMETER SQLParameters
        A Hash Table with the name and value of the parameters that need to be passed to the Stored Procedure
    .EXAMPLE
        Invoke-ETStoredProcedure -Server 'sql.groovesoundz.be' -Database 'AdventureWorks2017' -StoredProcedure 'GetUser' -SQLParameters @{Name="John"}
    .NOTES
        Author:  Christof Van Geendertaelen
        Website: http://www.groovesoundz.be
        Twitter: @cvangeendert
    #>
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]$Server,

        [Parameter(Mandatory)]
        [string]$Database,

        [Parameter(Mandatory)]
        [string]$StoredProcedure,

        [Parameter()]
        [hashtable]$SQLParameters
            
    )
        
    BEGIN {
    
    }
    
    PROCESS {

        try {
            
            # Connect to the SQL server

            $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
            $SqlConnection.ConnectionString = "Server=$Server;Database=$Database;Trusted_Connection=True"
            $SqlConnection.ConnectionString.ToString()
            $SqlConnection.Open()

            # Build the SQL command

            $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
            $SqlCmd.Connection = $SqlConnection
            $SqlCmd.CommandText = $StoredProcedure
            $SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure

            foreach ( $SQLParameter in $SQLParameters ) {
 
                # Convert the data type of the object to a SQL data type

                $DataType = Convert-SQLDataType -InputObject $SQLParameter["$($SQLParameter.Keys)"].GetType()

                # Add the parameter to the SQL command

                $SqlCmd.Parameters.Add("@$($SQLParameter.Keys)", $DataType) | Out-Null
                $SqlCmd.Parameters["@$($SQLParameter.Keys)"].Value = $SQLParameter["$($SQLParameter.Keys)"]

            }

            # Run the Stored Procedure

            $dataTable = New-Object System.Data.DataTable
            $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
            $sqlAdapter.SelectCommand = $sqlCmd
            [void]$sqlAdapter.Fill($dataTable)

            # Write the output to the pipeline

            Write-Output $dataTable

            # Close the SQL connection

            $sqlConnection.Close()

        }
        catch {

            Throw $_
            
        }
        



    }
    
    END {
    
    }
}

function Convert-SQLDataType {
    <#
    .SYNOPSIS
        This function converts the PowerShell data type to a SQL server data type.
    .DESCRIPTION
        This function converts the PowerShell data type to a SQL server data type. Following data types are supported:

        * Int32
        * String
        * Boolean
        * DateTime
        * Decimal
        * Double
    .PARAMETER InputObject
        Object to convert the object type to a SQL data type
    .EXAMPLE
        Convert-SQLDataType -InputObject "String"

        # [system.data.SqlDbType]::NVarChar
    .NOTES
        Author:  Christof Van Geendertaelen
        Website: http://www.groovesoundz.be
        Twitter: @cvangeendert
    #>
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [Object]$InputObject
            
    )
        
    BEGIN {
    
    }
    
    PROCESS {

        switch ($InputObject.GetType().Name) {
            "int32" {
                Write-Output "[system.data.SqlDbType]::Int"
            }
            "string" {
                Write-Output "[system.data.SqlDbType]::NVarChar"
            }
            "Boolean" {
                Write-Output "[system.data.SqlDbType]::Bit"
            }
            "DateTime" {
                Write-Output "[system.data.SqlDbType]::DateTime2"
            }
            "Decimal" {
                Write-Output "[system.data.SqlDbType]::Decimal"
            }
            "Double" {
                Write-Output "[system.data.SqlDbType]::Float"
            }
            Default {}
        }

    }
    
    END {
    
    }
}

