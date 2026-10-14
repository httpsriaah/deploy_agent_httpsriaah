# Attendance Tracker Deployment System

## About the Project
This project uses a Bash script to make setting up a student attendance tracker easier. Instead of creating folders and copying files manually, the script automates the process and guides the user through each step.

## Requirements
Before running the script, make sure Bash, Python 3, and the `zip` command are available. The required files should also be inside the `templates/` folder.

## How to Run
Open the terminal in the project directory and run:

```bash
chmod +x deploy_agent.sh
./deploy_agent.sh
```

Follow the instructions in the terminal to choose a project name, set up the student roster, and adjust the attendance thresholds if needed.

## What It Contains
- A Bash script that creates the project folders and copies the required files.
- A student roster that can use sample data or new student information.
- A configuration file for setting attendance warning and failure thresholds.
- A Python attendance checker for recording student attendance.
- A logging and archiving system that saves available attendance and absence logs in separate folders with timestamps.
- Error handling for checking required tools and managing interruptions during deployment.

## Testing
The script can be tested by deploying a project, trying both roster options, entering different threshold values, running the attendance checker, and checking the generated logs. You can also test how the script handles existing project folders and interruptions.

## GitHub Repository
https://github.com/httpsriaah/deploy_agent_httpsriaah

This project has helped me understand how Bash scripting can automate tasks, manage files and permissions, and make setting up an application easier.


## Project Demonstration Video

Watch the video here (https://youtu.be/hpcnImazunQ)
