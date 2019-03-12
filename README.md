# Omnifocus Level Up

A set of scripts to create tasks and mark them as done immediatly in Habitica
as soon as you mark a task as done in OmniFocus.

## How does this script works

* You check something as done in OmniFocus
* Magic make the script run
* The script create a tasks in Habitica and mark it done immediatly

## This script will not

* Sync habitica to OmniFocus
* Sync undone task to Habitica
* Sync or track habits and dailies

## Why?

I don't use Habitica for my daylies or todo anymore, but I don't wanted to pass
on the sweet sweet XP of done tasks.

Thus, this script.

## :warning: WARNING :warning:

This may break your Habitica. It should not break your OmniFocus (it only read
stuff), but remember that:

![I have idea what I'm doing.](img/i-have-no-idea-what-im-doing-doing.jpg)

## How to use

To make this work you will need:
* my `habitica(1)` script: `brew install mayeu/mayeu/habitica-cli`
* the `pass(1)` [password manager](https://www.passwordstore.org/) (for the
  habitica script): `brew install pass`
* the `run-one(1)` script: `brew install mayeu/mayeu/flock`
* the `jq(1)` tool: `brew install jq`
* the `terminal-notifier(1)` tool: `brew install terminal-notifier`
* the `gdate(1)` utility: `brew install coreutils`

Steps to do:
- udpate all the paths in `LaunchAgents/me.mayeu.script.OmniHabitica.plist` to
  match where you cloned the repo, and the OmniFocus database
- Copy `me.mayeu.script.OmniHabitica.plist` in `~/Library/LaunchAgents/`
- Load the script with
  `$ launchctl load ~/Library/LaunchAgents/me.mayeu.script.OmniHabitica.plist`
- Put the current day date as in this example:
  `$ echo 'Tuesday 12 March 2019 at 18:57:00' > ~/Library/Application Support/omnifocus-level-up/last_completed_task_processed` 

And voilà! From now on it should trigger a notification every time you mark a
task as done (or almost everytimes which is OK since it will process missed done
during the next run).
