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

command=${1:-default}

case "$command" in

    default|p|print)
        [ $# -gt 1 ] && printf "${yellow}[ /i\\ ] : print doesn't require any arguments \n"
        printTodo
    ;;

    a|add)
        if [ $# -gt 1 ]; then
            shift
            taskName="$@"
        
            if [[ -z ${taskName// } ]]; then
                printf "${red}[ x ] : Missing argument for add\n"
                exit 1;
            else
                printf "\r${blue}[ i ] : Adding task: $taskName\n"
                printf "[ ] - $taskName\n" >> ~/.dtodo
                printTodo
            fi
        
        else
            printf "${red}[ x ] : Missing argument for add\n"
            exit 1;
        fi
    ;;

    c|clear)
        [ $# -gt 1 ] && printf "${yellow}[ /i\\ ] : clear doesn't require any arguments \n"
        printf "\r${blue}[ i ] : Clearing the daily todo list\n"
        printf "" > ~/.dtodo
        printTodo 
    ;;

    d|done)
        shift
        taskId="${1:-first}"    

        content=$(cat ~/.dtodo)
        if [[ -z ${content// } ]]; then
            printf "\r${blue}[ i ] : The daily todo list is empty \n"
            exit 1;
        else
            if [[ $taskId == 'first' ]]; then
                printf "\r${blue}[ i ] : Marking first undone task as done\n"
                sed -i '0,/\[ \]/{s/\[ \]/\[x\]/}' ~/.dtodo
            else
                re='^[0-9]+$'

                while [ $# -gt 0 ]; do
                    taskId="$1"

                    [[ ! $taskId =~ $re ]] && printf "${red}[ x ] : Invalid task id\n" && exit 1;
                    
                    printf "${blue}[ i ] : Marking task $taskId as done\n"
                    sed -i "${taskId}s/\[ \]/\[x\]/" ~/.dtodo
                    shift
                done
            fi
            printTodo
        fi
       
    ;;

    u|undo)
        shift  
        taskId="${1:-first}"    


        content=$(cat ~/.dtodo)
        if [[ -z ${content// } ]]; then
            printf "\r${blue}[ i ] : The daily todo list is empty \n"
            exit 1;
        else
            if [[ $taskId == 'first' ]]; then
                printf "\r${blue}[ i ] : Marking first done task as undone\n"
                sed -i '0,/\[x\]/{s/\[x\]/\[ \]/}' ~/.dtodo
            else
                re='^[0-9]+$'

                while [ $# -gt 0 ]; do
                    taskId="$1"

                    [[ ! $taskId =~ $re ]] && printf "${red}[ x ] : Invalid task id\n" && exit 1;
                    
                    printf "${blue}[ i ] : Marking task $taskId as undone\n"
                    sed -i "${taskId}s/\[x\]/\[ \]/g" ~/.dtodo
                    shift
                done
            fi  
            printTodo
        fi
    ;;

    ua|undoall)
        [ $# -gt 1 ] && printf "${yellow}[ /i\\ ] : undoall doesn't require any arguments \n"


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

    r|remove)

        shift  
        taskId="${1:-last}"    

        content=$(cat ~/.dtodo)
        if [[ -z ${content// } ]]; then
            printf "\r${blue}[ i ] : The daily todo list is empty \n"
            exit 1;
        else

            if [[ $taskId == 'last' ]]; then
                printf "\r${blue}[ i ] : Removing the last task\n"
                sed -i "`cat ~/.dtodo|wc -l`d" ~/.dtodo
            else
                re='^[0-9]+$'

                while [ $# -gt 0 ]; do
                    taskId="$1"

                    [[ ! $taskId =~ $re ]] && printf "${red}[ x ] : Invalid task id\n" && exit 1;
                    
                    printf "${blue}[ i ] : Removing task $taskId\n"
                    sed -i "${taskId}d" ~/.dtodo
                    shift
                done
            fi  
            printTodo

        fi

    ;;


    e|edit)
        editor=${1:-vi}
        $editor ~/.dtodo
        printTodo
    ;;

    h|help)
        printf "${bg_blue} Daily Todo Help ${reset}\n"
        printf "${blue}━━━━━━━━━━━━━━━━━${reset}\n"
        printf "Author: ${green}@SkwalExe${reset}\n"
        printf "Github: ${green}https://github.com/SkwalExe/daily-todo${reset}\n"
        printf "${blue}━━━━━━━━━━━━━━━━━${reset}\n"
        printf "Manage your daily todo list\n"
        printf "${blue}━━━━━━━━━━━━━━━━━${reset}\n"
        printf "Options:\n"
        printf "  ${green}p, print${reset}       - Print the daily todo list\n"
        printf "  ${green}a, add ${blue}my task${reset} - Add a new task to the daily todo list\n"
        printf "  ${green}c, clear${reset}       - Clear the daily todo list\n"
        printf "  ${green}d, done ${blue}1 5${reset}    - Mark a task as done ${yellow}[D: the first undone task]\n"
        printf "  ${green}u, undo ${blue}7 9${reset}    - Mark a task as undone ${yellow}[D: the first done task]\n"
        printf "  ${green}ua, undoall${reset}    - Mark all tasks as undone\n"
        printf "  ${green}r, remove ${blue}17 4${reset} - Remove a task from the daily todo list ${yellow}[D: the last task]\n"
        printf "  ${green}e, edit ${blue}nano${reset}   - Manually edit the todo list ${yellow}[Editor: vi]\n"
        printf "  ${green}h, help${reset}        - Print this help message\n"
        printf "${blue}━━━━━━━━━━━━━━━━━${reset}\n"
    ;;

    *)
        printf "${red}[ x ] : Invalid argument : $1\n"
        exit 1;
    ;;


esac

