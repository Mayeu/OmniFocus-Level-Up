
on run argv
	(* This get the first argument passed via the CLI.
       For an unknow reason I can do the date conversion immediatly *)
	set last_date_processed to item 1 of argv
	set last_date_processed to date last_date_processed
	
	tell application "OmniFocus"
		tell default document
			(* Get all the task completed the last two day in a flat structure *)
			set done_tasks to every flattened task whose completed is true and modification date is greater than or equal to (last_date_processed - 0 * days)
			
			(* We loop on them and log the modification date and name as output *)
			repeat with current_task in done_tasks
				set task_name to name of current_task
				set modification_date to modification date of current_task
				log modification_date & task_name
			end repeat
		end tell
	end tell
end run