# Attendance Tracker Deployment Agent

## Overview
This project contains a Bash deployment script that sets up an attendance tracking project. It copies required files, configures permissions, supports student roster creation, allows threshold customization, runs the attendance checker, and archives attendance logs.

## Requirements
- Bash
- Python 3
- zip
- The template files in the templates/ directory

## How to Run
From the project directory, run:

    chmod +x deploy_agent.sh
    ./deploy_agent.sh

Follow the prompts to choose a project name, select or create a student roster, configure thresholds, run the attendance checker, and archive available logs.

## Features
- Checks for required dependencies and template files.
- Creates a project directory without overwriting an existing project.
- Supports an existing roster or a new roster.
- Sets executable permissions on the attendance checker.
- Restricts configuration file permissions.
- Allows customization of warning and failure thresholds.
- Runs the attendance checker on request.
- Archives available attendance and absence logs with timestamps.
- Handles deployment interruption using signal traps.

## Attendance Thresholds
The default warning threshold is 75%, and the default failure threshold is 50%. Users can customize these values during deployment. The failure threshold must be lower than the warning threshold.

## Log Archiving
Logs are stored in the project's reports/ directory. When available, attendance.log and absent.log are copied into timestamped files under archives/attendance/ and archives/absent/. Missing logs are reported without stopping the script.

## Signal Handling
The script traps SIGINT and SIGTSTP during deployment. If deployment is interrupted, it attempts to archive the incomplete project as a ZIP file.

## Project Structure

    Summative/
    ├── deploy_agent.sh
    ├── README.md
    ├── templates/
    │   ├── attendance_checker.py
    │   ├── assets.csv
    │   └── config.json
    └── attendance_tracker_<project_name>/
        ├── attendance_checker.py
        ├── Helpers/
        │   ├── assets.csv
        │   └── config.json
        ├── reports/
        └── archives/
            ├── attendance/
            └── absent/

## Testing
The deployment script was checked with bash -n deploy_agent.sh. The attendance checker was run on a test project, and the log archiving commands were tested with a generated attendance log.
