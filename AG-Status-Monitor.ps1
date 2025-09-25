<#
    Program:  AG-Status
    Desc:     This script checks the synchronization state of SQL Server
              databases that are part of Availability Groups (AGs).

              It performs the following steps:
              - Collects AG database sync status
              - Evaluates whether each database is synchronized, out of sync,
                or not in an AG
              - Sends email alerts on failure or success
              - Exits with a status code (0 for success, 1 for failure)

              Useful for: 
              - Daily health checks
              - Automated pipeline monitoring
              - Proactive alerting for database availability issues

    Requirements:
              - Custom module containing `Get-SITAGDatabaseStatus`
                (replace or rewrite with your own logic if unavailable)
              - FailoverClusters PowerShell module
              - Valid SMTP relay for sending notifications

    Last Update: 06/06/2025
    Version: 2.0
    Author: deviousafro
#>

# =======================
# Import required modules
# =======================

# Custom module that retrieves AG database status.
# Replace this path with your own function/module if needed.
Import-Module "C:\Scripts\YourModule\YourModule.psm1"

# Standard Windows module for cluster interactions.
Import-Module FailoverClusters

# ======================
# Email configuration
# ======================

# SMTP relay used to send notification emails.
# Replace with your environment’s relay server.
$smtpServer = "<YourSMTPRelay>"

# Replace with a sender email address that makes sense for your site.
$from = "monitor@yourdomain.com"

# Replace with one or more recipients who should get alerts.
$to = "dba-team@yourdomain.com"

# ==================================
# Collect database synchronization info
# ==================================

# Get database sync status via your custom function.
# Replace `Get-SITAGDatabaseStatus` with your own logic if necessary.
$databaseStatus = Get-SITAGDatabaseStatus 

# Extract fields for clarity.
$lines = $databaseStatus | Select SqlInstance, Name, AGSyncState

# Initialize tracking variables
$allSynced       = $true
$notAllSynced    = $false
$notSyncedDetails = @()  # Stores details of unsynchronized databases

# ======================
# Evaluation loop
# ======================
foreach ($line in $lines) {
    # Case: Database is not in an AG
    if ($line.AGSyncState -like "*Not in AG Group*") {
        $notAllSynced = $true
        $notSyncedDetails += $line
        $allSynced = $false
    }
    # Case: Database is in AG but not synchronized
    elseif ($line.AGSyncState -notlike "*Synchronized*") {
        $allSynced = $false
    }
}

# ======================
# Reporting & Notifications
# ======================

# Case A: Critical issue detected
if ($notAllSynced) {
    Write-Host "Critical: Found database(s) not synchronizing."

    $errormessage = $notSyncedDetails | ForEach-Object {
        Write-Host $_.SqlInstance, $_.Name, $_.AGSyncState
        "$($_.SqlInstance) - $($_.Name): $($_.AGSyncState)"
    }

    $stringerrormessage = $errormessage -join "`n"
    Write-Error $stringerrormessage

    # Send email alert for failure
    $subject = "CRITICAL: SQL AG Databases Not Synchronized"
    $body    = "The following databases are not synchronized:`n`n$stringerrormessage"

    Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $subject -Body $body

    Exit 1
}

# Case B: All databases synchronized
if ($allSynced -and -not $notAllSynced) {
    $successMessage = "All databases in Availability Groups are synchronized successfully as of $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')."
    Write-Host "Success: $successMessage"

    # Send email notification for success
    $subject = "SUCCESS: All SQL AG Databases Are Synchronized"
    $body    = $successMessage

    Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $subject -Body $body

    Exit 0
}
