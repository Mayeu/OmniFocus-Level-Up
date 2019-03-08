#!/usr/bin/env bash

set -xeuo pipefail
IFS=$'\n\t'
readonly DEBUG=false

#-- Dependencies -----------------------------------
#
# This script require:
#  * terminal-notifier(1)
#  * jq(1)
#  * my habitica(1) script
#
# You can install all that via brew:
#
#    brew install terminal-notifier jq mayeu/mayeu/habitica-cli
#

function info {
  terminal-notifier -title "OmniFocus to Habitica" -message "$1"
}

function debug {
  if ${DEBUG};
  then
    info "$1"
  fi
}

debug "Start processing the hooks"

readonly script_dir="${HOME}/Library/Application Support/omnifocus-level-up"
readonly last_run_file="${script_dir}/last_completed_task_processed"
readonly last_run_dir="${script_dir}/cache"
readonly omni_list_script="$(dirname $0)/../libexec/omni-list-done-todo-since.applescript"

# A slug function
to_slug() {
  # Forcing the POSIX local so alnum is only 0-9A-Za-z
  export LANG=POSIX
  export LC_ALL=POSIX
  # Keep only alphanumeric value
  sed -e 's/[^[:alnum:]]/-/g' |
  # Keep only one dash if there is multiple one consecutively
  tr -s '-'                   |
  # Lowercase everything
  tr A-Z a-z                  |
  # Remove last dash if there is nothing after
  sed -e 's/-$//'
}

# List the todo to process
todo_to_process() {
    # TODO: replace the time with something more logical
    osascript "$omni_list_script" "$last_processed_time" 2>&1 |
    sed -e 's/^date //'                                       |
    sed -e 's/,/|/'
}

# ensure we have our folder created
mkdir -p "$script_dir"
mkdir -p "$last_run_dir"
# ensure we have the last run file, or create a default one if not
if ! test -f "${last_run_file}";
then
  echo "Thursday 1 January 1970 at 00:00:00" > "$last_run_file" ;
fi

# Get the last time we ran which is also the last successfully processed tasks completion time
last_processed_time=`cat "$last_run_file"`

generate_timestamp() {
  while read -r line
  do
     IFS="|" read macdate title <<< ${line}
     timestamp=$(gdate -d"$(echo ${macdate} | sed -e 's/ at//')" +%s)
     echo "${timestamp}|${macdate}|${title}"
  done
}

todo_to_process |
generate_timestamp |
sort |
while read -r line;
do
  # Split the line in two on the '|'
  IFS="|" read timestamp macdate title <<< ${line}
  todo=$(echo "${timestamp}-${title}" | to_slug | md5)
  cache_file="${last_run_dir}/${todo}"

  if test ! -f "$cache_file"
  then
    # Escape the title, but habitica don't like '\ '
    debug "Process \"${title}\""
    # create the task on habitica
    json_data=$(habitica create "$todo")
    debug "Successfully created \"${todo}\""

    task_id=$(jq '.data.id' <<< ${json_data} | sed -e 's/"//g')
    # mark it as done
    habitica "done" "$task_id"
    debug "Successfully done \"${title}\""
    info "Sent to Habitica"

    # Cache the processed todo
    debug "Caching the todo"
    touch "$cache_file"

    # bump the last timestamp proccessed
    echo "$macdate" > "$last_run_file"
  fi
done

debug "Finished completed task processing"
