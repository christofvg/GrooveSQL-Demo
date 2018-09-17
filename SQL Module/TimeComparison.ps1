Import-Module .\GrooveSQL.psm1

# Initialize variables

$SQLServer   = "localhost"
$SQLInstance = "SQLExpress"
$Database    = "AdventureWorks2017"

# Load data in variables to compare PowerShell times with SQL times

$Persons   = Invoke-StoredProcedure -Server "$SQLServer\$SQLInstance" -Database "$Database" -StoredProcedure uspGetPersons
$Employees = Invoke-StoredProcedure -Server "$SQLServer\$SQLInstance" -Database "$Database" -StoredProcedure uspGetEmployees

Write-Output "The number of persons is $($Persons.Count) and the number of employees is $($Employees.Count)"

# Run a stored procedure that matches the employees with the persons to find personal data using a Stored Procedure

$SQLTime = Measure-Command -Expression {
    $EmployeePersons = Invoke-StoredProcedure -Server "$SQLServer\$SQLInstance" -Database "$Database" -StoredProcedure uspGetEmployeePersons
}

# Do the same, but use PowerShell to do the job

$PSTime = Measure-Command -Expression {

    $PSEmployeePersons = @()

    ForEach ($Employee in $Employees) {

        # Match the person with the employee

        $PSPerson = $Persons | Where-Object {$_.BusinessEntityID -eq $Employee.BusinessEntityID}

        $Properties = @{
            BirthDate        = $Employee.BirthDate
            FirstName        = $PSPerson.FirstName
            Gender           = $Employee.Gender
            HireDate         = $Employee.HireDate
            JobTitle         = $Employee.JobTitle
            LastName         = $PSPerson.LastName
            LoginID          = $Employee.LoginID
            MaritalStatus    = $Employee.MaritalStatus
            MiddleName       = $PSPerson.MiddleName
            NationalIDNumber = $Employee.NationalIDNumber
            SalariedFlag     = $Employee.SalariedFlag
            SickLeaveHours   = $Employee.SickLeaveHours
            Suffix           = $PSPerson.Suffix
            Title            = $PSPerson.Title
            VacationHours    = $Employee.VacationHours
        }

        $objPerson = New-Object -TypeName psobject -Property $Properties

        $PSEmployeePersons += $objPerson

    }

}

# Report

$ReportText = @"
The data, used for this demo, comes from the Adventure Works 2017 database from Microsoft.

Both operations have the same output.

Some numbers:
-------------

The SQL Stored Procedure took $($SQLTime.Minutes) minutes and $($SQLTime.Seconds) seconds to execute.
The PowerShell ForEach loop too $($PSTime.Minutes) minutes and $($PSTime.Seconds) seconds to execute.

The number of combined users with the SQL query is: $($EmployeePersons.Count)
The number of combined users with the PowerShell ForEach loop is: $($PSEmployeePersons.Count)
"@

# Write report to the screen

Write-Output $ReportText