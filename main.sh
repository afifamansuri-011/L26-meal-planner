#!/bin/bash
# G19 - L26 Meal Planner
DIR="$(cd "$(dirname "$0")" && pwd)"
RECIPES="$DIR/data/recipes"
REPORTS="$DIR/reports"
BACKUPS="$DIR/backups"
LOG="$DIR/logs/activity.log"
PLAN="$REPORTS/weekly_plan.txt"
GROCERY="$REPORTS/grocery_list.txt"
mkdir -p "$REPORTS" "$BACKUPS" "$DIR/logs"

log_action(){ echo "[$(date '+%F %T')] $1" >> "$LOG"; }
show_recipes(){
 echo "===== AVAILABLE RECIPES ====="
 for f in "$RECIPES"/*.txt; do
  [ -f "$f" ] || continue
  cat "$f"; echo
 done
 log_action "Viewed recipes"
}
create_plan(){
 local days=("Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday")
 local files=("$RECIPES"/*.txt)
 [ -f "${files[0]}" ] || { echo "No recipes found"; return; }
 : > "$PLAN"
 echo "===== WEEKLY MEAL PLAN =====" | tee -a "$PLAN"
 for day in "${days[@]}"; do
  echo "Choose recipe for $day:"
  local i=1
  for f in "${files[@]}"; do echo "$i. $(grep -m1 '^Recipe:' "$f" | cut -d: -f2-)"; ((i++)); done
  read -r -p "Choice (1-${#files[@]}): " n
  if [[ "$n" =~ ^[0-9]+$ ]] && ((n>=1 && n<=${#files[@]})); then
   name=$(grep -m1 '^Recipe:' "${files[$((n-1))]}" | cut -d: -f2- | xargs)
   echo "$day: $name" | tee -a "$PLAN"
  else echo "$day: No meal selected" | tee -a "$PLAN"; fi
 done
 log_action "Created weekly meal plan"
 view_grocery
}
view_plan(){ if [ -f "$PLAN" ]; then cat "$PLAN"; else echo "No weekly plan found"; fi; log_action "Viewed weekly plan"; }
view_grocery(){
 [ -f "$PLAN" ] || { echo "Create a weekly plan first"; return; }
 tmp=$(mktemp)
 while IFS= read -r line; do
  name="${line#*: }"
  [ "$name" = "$line" ] && continue
  for f in "$RECIPES"/*.txt; do
   r=$(grep -m1 '^Recipe:' "$f" | cut -d: -f2- | xargs)
   if [ "$r" = "$name" ]; then sed -n '/^Ingredients:/,$p' "$f" | tail -n +2 | sed 's/^- //'; break; fi
  done
 done < "$PLAN" > "$tmp"
 { echo "===== GROCERY LIST ====="; sort "$tmp" | uniq -c | sort -k2; } > "$GROCERY"
 rm -f "$tmp"; cat "$GROCERY"; log_action "Generated grocery list from weekly plan"
}
backup_project(){
 archive="$BACKUPS/mealplan_backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
 tar -czf "$archive" --exclude='./backups' -C "$DIR" .
 echo "Backup created: $archive"; log_action "Created project backup"
}
cron_task(){
 tmp=$(mktemp)
 for f in "$RECIPES"/*.txt; do [ -f "$f" ] && sed -n '/^Ingredients:/,$p' "$f" | tail -n +2 | sed 's/^- //' >> "$tmp"; done
 { echo "===== GROCERY LIST (ALL RECIPES) ====="; sort "$tmp" | uniq -c | sort -k2; } > "$GROCERY"
 rm -f "$tmp"; echo "Grocery list saved to reports/grocery_list.txt"; log_action "Ran grocery-list task"
}
show_help(){ echo "Options: ./main.sh --help | --backup | --cron"; echo "Menu: 1 Create plan, 2 Recipes, 3 View plan, 4 Grocery list, 5 Backup, 6 Activity log, 7 Exit"; }
case "$1" in --help) show_help; exit;; --backup) backup_project; exit;; --cron) cron_task; exit;; esac
while true; do
 echo; echo "===== MEAL PLANNER SYSTEM ====="
 echo "1. Create Weekly Meal Plan"; echo "2. View Available Recipes"; echo "3. View Weekly Plan"; echo "4. View Grocery List"; echo "5. Backup Project"; echo "6. View Activity Log"; echo "7. Exit"
 read -r -p "Enter choice: " c
 case "$c" in
  1) create_plan;; 2) show_recipes;; 3) view_plan;; 4) view_grocery;;
  5) backup_project;; 6) [ -f "$LOG" ] && cat "$LOG" || echo "No activity yet";;
  7) log_action "Exited application"; echo "Thank you!"; exit 0;;
  *) echo "Invalid choice";;
 esac
done
