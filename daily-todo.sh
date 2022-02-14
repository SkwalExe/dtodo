#!/bin/bash

blue='\033[0;96m'
red='\033[0;91m'
green='\033[0;92m'
yellow='\033[0;93m'
purple='\033[0;95m'
white='\033[0;97m'

bg_blue='\033[0;44m'
bg_red='\033[0;41m'
bg_green='\033[0;42m'
bg_yellow='\033[0;43m'
bg_cyan='\033[0;46m'
bg_white='\033[0;47m'
bg_purple='\033[0;45m'

reset='\033[0m'


if [ ! -f ~/.dtodo ]; then
    printf "${red}[ x ] : ~/.dtodo not found."
    sleep 1
    printf "\r${blue}[ i ] : Creating ~/.dtodo... "
    sleep 0.5
    if touch ~/.dtodo; then
        printf "\r${green}[ v ] : .dtodo created successfully\n"
    else
        printf "\r${red}[ x ] : Failed to create ~/.dtodo\n"
        exit 1;
    fi
fi

command="print"

while [ $# -gt 0 ]; do 

    case "$1" in

        p|print)
            command="print"
            shift
        ;;
        a|add)
            if [ $# -gt 1 ]; then

                taskName="$2"

                command="add"
                shift 2
            else
                printf "${red}[ x ] : Missing argument for add\n"
                exit 1;
            fi
        ;;

        c|clear)
            command="clear"
            shift
        ;;

        d|done)
            if [ $# -gt 1 ]; then

                taskId="$2"

                command="done"
                shift 2
            else
                printf "${red}[ x ] : Missing argument for done\n"
                exit 1;
            fi
        ;;

        u|undone)
            if [ $# -gt 1 ]; then

                taskId="$2"

                command="undone"
                shift 2
            else
                printf "${red}[ x ] : Missing argument for undo\n"
                exit 1;
            fi
        ;;

        ua|undoall)
            command="undoall"
            shift
        ;;

        fd|firstdone)
            command="firstdone"
            shift
        ;;

        r|remove)
            if [ $# -gt 1 ]; then

                taskId="$2"

                command="remove"
                shift 2
            else
                printf "${red}[ x ] : Missing argument for delete\n"
                exit 1;
            fi
        ;;

        h|help)
            command="help"
            shift
        ;;

        *)
            printf "${red}[ x ] : Invalid argument : $1\n"
            exit 1;
        ;;

     
    esac

done

function printTodo() {
    content=$(cat -b ~/.dtodo)

    if [[ -z ${content// } ]]; then
        printf "\r${blue}[ i ] : The daily todo list is empty \n"
        exit 1;
    else
        printf "\r${blue}[ i ] : The daily todo list is:\n\n"
        printf "${blue}$content\n"

    fi

}



case $command in
    

        done)
            content=$(cat ~/.dtodo)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                printf "${blue}[ i ] : Marking task $taskId as done\n"
                sed -i "${taskId}s/\[ \]/\[x\] /" ~/.dtodo
                printTodo
            fi
       
            
        ;;

        undone)
            content=$(cat ~/.dtodo)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                printf "${blue}[ i ] : Marking task $taskId as undone\n"
                sed -i "${taskId}s/\[x\]/\[ \]/g" ~/.dtodo
                printTodo
            fi

        ;;

        undoall)
            content=$(cat ~/.dtodo)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                printf "${blue}[ i ] : Marking all tasks as undone\n"
                sed -i "s/\[x\]/\[ \]/g" ~/.dtodo
                printTodo
            fi

        ;;


        print)
            printTodo        
        ;;

        add)
            if [[ -z ${taskName// } ]]; then
                printf "${red}[ x ] : Missing argument for add\n"
                exit 1;
            else
                printf "\r${blue}[ i ] : Adding task: $taskName\n"
                printf "[ ] - $taskName\n" >> ~/.dtodo
                printTodo
            fi
        ;;
        clear)
            printf "\r${blue}[ i ] : Clearing the daily todo list\n"
            printf "" > ~/.dtodo
            printTodo 
        ;;

        firstdone)
            content=$(cat ~/.dtodo)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                printf "\r${blue}[ i ] : Marking first undone task as done\n"
                sed -i '0,/\[ \]/{s/\[ \]/\[x\]/}' ~/.dtodo
                printTodo
            fi

        ;;

        remove)
            content=$(cat ~/.dtodo)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                printf "\r${blue}[ i ] : Deleting task $taskId\n"
                sed -i "${taskId}d" ~/.dtodo
                printTodo
            fi
        ;;

        help)
            printf "${bg_blue} Daily Todo Help ${reset}\n"
            printf "${blue}━━━━━━━━━━━━━━━━━${reset}\n"
            printf "Author: ${green}@SkwalExe${reset}\n"
            printf "Github: ${green}https://github.com/SkwalExe/daily-todo${reset}\n"
            printf "${blue}━━━━━━━━━━━━━━━━━${reset}\n"
            printf "Manage your daily todo list\n"
            printf "${blue}━━━━━━━━━━━━━━━━━${reset}\n"
            printf "Options:\n"
            printf "  ${green}p, print${reset}    - Print the daily todo list\n"
            printf "  ${green}a, add${reset}      - Add a new task to the daily todo list\n"
            printf "  ${green}c, clear${reset}    - Clear the daily todo list\n"
            printf "  ${green}d, done${reset}     - Mark a task as done\n"
            printf "  ${green}u, undone${reset}   - Mark a task as undone\n"
            printf "  ${green}ua, undoall${reset} - Mark all tasks as undone\n"
            printf "  ${green}fd, firstdone${reset} - Mark the first undone task as done\n"
            printf "  ${green}h, help${reset}     - Print this help message\n"
            printf "${blue}━━━━━━━━━━━━━━━━━${reset}\n"


esac
