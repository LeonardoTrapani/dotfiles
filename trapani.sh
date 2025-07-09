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
flg_Restore=0
flg_Services=0
flg_Themes=0
flg_Env=0
flg_DryRun=0
flg_Default=0
flg_NoNvidia=0
flg_NoThemes=0

while getopts sprvtedmnxh RunStep; do
    case $RunStep in
    s) flg_Stow=1 ;;
    p) flg_Install=1 ;;
    r) flg_Restore=1 ;;
    v) flg_Services=1 ;;
    t) flg_Themes=1 ;;
    e) flg_Env=1 ;;
    d)
        flg_Default=1
        export use_default="--noconfirm"
        ;;
    m) flg_NoThemes=1 ;;
    n) flg_NoNvidia=1 ;;
    x) flg_DryRun=1 ;;
    h)
        cat <<EOF
Usage: $0 [options]
            s : [s]tow dotfiles only
            p : install [p]ackages only
            r : [r]estore config files only
            v : enable system ser[v]ices only
            t : install [t]hemes only
            e : setup [e]nvironment variables (API keys)
            d : run with [d]efaults (no prompts)
            m : no the[m]e reinstallations
            n : ignore/[n]o nvidia actions
            x : dry run - test without e[x]ecuting
            h : show this [h]elp

NOTE: 
        running without args will prompt for what to run
        use -d for automated setup with defaults
        combine flags for multiple actions (e.g., -pr for packages + restore)

EXAMPLES:
        trapani.sh       # Interactive mode
        trapani.sh -d    # Run everything with defaults
        trapani.sh -s    # Only stow dotfiles
        trapani.sh -pr   # Install packages and restore configs
        trapani.sh -e    # Only setup environment variables
        trapani.sh -sprvt # Do everything (stow + packages + restore + services + themes)
        trapani.sh -x     # Dry run - test without executing

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
    print_log -sec "2" " Install packages"
    print_log -sec "3" " Restore config files"
    print_log -sec "4" " Enable system services"
    print_log -sec "5" " Install themes"
    print_log -sec "6" " Setup environment variables (API keys)"
    print_log -sec "7" " Do everything (recommended)"
    print_log -sec "8" " Custom selection (choose multiple)"
    print_log -sec "q" " Quit"
    echo ""
    
    prompt_timer 30 "Enter option number [default: 7 - everything]"
    
    case "${PROMPT_INPUT}" in
    1) flg_Stow=1 ;;
    2) flg_Install=1 ;;
    3) flg_Restore=1 ;;
    4) flg_Services=1 ;;
    5) flg_Themes=1 ;;
    6) flg_Env=1 ;;
    7) 
        flg_Stow=1
        flg_Install=1
        flg_Restore=1
        flg_Services=1
        flg_Themes=1
        flg_Env=1
        ;;
    8)
        # Custom selection mode
        print_log -g "Select actions to perform (y/n):"
        
        print_log -n "Stow dotfiles? [y/N]: "
        read -r answer
        [[ "$answer" == [Yy] ]] && flg_Stow=1
        
        print_log -n "Install packages? [y/N]: "
        read -r answer
        [[ "$answer" == [Yy] ]] && flg_Install=1
        
        print_log -n "Restore config files? [y/N]: "
        read -r answer
        [[ "$answer" == [Yy] ]] && flg_Restore=1
        
        print_log -n "Enable system services? [y/N]: "
        read -r answer
        [[ "$answer" == [Yy] ]] && flg_Services=1
        
        print_log -n "Install themes? [y/N]: "
        read -r answer
        [[ "$answer" == [Yy] ]] && flg_Themes=1
        
        print_log -n "Setup environment variables? [y/N]: "
        read -r answer
        [[ "$answer" == [Yy] ]] && flg_Env=1
        
        print_log -n "Skip nvidia actions? [y/N]: "
        read -r answer
        [[ "$answer" == [Yy] ]] && flg_NoNvidia=1
        
        print_log -n "Skip theme reinstallations? [y/N]: "
        read -r answer
        [[ "$answer" == [Yy] ]] && flg_NoThemes=1
        ;;
    q)
        print_log -sec "setup" -crit "Quit" "Exiting..."
        exit 0
        ;;
    *)
        print_log -sec "setup" -warn "Defaulting to everything"
        flg_Stow=1
        flg_Install=1
        flg_Restore=1
        flg_Services=1
        flg_Themes=1
        flg_Env=1
        ;;
    esac
elif [ "${flg_Default}" -eq 1 ] && [ $OPTIND -eq 2 ]; then
    # Default mode - do everything
    flg_Stow=1
    flg_Install=1
    flg_Restore=1
    flg_Services=1
    flg_Themes=1
    flg_Env=1
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

#-----------------------------------------#
# Setup environment variables if requested #
#-----------------------------------------#
if [ ${flg_Env} -eq 1 ]; then
    cat <<"EOF"

 _____            
| ____|_ ____   __
|  _| | '_ \ \ / /
| |___| | | \ V / 
|_____|_| |_|\_/  

EOF

    print_log -g "🔧 Setting up private environment variables..."
    ENV_SCRIPT="$HOME/dotfiles/Scripts/manage_env.sh"
    
    if [ ! -f "$ENV_SCRIPT" ]; then
        print_log -sec "env" -err "Environment management script not found at $ENV_SCRIPT"
        exit 1
    fi

    if [ "${flg_DryRun}" -eq 1 ]; then
        print_log -n "[test-run] " -b "would run :: " "$ENV_SCRIPT setup"
    else
        chmod +x "$ENV_SCRIPT"
        print_log -g "🔑 Launching environment variable setup..."
        
        if [ "${flg_Default}" -eq 1 ]; then
            # In default mode, just initialize quietly without prompting
            "$ENV_SCRIPT" init true
            if [ $? -eq 0 ]; then
                print_log -g "✅ Created private environment file"
            else
                print_log -g "✅ Private environment file already exists"
            fi
            print_log -sec "env" -warn "Default mode: use './Scripts/manage_env.sh edit' to add your API keys"
        else
            # Interactive mode - let manage_env.sh handle everything
            "$ENV_SCRIPT" setup
        fi
        
        if [ $? -ne 0 ]; then
            print_log -sec "env" -err "Environment setup failed"
            exit 1
        fi
    fi
fi

#-------------------------------#
# Run installation scripts if requested #
#-------------------------------#
if [ ${flg_Install} -eq 1 ] || [ ${flg_Restore} -eq 1 ] || [ ${flg_Services} -eq 1 ] || [ ${flg_Themes} -eq 1 ]; then
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
        
        # Build install.sh arguments based on selected options
        install_args=""
        
        [ ${flg_Install} -eq 1 ] && install_args="${install_args}i"
        [ ${flg_Restore} -eq 1 ] && install_args="${install_args}r"
        [ ${flg_Services} -eq 1 ] && install_args="${install_args}s"
        [ ${flg_NoNvidia} -eq 1 ] && install_args="${install_args}n"
        
        # Handle themes logic carefully:
        # - If themes are selected, ensure restore is included (themes need restore process)
        # - If restore is selected but themes are NOT selected, skip themes
        if [ ${flg_Themes} -eq 1 ]; then
            # Themes selected: ensure restore is included (themes need restore process)
            if [[ "$install_args" != *"r"* ]]; then
                install_args="${install_args}r"
            fi
        elif [ ${flg_Restore} -eq 1 ] && [ ${flg_Themes} -eq 0 ]; then
            # Restore selected but themes NOT selected: skip themes
            install_args="${install_args}m"
        fi
        
        # Apply explicit no-themes flag if set
        [ ${flg_NoThemes} -eq 1 ] && install_args="${install_args}m"
        
        if [ -n "${use_default}" ]; then
            install_args="${install_args}d"
        fi
        
        # If no specific install actions selected, default to full install
        if [ -z "$install_args" ] || [ "$install_args" = "d" ]; then
            install_args="irs${install_args}"
        fi
        
        print_log -g "📦 Running with flags: " -y "-${install_args}"
        
        "$INSTALL_SCRIPT" "-${install_args}"
        
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
    [ ${flg_Install} -eq 1 ] && actions_performed+=("Package installation")
    [ ${flg_Restore} -eq 1 ] && actions_performed+=("Config restoration")
    [ ${flg_Services} -eq 1 ] && actions_performed+=("System services")
    [ ${flg_Themes} -eq 1 ] && actions_performed+=("Theme installation")
    [ ${flg_Env} -eq 1 ] && actions_performed+=("Environment setup")
    
    if [ ${#actions_performed[@]} -gt 0 ]; then
        print_log -b "Completed actions: " -y "${actions_performed[*]}"
    fi
    
    print_log -c "💡 You may want to restart your shell or reboot your system."
fi

print_log -b "Log: " -y "View logs at ${cacheDir}/logs/${SETUP_LOG}"

# Ask for reboot if installation scripts were run
if [ \( ${flg_Install} -eq 1 \) -o \( ${flg_Restore} -eq 1 \) -o \( ${flg_Services} -eq 1 \) -o \( ${flg_Themes} -eq 1 \) ] && [ "${flg_DryRun}" -ne 1 ]; then
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
