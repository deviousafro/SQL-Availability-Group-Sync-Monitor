# SQL-Availability-Group-Sync-Monitor
AG-Status – SQL Availability Group Synchronization Monitor
📌 Overview

The AG-Status PowerShell script is designed to monitor SQL Server databases that are part of Availability Groups (AGs). It verifies their synchronization state, provides clear console output, and sends email alerts for failures or successes.

This script is ideal for:

Daily health checks

Automated job/pipeline monitoring

Proactive alerting to reduce downtime

⚙️ Features

Checks all databases on configured SQL Server instances.

Evaluates whether databases are:

✅ Synchronized

⚠️ Not in an Availability Group

❌ Out of Sync

Sends email alerts for both success and failure states.

Exits with clear status codes (0 = success, 1 = failure) for easy integration with monitoring systems.

📂 Requirements

PowerShell 5.1+ or PowerShell 7+

FailoverClusters module (included with Windows Server features)

SMTP relay (for sending notifications)

Custom function or module to check database sync state

The example uses Get-SITAGDatabaseStatus

You can replace this with your own logic (e.g., dbatools
 Get-DbaAgDatabase)

🛠️ Setup

Clone this repository or download the script.

git clone https://github.com/<your-org>/AG-Status.git
cd AG-Status


Update script variables for your environment:

Import-Module path → point to your module or replace with your own logic.

$smtpServer → your SMTP relay.

$from → email sender address.

$to → recipient(s) for alerts.

Test the script manually:

.\AG-Status.ps1


Automate with Task Scheduler or DevOps pipeline:

Run on a schedule (e.g., every 15 minutes).

Use exit codes for CI/CD or monitoring pipelines.
