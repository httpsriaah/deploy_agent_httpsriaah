#!/bin/bash

handle_interruption() {
    echo ""
    echo "Deployment interrupted!"

    if [ "$deployment_in_progress" = true ] && [ -d "$project_dir" ]; then
        zip -r "${project_dir}_archive.zip" "$project_dir"
        echo "Incomplete project archived as ${project_dir}_archive.zip"
    fi

    exit 130
}

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required."
    exit 1
fi
if ! command -v zip >/dev/null 2>&1; then
    echo "Error: zip is required."
    exit 1
fi
for file in attendance_checker.py assets.csv config.json; do
    if [ ! -f "templates/$file" ]; then
        echo "Error: templates/$file is missing."
        exit 1
    fi
done

read -p "Enter project name: " project_name
echo "You entered: $project_name"
project_dir="attendance_tracker_$project_name"

if [ -d "$project_dir" ]; then
    echo "Error: $project_dir already exists. Choose another name."
    exit 1
fi
trap 'handle_interruption' INT
trap 'handle_interruption' TSTP

deployment_in_progress=true
mkdir -p "$project_dir"
echo "Project folder created: $project_dir"
mkdir -p "$project_dir/Helpers" "$project_dir/reports"
echo "Project subfolders created."
cp templates/attendance_checker.py "$project_dir/attendance_checker.py"
echo "Attendance checker copied."
cp templates/assets.csv "$project_dir/Helpers/assets.csv"
cp templates/config.json "$project_dir/Helpers/config.json"
echo "Attendance data and configuration copied."
chmod +x "$project_dir/attendance_checker.py"
chmod 600 "$project_dir/Helpers/config.json"
echo "File permissions configured."

echo ""
echo "Choose a roster option:"
echo "1. Use the existing student roster"
echo "2. Create a new student roster"
read -p "Enter your choice (1 or 2): " roster_choice

if [ "$roster_choice" = "1" ]; then
    read -p "How many students do you want to include (1-10)? " student_count

    if [[ ! "$student_count" =~ ^[0-9]+$ ]] || [ "$student_count" -lt 1 ] || [ "$student_count" -gt 10 ]; then
        echo "Error: Enter a number between 1 and 10."
        exit 1
    fi

    head -n "$((student_count + 1))" templates/assets.csv > "$project_dir/Helpers/assets.csv"
    echo "$student_count students added to the project roster."

elif [ "$roster_choice" = "2" ]; then
    read -p "How many students will be in the new roster? " student_count

    if [[ ! "$student_count" =~ ^[0-9]+$ ]] || [ "$student_count" -lt 1 ]; then
        echo "Error: Enter a positive whole number."
        exit 1
    fi

    roster_file="$project_dir/Helpers/assets.csv"
    echo "Email,Names,Attendance Count,Absence Count" > "$roster_file"

    for ((i=1; i<=student_count; i++)); do
        read -p "Enter student $i name: " student_name
        read -p "Enter student $i email: " student_email

        if [ -z "$student_name" ] || [ -z "$student_email" ]; then
            echo "Error: Name and email cannot be empty."
            exit 1
        fi

        echo "$student_email,$student_name,0,0" >> "$roster_file"
    done

    echo "New roster created with $student_count students."
    sed -i -E 's/"total_sessions"[[:space:]]*:[[:space:]]*[0-9]+/"total_sessions": 1/' "$project_dir/Helpers/config.json"

else
    echo "Error: Invalid roster choice."
    exit 1
fi


echo ""
read -p "Do you want to change the attendance thresholds? (y/n): " change_thresholds

if [[ "$change_thresholds" == "y" || "$change_thresholds" == "Y" ]]; then
    read -p "Enter warning threshold (0-100): " warning_threshold
    read -p "Enter failure threshold (0-100): " failure_threshold

    if [[ ! "$warning_threshold" =~ ^[0-9]+$ ]] || [[ ! "$failure_threshold" =~ ^[0-9]+$ ]] || [ "$warning_threshold" -gt 100 ] || [ "$failure_threshold" -gt 100 ]; then
        echo "Error: Thresholds must be whole numbers between 0 and 100."
        exit 1
    fi

    if [ "$failure_threshold" -ge "$warning_threshold" ]; then
        echo "Error: Failure threshold must be lower than warning threshold."
        exit 1
    fi

    sed -i "s/\"warning\": [0-9]*/\"warning\": $warning_threshold/" "$project_dir/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $failure_threshold/" "$project_dir/Helpers/config.json"

    echo "Thresholds updated successfully."
else
    echo "Keeping the default thresholds."
fi

deployment_in_progress=false
trap - INT TSTP

echo ""
read -p "Do you want to run the attendance checker now? (y/n): " run_checker

if [[ "$run_checker" == "y" || "$run_checker" == "Y" ]]; then
    (
        cd "$project_dir" || exit 1
        python3 attendance_checker.py
    )
    echo "Attendance checker finished."
else
    echo "You can run the attendance checker later from $project_dir."
fi

echo ""
read -p "Do you want to archive attendance logs? (y/n): " archive_choice

if [[ "$archive_choice" == "y" || "$archive_choice" == "Y" ]]; then
    timestamp=$(date +"%Y%m%d_%H%M%S")
    mkdir -p "$project_dir/archives/attendance" "$project_dir/archives/absent"

    if [ -f "$project_dir/reports/attendance.log" ]; then
        cp "$project_dir/reports/attendance.log" "$project_dir/archives/attendance/attendance_${timestamp}.log"
        echo "Attendance log archived."
    else
        echo "No attendance log found to archive."
    fi

    if [ -f "$project_dir/reports/absent.log" ]; then
        cp "$project_dir/reports/absent.log" "$project_dir/archives/absent/absent_${timestamp}.log"
        echo "Absence log archived."
    else
        echo "No absence log found to archive."
    fi
else
    echo "Log archiving skipped."
fi



