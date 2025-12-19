#!/bin/bash


ANSWER=""
PATH_TO_FILE="/home/student/DevOps/Bash-Scripting/to-do-list.txt"

while true; do
    echo -e "\n1 - View list\n2 - Exit"
    read -p "What do you want to do? " ANSWER

    case "$ANSWER" in
        1)
            echo -e "\nYou selected: View list\n"
            cat "$PATH_TO_FILE"

            while true; do
                echo -e "\nWhat do you want to do?
1 - Add new task
2 - Mark as completed
3 - Delete task
4 - Back"

                read -p "Choose: " ANSWER_FOR_LIST

                case "$ANSWER_FOR_LIST" in
                    1)
                        read -p "Enter new task: " NAME_OF_NEW_TASK
                        if [[ -n "$NAME_OF_NEW_TASK" ]]; then
                            echo "- | $NAME_OF_NEW_TASK" >> "$PATH_TO_FILE"
                        fi
                        ;;
                    2)
                        echo -e "\nAll tasks:\n"
                        tail -n +3 "$PATH_TO_FILE" | nl -w2 -s". "
                        echo ""

                        read -p "Enter task number to mark as completed: " NUM
                        LINE=$((NUM + 2))

                        sed -i "${LINE}s/^- |/x |/" "$PATH_TO_FILE"
                        ;;
                    3)
                        echo -e "\nAll tasks:\n"
                        tail -n +3 "$PATH_TO_FILE" | nl -w2 -s". "
                        echo ""

                        read -p "Enter task number to delete: " NUM
                        LINE=$((NUM + 2))

                        sed -i "${LINE}d" "$PATH_TO_FILE"
                        ;;
                    4)
                        break
                        ;;
                    *)
                        echo "Wrong choice"
                        ;;
                esac
            done
            ;;
        2)
            echo "Exit..."
            break
            ;;
        *)
            echo "Wrong choice. Enter 1 or 2!"
            ;;
    esac
done
