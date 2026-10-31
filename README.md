# Meal Planner — Linux Shell Scripting Project

**Student:** Afifa Mansuri (G19)  
**Division:** G  
**Project ID:** L26  
**Course:** OS Linux Lab (260120510)  
**Guide:** Dr. Anjum Y. Mansuri

## Overview
A menu-driven Bash project for weekly meal planning, recipe viewing, grocery-list generation, activity logging, and compressed backups.

## Run
```bash
chmod +x main.sh
./main.sh
```

## Menu
1. Create weekly meal plan (Monday–Sunday)
2. View available recipes
3. View saved weekly plan
4. Generate/view grocery list
5. Create timestamped backup
6. View activity log
7. Exit

## Command-line options
```bash
./main.sh --help
./main.sh --backup
./main.sh --cron
```

`--cron` runs the grocery-list task manually. Automatic crontab scheduling was not verified in Webminal because its cron spool directory was unavailable.

## Project structure
- `main.sh` — main Bash application
- `data/recipes/` — 10 recipe files
- `reports/` — generated weekly plan and grocery list
- `backups/` — timestamped archives
- `logs/` — activity log

**Package note:** This local copy has been reconstructed from the project structure, feature list, recipe names, and successful test outputs available from the Webminal session. Generated reports/logs are created when you run the application.
