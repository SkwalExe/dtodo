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




function printTodoList() { # Prints the specified (first argument passed to the function) todo list
    content=$(cat -b $1) # -b to add lien number

    if [[ -z ${content// } ]]; then # the // is to remove trailing spaces
        printf "${blue}[ i ] : The daily todo list is empty \n"
        exit 1;
    else
        printf "\n${blue}$content\n"
    fi
}

function checkExist() { # Check if the current todo file ($tdfile) exists
    if [ ! -f ~/.$tdfile ]; then #
        printf "${blue}[ i ] : Creating ~/.${tdfile}...\n" 
        if ! touch ~/.$tdfile; then # try to create the file, else print error and exit
            printf "${red}[ x ] : Failed to create ~/.$tdfile\n"
            exit 1;
        fi
    fi
}

tdfile="dtodo"  # the todo file to execute the action on 
                # the todo files are ~/.dtodo-*
                # the default todo file is ~/.dtodo



function parseArgs() { # parse command line arguments


    command=${1:-default} # the command to execute on the todo list # if not argument is specified, default command (printall) is used
   
    case "$command" in

        l|list) # specify which todo list to execute the command on
            if [ $# -gt 1 ]; then
                    shift
                    _tdfile="$1" # temporary variable to store the todo list
                
                    if [[ -z ${_tdfile// } ]]; then
                        printf "${red}[ x ] : Missing argument for list\n"
                        exit 1;
                    else
                        tdfile="dtodo-$_tdfile"
                        shift
                        parseArgs $@ # parse args again to execute the specified command on the just specified todo list
                    fi
                
                else
                    printf "${red}[ x ] : Missing argument for list\n"
                    exit 1;
                fi

        ;;

        rl|removelist) # delete a todo list
            if [ $# -gt 1 ]; then
                    shift
                    toremove="$1" # variable to store the todo list to remove
                
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


        p|print) # print the current todo list
            checkExist
            [ $# -gt 1 ] && printf "${yellow}[ /i\\ ] : print doesn't require any arguments \n" # if there is more than one argument print a warning because the arguments are ignored
            printTodoList ~/.$tdfile
        ;;

        a|add) # add a new task to the current todo list
            checkExist
            if [ $# -gt 1 ]; then
                shift
                taskName="$*" # variable to store the task name - equal to all the remaining arguments after the command
            
                if [[ -z ${taskName// } ]]; then
                    printf "${red}[ x ] : Missing argument for add\n"
                    exit 1;
                else
                    printf "\r${blue}[ i ] : Adding task: $taskName\n"
                    printf "[ ] - $taskName\n" >> ~/.$tdfile
                    printTodoList ~/.$tdfile
                fi
            
            else
                printf "${red}[ x ] : Missing argument for add\n"
                exit 1;
            fi
        ;;

        c|clear) # remove all tasks from the current todo list
            checkExist 
            [ $# -gt 1 ] && printf "${yellow}[ /i\\ ] : clear doesn't require any arguments \n" # if there is more than one argument print a warning because the arguments are ignored
            printf "\r${blue}[ i ] : Clearing the daily todo list\n"
            printf "" > ~/.$tdfile # overwrite the todo list
            printTodoList  ~/.$tdfile
        ;;

        d|done) # mark a task as done
            checkExist 
            shift
            taskId="${1:-first}" # the task id to mark as done "first" if no argument is specified

            content=$(cat ~/.$tdfile)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                if [[ $taskId == 'first' ]]; then # if no argument is specified mark the first undone task as done
                    printf "\r${blue}[ i ] : Marking first undone task as done\n"
                    sed -i '0,/\[ \]/{s/\[ \]/\[x\]/}' ~/.$tdfile # on the first line containing [ ] replace it with [x]
                else
                    re='^[0-9]+$' # regex to check if the argument is a number

                    while [ $# -gt 0 ]; do # while there are arguments
                        taskId="$1"

                        [[ ! $taskId =~ $re ]] && printf "${red}[ x ] : Invalid task id\n" && exit 1; # if the argument is not a number print error and exit
                        
                        printf "${blue}[ i ] : Marking task $taskId as done\n"
                        sed -i "${taskId}s/\[ \]/\[x\]/" ~/.$tdfile # on the specified line replace [ ] with [x]
                        shift # remove the task id from the arguments list and parse the remaining arguments
                    done
                fi
                printTodoList ~/.$tdfile
            fi
        
        ;;

        u|undo) # mark a task as undone
            checkExist
            shift 
            taskId="${1:-first}" # the task id to mark as undone "first" if no argument is specified


            content=$(cat ~/.$tdfile)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                if [[ $taskId == 'first' ]]; then
                    printf "\r${blue}[ i ] : Marking first done task as undone\n"
                    sed -i '0,/\[x\]/{s/\[x\]/\[ \]/}' ~/.$tdfile # on the first line containing [x] replace it with [ ]
                else
                    re='^[0-9]+$' # regex to check if the argument is a number

                    while [ $# -gt 0 ]; do # while there are arguments
                        taskId="$1"

                        [[ ! $taskId =~ $re ]] && printf "${red}[ x ] : Invalid task id\n" && exit 1;
                        
                        printf "${blue}[ i ] : Marking task $taskId as undone\n"
                        sed -i "${taskId}s/\[x\]/\[ \]/g" ~/.$tdfile # on the specified line replace [x] with [ ]
                        shift
                    done
                fi  
                printTodoList ~/.$tdfile
            fi
        ;;

        ua|undoall) # undo all tasks on the current todo list
            checkExist
            [ $# -gt 1 ] && printf "${yellow}[ /i\\ ] : undoall doesn't require any arguments \n" # if there is more than one argument print a warning because the arguments are ignored


            content=$(cat ~/.$tdfile)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else
                printf "${blue}[ i ] : Marking all tasks as undone\n"
                sed -i "s/\[x\]/\[ \]/g" ~/.$tdfile # replace all [x] with [ ]
                printTodoList ~/.$tdfile
            fi
        ;;

        r|remove) # remove a task from the todo list

            checkExist
            shift  
            taskId="${1:-last}" # the task id to remove "last" if no argument is specified

            content=$(cat ~/.$tdfile)
            if [[ -z ${content// } ]]; then
                printf "\r${blue}[ i ] : The daily todo list is empty \n"
                exit 1;
            else

                if [[ $taskId == 'last' ]]; then
                    printf "\r${blue}[ i ] : Removing the last task\n"
                    sed -i "$(cat ~/.$tdfile|wc -l)d" ~/.$tdfile # remove the last line
                else
                    re='^[0-9]+$' # regex to check if the argument is a number

                    taskId="$*" # can only specify on task to remove because else we would have an error 

                    [[ ! $taskId =~ $re ]] && printf "${red}[ x ] : Invalid task id, note that you can only specify one task : ${red}$taskId\n" && exit 1; # if the argument is not a number print error and exit
                    
                    printf "${blue}[ i ] : Removing task $taskId\n"
                    sed -i "${taskId}d" ~/.$tdfile # remove the specified line
                    shift
                fi  
                printTodoList ~/.$tdfile

            fi

        ;;


        e|edit) # open the todo list in an editor
            checkExist
            shift
            editor=${1:-vi}
            $editor ~/.$tdfile
            printTodoList ~/.$tdfile
        ;;

        default|pa|printall) # print all the todo lists
            lists_arr=($(ls ~/.dtodo*)) # list of all the existing todo lists

          
            for list in "${lists_arr[@]}" # for each list
            do
                printf "\n${purple}[ i ] : Printing list $(basename $list)\n"
                printTodoList $list # print it
            done
            
        ;;

        uaa|undoallall) # undo all tasks on all todo lists

            lists_arr=($(ls ~/.dtodo*)) # the list of all the existing todo lists

            for list in "${lists_arr[@]}" # for each list
            do
                printf "\n${purple}[ i ] : Undoing all tasks in list $(basename $list)\n"
                sed -i "s/\[x\]/\[ \]/g" $list # replace all [x] with [ ]
                printTodoList $list
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

parseArgs $@ # Call the fonction with the arguments passed to the script