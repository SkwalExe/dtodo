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




function printTodo() {
    content=$(cat -b $1)

    if [[ -z ${content// } ]]; then
        printf "${blue}[ i ] : The daily todo list is empty \n"
        exit 1;
    else
        printf "\n${blue}$content\n"

    fi

}

function checkExist() {
    if [ ! -f ~/.$tdfile ]; then
        printf "${red}[ x ] : ~/.$tdfile not found.\n"
        printf "${blue}[ i ] : Creating ~/.${tdfile}...\n"
        if touch ~/.$tdfile; then
            printf "${green}[ v ] : .$tdfile created successfully\n"
        else
            printf "${red}[ x ] : Failed to create ~/.$tdfile\n"
            exit 1;
        fi
    fi
}
tdfile="dtodo"

function parseArgs() {


    command=${1:-default}
    case "$command" in

        l|list)
            if [ $# -gt 1 ]; then
                    shift
                    _tdfile="$1"
                
                    if [[ -z ${_tdfile// } ]]; then
                        printf "${red}[ x ] : Missing argument for list\n"
                        exit 1;
                    else
                        tdfile="dtodo-$_tdfile"
                        shift
                        parseArgs $@
                    fi
                
                else
                    printf "${red}[ x ] : Missing argument for list\n"
                    exit 1;
                fi

        ;;

        rl|removelist)
            if [ $# -gt 1 ]; then
                    shift
                    toremove="$1"
                
                    if [[ -z ${toremove// } ]]; then
                        printf "${red}[ x ] : Missing argument for removelist\n"
                        exit 1;
                    else
                        rm -f ~/.dtodo-$toremove
                        printf "${green}[ v ] : Removed list ${toremove}\n"
                    fi
                
                else
                    printf "${red}[ x ] : Missing argument for removelist\n"
                    exit 1;
            fi
        ;;


        p|print)
            checkExist
            [ $# -gt 1 ] && printf "${yellow}[ /i\\ ] : print doesn't require any arguments \n"
            printTodo ~/.$tdfile
        ;;

        a|add)
            checkExist
            if [ $# -gt 1 ]; then
                shift
                taskName="$*"
            
                if [[ -z ${taskName// } ]]; then
                    printf "${red}[ x ] : Missing argument for add\n"
                    exit 1;
                else
                    printf "\r${blue}[ i ] : Adding task: $taskName\n"
                    printf "[ ] - $taskName\n" >> ~/.$tdfile
                    printTodo ~/.$tdfile
                fi
            
            else
                printf "${red}[ x ] : Missing argument for add\n"
                exit 1;
            fi
        ;;

        c|clear)
            checkExist
            [ $# -gt 1 ] && printf "${yellow}[ /i\\ ] : clear doesn't require any arguments \n"
            printf "\r${blue}[ i ] : Clearing the daily todo list\n"
            printf "" > ~/.$tdfile
            printTodo  ~/.$tdfile
        ;;

        d|done)
            checkExist
            shift
            taskId="${1:-first}"    

            content=$(cat ~/.$tdfile)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                if [[ $taskId == 'first' ]]; then
                    printf "\r${blue}[ i ] : Marking first undone task as done\n"
                    sed -i '0,/\[ \]/{s/\[ \]/\[x\]/}' ~/.$tdfile
                else
                    re='^[0-9]+$'

                    while [ $# -gt 0 ]; do
                        taskId="$1"

                        [[ ! $taskId =~ $re ]] && printf "${red}[ x ] : Invalid task id\n" && exit 1;
                        
                        printf "${blue}[ i ] : Marking task $taskId as done\n"
                        sed -i "${taskId}s/\[ \]/\[x\]/" ~/.$tdfile
                        shift
                    done
                fi
                printTodo ~/.$tdfile
            fi
        
        ;;

        u|undo)
            checkExist
            shift  
            taskId="${1:-first}"    


            content=$(cat ~/.$tdfile)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                if [[ $taskId == 'first' ]]; then
                    printf "\r${blue}[ i ] : Marking first done task as undone\n"
                    sed -i '0,/\[x\]/{s/\[x\]/\[ \]/}' ~/.$tdfile
                else
                    re='^[0-9]+$'

                    while [ $# -gt 0 ]; do
                        taskId="$1"

                        [[ ! $taskId =~ $re ]] && printf "${red}[ x ] : Invalid task id\n" && exit 1;
                        
                        printf "${blue}[ i ] : Marking task $taskId as undone\n"
                        sed -i "${taskId}s/\[x\]/\[ \]/g" ~/.$tdfile
                        shift
                    done
                fi  
                printTodo ~/.$tdfile
            fi
        ;;

        ua|undoall)
            checkExist
            [ $# -gt 1 ] && printf "${yellow}[ /i\\ ] : undoall doesn't require any arguments \n"


            content=$(cat ~/.$tdfile)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                printf "${blue}[ i ] : Marking all tasks as undone\n"
                sed -i "s/\[x\]/\[ \]/g" ~/.$tdfile
                printTodo ~/.$tdfile
            fi
        ;;

        r|remove)
            checkExist
            shift  
            taskId="${1:-last}"    

            content=$(cat ~/.$tdfile)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else

                if [[ $taskId == 'last' ]]; then
                    printf "\r${blue}[ i ] : Removing the last task\n"
                    sed -i "$(cat ~/.$tdfile|wc -l)d" ~/.$tdfile
                else
                    re='^[0-9]+$'

                    taskId="$*"

                    [[ ! $taskId =~ $re ]] && printf "${red}[ x ] : Invalid task id, note that you can only specify one task : ${red}$taskId\n" && exit 1;
                    
                    printf "${blue}[ i ] : Removing task $taskId\n"
                    sed -i "${taskId}d" ~/.$tdfile
                    shift
                fi  
                printTodo ~/.$tdfile

            fi

        ;;


        e|edit)
            checkExist
            shift
            editor=${1:-vi}
            $editor ~/.$tdfile
            printTodo ~/.$tdfile
        ;;

        default|pa|printall)
            lists_arr=($(ls ~/.dtodo*))

          
            for list in "${lists_arr[@]}"
            do
                printf "\n${purple}[ i ] : Printing list $(basename $list)\n"
                printTodo $list
            done
            
        ;;

        uaa|undoallall)

            lists_arr=($(ls ~/.dtodo*))

            for list in "${lists_arr[@]}"
            do
                printf "\n${purple}[ i ] : Undoing all tasks in list $(basename $list)\n"
                sed -i "s/\[x\]/\[ \]/g" $list
                printTodo $list
            done


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
            printf "  ${green}e, edit ${blue}nano${reset}   - Manually edit the todo list ${yellow}[Default: vi]\n"
            printf "  ${green}pa, printall${reset}   - Print all daily todo lists\n"
            printf "  ${green}l, list${blue} monday${reset}${reset} - Define what todo list to perform the action on\n"
            printf "  ${green}uaa, undoallall${reset} - Undo all tasks in all daily todo lists\n"
            printf "  ${green}rl, removelist${reset} - Remove a daily todo list\n"
            printf "  ${green}h, help${reset}        - Print this help message\n"
            printf "${blue}━━━━━━━━━━━━━━━━━${reset}\n"
        ;;

        *)
            printf "${red}[ x ] : Invalid argument : $1\n"
            exit 1;
        ;;


    esac

}

parseArgs $@