#!/bin/bash

# LVM Helper Script

# Disclaimer:
# This script is provided for educational purposes only. Use it at your own risk.
# The author is not responsible for any consequences or damages resulting from the use of this script.
# If you choose to run this script, make sure you understand the code and its implications.

VERSION="v0.0.1"
GR=$(tput setaf 2)
CY=$(tput setaf 6)
NC=$(tput sgr 0)
CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
REQUIRED_UTILITIES=("pvcreate" "vgcreate" "lvcreate" "mkfs.ext4" "blkid")
TMP_LOG="lvm-helper.tmp.log"

# Check if the script is being run as root
echo -ne "Check if the script is being run with root privileges...\033[0K\r"
sleep 0.5
if [[ $(id -u) -ne 0 ]]; then
    echo "To create LVM requires root privileges. Please run it as root user or use sudo."
    exit 1
else
    echo -e "\\r${CHECK_MARK} Script run with root privileges.\033[0K\r"
    sleep 0.5
fi

# Check if the required utilities are installed
echo -ne "Check required utilities...\033[0K\r"
sleep 0.5
for utility in "${REQUIRED_UTILITIES[@]}"; do
    if ! command -v "$utility" &>/dev/null; then
        echo "$utility is not installed. Please install the required tools."
        exit 1
    fi
done

# If all required utilities are installed, continue operations.
echo -e "\\r${CHECK_MARK} All required utilities are installed. Proceed script operations...\033[0K\r"
sleep 0.5

# Create a tmp log file
if [ -e $TMP_LOG ]; then
    >$TMP_LOG
fi
touch "$TMP_LOG"

# Display Main Menu
show_main_menu() {
    clear
    echo "|--------------------------------- ${CY}LVM Helper${NC} ---------------------------------|"
    echo
    echo "1. Create"
    echo "2. Delete"
    echo "3. Extend Size"
    echo "4. Reduce Size"
    echo "5. Show Info"
    echo "6. Quit"
    echo
    echo "Note:"
    echo "- This script can perform tasks such as creating, deleting, and resizing."
    echo "- Extend and Reduce size only Logical Volume (LV) supported."
    echo
    echo "This script is provided for educational purposes only. Use it at your own risk."
    echo
    echo "|----------------------------------- ${GR}$VERSION${NC} -----------------------------------|"
}

# Display submenu 1
show_submenu1() {
    clear
    echo "|--------------------------------- ${CY}LVM Helper${NC} ---------------------------------|"
    echo
    echo "1. Create Physical Volumes (PV)"
    echo "2. Create Volume Groups (VG)"
    echo "3. Create Logical Volumes (LV)"
    echo "4. Back to Main Menu"
    echo
    echo "|----------------------------------- ${GR}$VERSION${NC} -----------------------------------|"
}

# Display submenu 2
show_submenu2() {
    clear
    echo "|--------------------------------- ${CY}LVM Helper${NC} ---------------------------------|"
    echo
    echo "1. Delete Physical Volumes (PV)"
    echo "2. Delete Volume Groups (VG)"
    echo "3. Delete Logical Volumes (LV)"
    echo "4. Back to Main Menu"
    echo
    echo "|----------------------------------- ${GR}$VERSION${NC} -----------------------------------|"
}

# Display submenu 3
show_submenu3() {
    clear
    echo "|--------------------------------- ${CY}LVM Helper${NC} ---------------------------------|"
    echo
    echo "1. Extend Logical Volumes (LV)"
    echo "2. Back to Main Menu"
    echo
    echo "|----------------------------------- ${GR}$VERSION${NC} -----------------------------------|"
}

# Display submenu 4
show_submenu4() {
    clear
    echo "|--------------------------------- ${CY}LVM Helper${NC} ---------------------------------|"
    echo
    echo "1. Reduce Logical Volumes (LV)"
    echo "2. Back to Main Menu"
    echo
    echo "|----------------------------------- ${GR}$VERSION${NC} -----------------------------------|"
}

# Confirmation function
confirm() {
    while true; do
        read -p "$1 [y/n]: " choice
        case "$choice" in
        [Yy]*)
            break
            ;;
        [Nn]*)
            return 1
            ;;
        *)
            echo "Please enter 'y' for yes or 'n' for no."
            ;;
        esac
    done
    return 0
}

# Get LVM Info
update_log() {
    echo -ne "Updating LVM info...\033[0K\r"
    lvm_info >$TMP_LOG 2>&1
    sleep 0.5
    echo -e "\\r${CHECK_MARK} LVM info updated!\033[0K\r"
}

# Create PV
create_pv() {
    echo "Create Physical Volumes. Please fill required input."
    while true; do
        read -p 'Disk Path: ' VAR_DISK_PATH
        if [[ -n "$VAR_DISK_PATH" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    pvcreate $VAR_DISK_PATH
    update_log
}

# Create VG
create_vg() {
    echo "Create Volume Groups. Please fill required input."
    while true; do
        read -p 'PV Name: ' VAR_PV_NAME
        if [[ -n "$VAR_PV_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'VG Name: ' VAR_VG_NAME
        if [[ -n "$VAR_VG_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    vgcreate $VAR_VG_NAME $VAR_PV_NAME
    update_log
}

# Create LV
create_lv() {
    echo "Create Logical Volumes. Please fill required input."
    while true; do
        read -p 'VG Name: ' VAR_VG_NAME
        if [[ -n "$VAR_VG_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'LV Name: ' VAR_LV_NAME
        if [[ -n "$VAR_LV_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'LV Size: ' VAR_LV_SIZE
        if [[ -n "$VAR_LV_SIZE" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'Mountpoint: ' VAR_MOUNTPOINT
        if [[ -n "$VAR_MOUNTPOINT" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    lvcreate -L $VAR_LV_SIZE -n $VAR_LV_NAME $VAR_VG_NAME
    mkfs.ext4 /dev/$VAR_VG_NAME/$VAR_LV_NAME
    if [[ ! -d $VAR_MOUNTPOINT ]]; then
        mkdir -p $VAR_MOUNTPOINT
    fi
    UUID=$(blkid -o value -s UUID /dev/$VAR_VG_NAME/$VAR_LV_NAME)
    echo "UUID=$UUID $VAR_MOUNTPOINT ext4 defaults 0 2" >>/etc/fstab
    mount -a
    update_log
}

# Delete PV
delete_pv() {
    echo "Delete Physical Volumes. Please fill required input."
    while true; do
        read -p 'PV Name: ' VAR_PV_NAME
        if [[ -n "$VAR_PV_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    pvremove $VAR_PV_NAME
    update_log
}

# Delete VG
delete_vg() {
    echo "Delete Volume Groups. Please fill required input."
    while true; do
        read -p 'VG Name: ' VAR_VG_NAME
        if [[ -n "$VAR_VG_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    vgremove $VAR_VG_NAME
    update_log
}

# Delete LV
delete_lv() {
    echo "Delete Logical Volumes. Please fill required input."
    while true; do
        read -p 'VG Name: ' VAR_VG_NAME
        if [[ -n "$VAR_VG_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'LV Name: ' VAR_LV_NAME
        if [[ -n "$VAR_LV_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'Mountpoint: ' VAR_MOUNTPOINT
        if [[ -n "$VAR_MOUNTPOINT" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    if mountpoint -q "$VAR_MOUNTPOINT"; then
        umount "$VAR_MOUNTPOINT"
        if [ $? -eq 0 ]; then
            echo "Unmounted successfully."
        else
            echo "Unmounting failed."
        fi
    fi
    UUID=$(blkid -o value -s UUID /dev/$VAR_VG_NAME/$VAR_LV_NAME)
    line_to_delete="UUID=$UUID $VAR_MOUNTPOINT ext4 defaults 0 2"
    tmpfile=$(mktemp)
    grep -v "$line_to_delete" /etc/fstab >"$tmpfile"
    mv "$tmpfile" /etc/fstab
    wipefs -a /dev/$VAR_VG_NAME/$VAR_LV_NAME
    lvchange -an /dev/$VAR_VG_NAME/$VAR_LV_NAME
    lvremove /dev/$VAR_VG_NAME/$VAR_LV_NAME
    if confirm "Do you want to delete mountpoint directory?"; then
        rm -rf $VAR_MOUNTPOINT
    fi
    update_log
}

# Extend LV
extend_lv() {
    echo "Extend Logical Volumes Size. Please fill required input."
    while true; do
        read -p 'VG Name: ' VAR_VG_NAME
        if [[ -n "$VAR_VG_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'LV Name: ' VAR_LV_NAME
        if [[ -n "$VAR_LV_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'Size Increase: ' VAR_INCR_SIZE
        if [[ -n "$VAR_INCR_SIZE" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    lvextend -r -L +$VAR_INCR_SIZE /dev/$VAR_VG_NAME/$VAR_LV_NAME
    update_log
}

# Reduce LV
reduce_lv() {
    echo "Reduce Logical Volumes Size. Please fill required input."
    while true; do
        read -p 'VG Name: ' VAR_VG_NAME
        if [[ -n "$VAR_VG_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'LV Name: ' VAR_LV_NAME
        if [[ -n "$VAR_LV_NAME" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'Size Decrease: ' VAR_DECR_SIZE
        if [[ -n "$VAR_DECR_SIZE" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    while true; do
        read -p 'Mountpoint: ' VAR_MOUNTPOINT
        if [[ -n "$VAR_MOUNTPOINT" ]]; then
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
    if mountpoint -q "$VAR_MOUNTPOINT"; then
        umount "$VAR_MOUNTPOINT"
        if [ $? -eq 0 ]; then
            echo "Unmounted successfully."
        else
            echo "Unmounting failed."
        fi
    fi
    fsck -fy /dev/$VAR_VG_NAME/$VAR_LV_NAME
    lvreduce -r -L -$VAR_DECR_SIZE /dev/$VAR_VG_NAME/$VAR_LV_NAME
    mount -a
    update_log
}

# Perform Get LVM info function
lvm_info() {
    if [ -e "$TMP_LOG" ]; then
        >"$TMP_LOG"
    fi

    IFS=$'\n'
    export IFS

    phydis=$(pvdisplay | grep -E "PV Name|VG Name|PV Size" | awk 'NR%3{printf "%s,",$0;next}{print;}' | sed 's/PV Name//g' | sed 's/VG Name//g' | sed 's/PV Size//g' | sed 's/ //g')
    if [ -f /etc/redhat-release ]; then
        if [[ $(cat /etc/redhat-release | awk -F " " '{print$4}' | awk -F "." '{print$1}') -eq 7 ]]; then
            logdis=$(lvdisplay | grep -E "LV Path|LV Size" | awk 'NR%2{printf "%s,",$0;next}{print;}' | sed 's/LV Path//g' | sed 's/LV Size//g' | sed 's/ //g' | sort)
        else
            logdis=$(lvdisplay | grep -E "LV Name|LV Size" | awk 'NR%2{printf "%s,",$0;next}{print;}' | sed 's/LV Name//g' | sed 's/LV Size//g' | sed 's/ //g' | sort)
        fi
    else
        logdis=$(lvdisplay | grep -E "LV Name|LV Size" | awk 'NR%2{printf "%s,",$0;next}{print;}' | sed 's/LV Name//g' | sed 's/LV Size//g' | sed 's/ //g' | sort)
        flag="norh"
    fi
    phyparttrans=""

    print_heading() {
        echo "| ${GR}PV Name${NC}   | ${GR}PV Size${NC}   | ${GR}VG Name${NC}      | ${GR}VG Size${NC}   | ${GR}LV Name${NC}                   | ${GR}LV Size${NC}   | ${GR}Used${NC}   | ${GR}Avail${NC}  | ${GR}Mounted on${NC}                  |"
    }

    print_separator() {
        echo "|-----------|-----------|--------------|-----------|---------------------------|-----------|--------|--------|-----------------------------|"
    }

    print_line() {
        printf '%1s %-9s %1s %-9s %1s %-12s %1s %-9s %1s %-25s %1s %-9s %1s %-6s %1s %-6s %1s %-27s %1s\n' \
            "|" "$1" "|" "$2" "|" "$3" "|" "$4" "|" "$5" "|" "$6" "|" "$7" "|" "$8" "|" "$9" "|"
    }

    echo "LVM Information:"
    print_separator
    print_heading
    for phy in ${phydis}; do
        phypart1=$(echo "${phy}" | awk -F "," '{print$1}')
        phypart2=$(echo "${phy}" | awk -F "," '{print$2}')
        phypart3=$(echo "${phy}" | awk -F "," '{print$3}' | cut -f1 -d"/" | tr -d '<')
        if [ -z "$logdis" ]; then
            volsize=$(vgdisplay "$phypart2" 2>/dev/null | awk '/VG Size/ {gsub("<", "", $3); print $3 $NF}')
            print_separator
            print_line "$phypart1" "$phypart3" "$phypart2" "$volsize" "" "" "" ""
        fi
        if [ "$phypart2" != "$phyparttrans" ]; then
            phyparttrans="$phypart2"
            counter=1
            for log in ${logdis}; do
                volsize=$(vgdisplay "$phypart2" 2>/dev/null | awk '/VG Size/ {gsub("<", "", $3); print $3 $NF}')
                logpart1=$(echo "${log}" | awk -F "," '{print$1}')
                logpart2=$(echo "${log}" | awk -F "," '{print$2}')
                logpartmatch=$(echo "${logpart1}" | awk -F "/" '{print$3}')
                if [ $counter -eq 1 ]; then
                    if [ "${phypart2}" == "${logpartmatch}" ]; then
                        mountpoint1=$(echo "$logpart1" | awk -F "/" '{print$3}')
                        mountpoint2=$(echo "$logpart1" | awk -F "/" '{print$4}')
                        df_output=$(df -h /dev/mapper/${mountpoint1}-${mountpoint2} 2>/dev/null | tail -1)
                        Used=$(echo "$df_output" | awk -F " " '{print$3}')
                        Avail=$(echo "$df_output" | awk -F " " '{print$2}')
                        Mounted=$(echo "$df_output" | awk -F " " '{print$3$NF}')
                        print_separator
                        if [ -e /dev/mapper/${mountpoint1}-${mountpoint2} ]; then
                            print_line "$phypart1" "$phypart3" "$phypart2" "$volsize" "$logpart1" "$logpart2" "$Used" "$Avail" "$Mounted"
                        else
                            print_line "$phypart1" "$phypart3" "$phypart2" "$volsize" "" "" "" "" ""
                        fi
                        counter=$(($counter + 1))
                    elif [[ "${flag}" == "norh" ]]; then
                        df_output=$(df -h /dev/${phypart2}/${logpart1} 2>/dev/null | tail -1)
                        Used=$(echo "$df_output" | awk -F " " '{print$3}')
                        Avail=$(echo "$df_output" | awk -F " " '{print$2}')
                        Mounted=$(echo "$df_output" | awk -F " " '{print$NF}')
                        print_separator
                        if [ -e /dev/mapper/${phypart2}-${logpart1} ]; then
                            print_line "$phypart1" "$phypart3" "$phypart2" "$volsize" "$logpart1" "$logpart2" "$Used" "$Avail" "$Mounted"
                        else
                            print_line "$phypart1" "$phypart3" "$phypart2" "$volsize" "" "" "" "" ""
                        fi
                        counter=$(($counter + 1))
                    fi
                else
                    if [ "${phypart2}" == "${logpartmatch}" ]; then
                        mountpoint1=$(echo "$logpart1" | awk -F "/" '{print$3}')
                        mountpoint2=$(echo "$logpart1" | awk -F "/" '{print$4}')
                        df_output=$(df -h /dev/mapper/${mountpoint1}-${mountpoint2} 2>/dev/null | tail -1)
                        Used=$(echo "$df_output" | awk -F " " '{print$3}')
                        Avail=$(echo "$df_output" | awk -F " " '{print$2}')
                        Mounted=$(echo "$df_output" | awk -F " " '{print$NF}')
                        if [ -e /dev/mapper/${mountpoint1}-${mountpoint2} ]; then
                            print_line "" "" "" "" "$logpart1" "$logpart2" "$Used" "$Avail" "$Mounted"
                        fi
                        counter=$(($counter + 1))
                    elif [[ "${flag}" == "norh" ]]; then
                        df_output=$(df -h /dev/${phypart2}/${logpart1} 2>/dev/null | tail -1)
                        Used=$(echo "$df_output" | awk -F " " '{print$3}')
                        Avail=$(echo "$df_output" | awk -F " " '{print$2}')
                        Mounted=$(echo "$df_output" | awk -F " " '{print$NF}')
                        if [ -e /dev/mapper/${phypart2}-${logpart1} ]; then
                            print_line "" "" "" "" "$logpart1" "$logpart2" "$Used" "$Avail" "$Mounted"
                        fi
                        counter=$(($counter + 1))
                    fi
                fi
            done
        # else
        #     print_line "|" "$phypart1" "|" "$phypart3" "|" "$phypart2" "|" "$volsize" "|" " " "|" " " "|" " " "|" " " "|" " " "|"
        fi
    done
    print_separator
}

# Main Menu loop
while true; do
    show_main_menu
    if [ -s $TMP_LOG ]; then
        cat $TMP_LOG
    fi
    echo
    read -p "Enter your choice (1/2/3/etc...): " main_choice
    case "$main_choice" in
    1)
        while true; do
            show_submenu1
            if [ -s $TMP_LOG ]; then
                cat $TMP_LOG
            fi
            echo
            read -p "Enter your choice (1/2/3/etc...): " submenu1_choice
            case "$submenu1_choice" in
            1)
                create_pv
                read -p "Press Enter to continue..."
                ;;
            2)
                create_vg
                read -p "Press Enter to continue..."
                ;;
            3)
                create_lv
                read -p "Press Enter to continue..."
                ;;
            4)
                break # Go back to the main menu
                ;;
            *)
                echo "Invalid choice. Please select a valid option (1/2/3/etc...)"
                read -p "Press Enter to continue..."
                ;;
            esac
        done
        ;;
    2)
        while true; do
            show_submenu2
            if [ -s $TMP_LOG ]; then
                cat $TMP_LOG
            fi
            echo
            read -p "Enter your choice (1/2/3/etc...): " submenu2_choice
            case "$submenu2_choice" in
            1)
                delete_pv
                read -p "Press Enter to continue..."
                ;;
            2)
                delete_vg
                read -p "Press Enter to continue..."
                ;;
            3)
                delete_lv
                read -p "Press Enter to continue..."
                ;;
            4)
                break # Go back to the main menu
                ;;
            *)
                echo "Invalid choice. Please select a valid option (1/2/3/etc...)"
                read -p "Press Enter to continue..."
                ;;
            esac
        done
        ;;
    3)
        while true; do
            show_submenu3
            if [ -s $TMP_LOG ]; then
                cat $TMP_LOG
            fi
            echo
            read -p "Enter your choice (1/2/3/etc...): " submenu3_choice
            case "$submenu3_choice" in
            1)
                extend_lv
                read -p "Press Enter to continue..."
                ;;
            2)
                break # Go back to the main menu
                ;;
            *)
                echo "Invalid choice. Please select a valid option (1/2/3/etc...)"
                read -p "Press Enter to continue..."
                ;;
            esac
        done
        ;;
    4)
        while true; do
            show_submenu4
            if [ -s $TMP_LOG ]; then
                cat $TMP_LOG
            fi
            echo
            read -p "Enter your choice (1/2/3/etc...): " submenu4_choice
            case "$submenu4_choice" in
            1)
                reduce_lv
                read -p "Press Enter to continue..."
                ;;
            2)
                break # Go back to the main menu
                ;;
            *)
                echo "Invalid choice. Please select a valid option (1/2/3/etc...)"
                read -p "Press Enter to continue..."
                ;;
            esac
        done
        ;;
    5)
        update_log
        read -p "Press Enter to continue..."
        ;;
    6)
        rm -rf $TMP_LOG
        echo -ne "Exiting script...\033[0K\r"
        sleep 0.5
        echo -e "Byebye!\033[0K\r"
        sleep 0.5
        clear
        exit 0
        ;;
    *)
        echo "Invalid choice. Please select a valid option (1/2/3/etc..)"
        read -p "Press Enter to continue..."
        ;;
    esac
done