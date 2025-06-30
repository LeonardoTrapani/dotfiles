#!/usr/bin/env bash
# shellcheck disable=SC2154
#|---/ /+----------------------------+---/ /|#
#|--/ /-| Main dotfiles setup script |--/ /-|#
#|-/ /--| Trapani's Configs          |-/ /--|#
#|/ /---+----------------------------+/ /---|#

cat <<"EOF"

-------------------------------------------------
 _____                          _     
|_   _|_ __ __ _ _ __   __ _ _ __ (_)___ 
  | | | '__/ _` | '_ \ / _` | '_ \| / __|
  | | | | | (_| | |_) | (_| | | | | \__ \
  |_| |_|  \__,_| .__/ \__,_|_| |_|_|___/
                |_|                     
  ____             __ _           
 / ___|___  _ __  / _(_) __ _ ___ 
| |   / _ \| '_ \| |_| |/ _` / __|
| |__| (_) | | | |  _| | (_| \__ \
 \____\___/|_| |_|_| |_|\__, |___/
                        |___/     

-------------------------------------------------

EOF

#--------------------------------#
# import variables and functions #
#--------------------------------#
scrDir="$(dirname "$(realpath "$0")")"
# shellcheck disable=SC1091
if ! source "${scrDir}/Scripts/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

#------------------#
# evaluate options #
#------------------#
flg_Stow=0
flg_Install=0
flg_DryRun=0
flg_Default=0

while getopts sidnh: RunStep; do
    case $RunStep in
    s) flg_Stow=1 ;;
    i) flg_Install=1 ;;
    d)
        flg_Default=1
        export use_default="--noconfirm"
        ;;
    n) flg_DryRun=1 ;;
    h)
        cat <<EOF
Usage: $0 [options]
            s : [s]tow dotfiles only
            i : run [i]nstallation scripts only
            d : run with [d]efaults (no prompts)
            n : dry ru[n] - test without executing
            h : show this [h]elp

NOTE: 
        running without args will prompt for what to run
        use -d for automated setup with defaults

EXAMPLES:
        setup.sh       # Interactive mode
        setup.sh -d    # Run everything with defaults
        setup.sh -s    # Only stow dotfiles
        setup.sh -n    # Test run without executing

EOF
        exit 0
        ;;
    *)
        echo "Invalid option. Use -h for help."
        exit 1
        ;;
    esac
done

# Set up logging
SETUP_LOG="$(date +'%y%m%d_%Hh%Mm%Ss')_setup"
export flg_DryRun SETUP_LOG
export HYDE_LOG="$SETUP_LOG"  # Reuse the logging system

if [ "${flg_DryRun}" -eq 1 ]; then
    print_log -n "[test-run] " -b "enabled :: " "Testing without executing"
elif [ $OPTIND -eq 1 ] && [ "${flg_Default}" -eq 0 ]; then
    # Interactive mode - ask user what to do
    print_log -c "🔧 Welcome to Trapani's Configs Setup!"
    echo ""
    print_log -g "What would you like to do?"
    print_log -sec "1" " Stow dotfiles"
    print_log -sec "2" " Run installation scripts"
    print_log -sec "3" " Do everything (recommended)"
    print_log -sec "q" " Quit"
    echo ""
    
    prompt_timer 30 "Enter option number [default: 3 - everything]"
    
    case "${PROMPT_INPUT}" in
    1) flg_Stow=1 ;;
    2) flg_Install=1 ;;
    3) 
        flg_Stow=1
        flg_Install=1
        ;;
    q)
        print_log -sec "setup" -crit "Quit" "Exiting..."
        exit 0
        ;;
    *)
        print_log -sec "setup" -warn "Defaulting to everything"
        flg_Stow=1
        flg_Install=1
        ;;
    esac
elif [ "${flg_Default}" -eq 1 ] && [ $OPTIND -eq 2 ]; then
    # Default mode - do everything
    flg_Stow=1
    flg_Install=1
fi



#---------------------#
# Stow files if requested #
#---------------------#
if [ ${flg_Stow} -eq 1 ]; then
    cat <<"EOF"

 ____  _                   
/ ___|| |_ _____      __   
\___ \| __/ _ \ \ /\ / /   
 ___) | || (_) \ V  V /    
|____/ \__\___/ \_/\_/     

EOF

    print_log -g "🔧 Stowing dotfiles..."
    STOW_DIR="$HOME/dotfiles/Stow"
    
    if [ ! -d "$STOW_DIR" ]; then
        print_log -sec "stow" -err "Stow directory not found at $STOW_DIR"
        exit 1
    fi

    if [ "${flg_DryRun}" -eq 1 ]; then
        print_log -n "[test-run] " -b "would stow :: " "files from $STOW_DIR"
        cd "$STOW_DIR" || exit
        for dir in */; do
            dir=${dir%/}  # Remove trailing slash
            print_log -n "[test-run] " -b "would stow :: " "$dir"
        done
    else
        cd "$STOW_DIR" || exit
        stow_success=0
        stow_total=0
        
        for dir in */; do
            dir=${dir%/}  # Remove trailing slash
            stow_total=$((stow_total + 1))
            print_log -g "🔧 Stowing " -y "$dir" -g "..."
            
            if stow -v -t "$HOME" "$dir" 2>/dev/null; then
                print_log -g "✅ Successfully stowed " -y "$dir"
                stow_success=$((stow_success + 1))
            else
                print_log -sec "stow" -warn "Failed to stow $dir (may already be stowed)"
            fi
        done
        
        print_log -g "✅ Stow complete: " -y "$stow_success" -g "/" -y "$stow_total" -g " packages processed"
    fi
fi

#-------------------------------#
# Run installation scripts if requested #
#-------------------------------#
if [ ${flg_Install} -eq 1 ]; then
    cat <<"EOF"

 ___           _        _ _ 
|_ _|_ __  ___| |_ __ _| | |
 | || '_ \/ __| __/ _` | | |
 | || | | \__ \ || (_| | | |
|___|_| |_|___/\__\__,_|_|_|

EOF

    print_log -g "🔧 Running installation scripts..."
    INSTALL_SCRIPT="$HOME/dotfiles/Scripts/install.sh"
    
    if [ ! -f "$INSTALL_SCRIPT" ]; then
        print_log -sec "install" -err "Installation script not found at $INSTALL_SCRIPT"
        exit 1
    fi

    if [ "${flg_DryRun}" -eq 1 ]; then
        print_log -n "[test-run] " -b "would run :: " "$INSTALL_SCRIPT"
    else
        chmod +x "$INSTALL_SCRIPT"
        print_log -g "🚀 Launching " -y "Trapani's Configs" -g " installation..."
        
        # Pass through any additional arguments
        if [ -n "${use_default}" ]; then
            "$INSTALL_SCRIPT" -d
        else
            "$INSTALL_SCRIPT"
        fi
        
        if [ $? -eq 0 ]; then
            print_log -g "✅ Installation scripts executed successfully"
        else
            print_log -sec "install" -err "Installation scripts failed"
            exit 1
        fi
    fi
fi

#--------------------#
# completion message #
#--------------------#
echo ""
if [ "${flg_DryRun}" -eq 1 ]; then
    print_log -n "[test-run] " -b "Setup test completed"
else
    print_log -g "✅ " -y "Trapani's Configs" -g " setup complete!"
    
    # Show what was done
    actions_performed=()
    [ ${flg_Stow} -eq 1 ] && actions_performed+=("Dotfiles stowing") 
    [ ${flg_Install} -eq 1 ] && actions_performed+=("Installation scripts")
    
    if [ ${#actions_performed[@]} -gt 0 ]; then
        print_log -b "Completed actions: " -y "${actions_performed[*]}"
    fi
    
    print_log -c "💡 You may want to restart your shell or reboot your system."
fi

print_log -b "Log: " -y "View logs at ${cacheDir}/logs/${SETUP_LOG}"

# Ask for reboot if installation scripts were run
if [ ${flg_Install} -eq 1 ] && [ "${flg_DryRun}" -ne 1 ]; then
    echo ""
    print_log -stat "Trapani's Configs" "It is not recommended to use newly installed or upgraded Trapani's Configs without rebooting the system. Do you want to reboot the system? (y/N)"
    read -r answer

    if [[ "$answer" == [Yy] ]]; then
        print_log -g "Rebooting system..."
        systemctl reboot
    else
        print_log -c "💡 Remember to reboot when convenient to ensure all changes take effect."
    fi
fi
