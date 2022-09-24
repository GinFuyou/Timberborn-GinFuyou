#!/bin/sh
# BepInEx running script
#
# WARNING Edited by GinFuyou because original one didn't work for me
# I've renamed the file, but usage is the same
# It runs Proton directly because wrappers break for me
# Comments are mix of original and my edits, I've tried to mark my additions.
#
# HOW TO USE:
# 1. Prerequirements must be fulfilled, see README.md
# 2. Place this file in your game's dir (along with Timberborn.exe)
# 3. Make this script executable with `chmod u+x ./timberborn_linux_bepinex.sh`
# 4. In Steam, go in Steam Library -> (Game) Properties -> General -> Launch Options. Change it to:
#    ./timberborn_linux_bepinex.sh %command% > ~/timberborn.log 2>&1
# - `> ~/timberborn.log 2>&1` part will redirect output to your home dir's timberborn.log
#   it's only needed for debuging, you can remove it
# 5. Start the game via Steam
#
# Note that you won't get a console this way
# [Gin]: This gets BepInEx console for Timberborn just fine, maybe because I've removed wrappers?
#
# Appendix "A": Prerequirements and known issues
# You need to install "winhttp" DLL to run game modded. See https://github.com/BepInEx/BepInEx/issues/110
# * issue 1 - protontricks fails with error

# https://github.com/BepInEx/BepInEx/issues/110
#
# NOTE: Edit the script only if you know what you're doing!

# Resolve base directory relative to this script
# Hopefully this resolves relative paths and links
a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BASEDIR=$(cd "$a"; pwd -P)


echo ">> Starting [$(date)]"
echo " --- "

# Special case: program is launched via Steam
# In that case rerun the script via their bootstrapper to ensure Steam overlay works
if [ "$2" = "SteamLaunch" ]; then
    # Gin: This is debug part. You can sagerly remove it
    echo "Executing SteamLaunch"
    cmd="$1 $2 $3 $4 $0"
    echo "[original command]: $cmd (it will be discarded)"
    i=1
    echo "arguments (0 is the base command):"
    echo " $0"

    # Gin: regex to detect argument with proton executable:
    proton_regex='\/proton$'
    # Gin: set command to empty to try to detect proton command later with regular expression
    cmd=""
    shift_by=0

    # Gin: list all passed args and find one with proton command
    for var in "$@"
    do

        if [[ $var =~ $proton_regex ]]
        then
            echo " $i: $var [Will use this as cmd]"
            cmd=$var
            shift_by=$i
        else
            echo " $i: $var"
        fi
        i=$(( i + 1 ))
    done

    if [ "$cmd" = "" ]
    then
        echo "ERROR: command is not found. Either script didn't get expected arguments or regular expresion in it is wrong. Check the list of args above."
        echo "- regular expression was: '$proton_regex' (refer to https://regex101.com/)"
        echo "Terminating."
        exit 1
    fi

    # Gin: remove first args: WARNING arguments SHIFT
    # Gin: Run directly with Proton (no Steam wrappers)
    # cmd="${10}"  # this should be path to proton executable. Beware of space in the path
    echo "[shift arguments by]: $shift_by"
    shift $shift_by

    # Gin: more debug output
    echo "[new command]: $cmd"
    echo "[shifted args]: $@"

    exec "$cmd" $@
    exit
fi

export DOORSTOP_ENABLE=TRUE
export DOORSTOP_INVOKE_DLL_PATH="$BASEDIR/BepInEx/core/BepInEx.Preloader.dll"

# Allow to specify --doorstop-enable true|false
# Everything else is passed as-is to `exec`
while :; do
    case $1 in
        --doorstop-enable)
            if [ -n "$2" ]; then
                export DOORSTOP_ENABLE=$(echo "$2" | tr a-z A-Z)
                shift
            else
                echo "No --doorstop-enable value specified, using default!"
            fi
            ;;
        --doorstop-target)
            if [ -n "$2" ]; then
                export DOORSTOP_INVOKE_DLL_PATH="$2"
                shift
            else
                echo "No --doorstop-target value specified, using default!"
            fi
            ;;
        --doorstop-dll-search-override)
            if [ -n "$2" ]; then
                export DOORSTOP_CORLIB_OVERRIDE_PATH="$2"
                shift
            else
                echo "No --doorstop-dll-search-override value specified, using default!"
            fi
            ;;
        *)
            if [ -z "$1" ]; then
                break
            fi
            if [ -z "$launch" ]; then
                launch="$1"
            else
                rest="$rest $1"
            fi
            ;;
    esac
    shift
done


export LD_LIBRARY_PATH="$BASEDIR/doorstop_libs:$LD_LIBRARY_PATH"
export LD_PRELOAD="libdoorstop_x64.so:$LD_PRELOAD"


# Run the main executable
# Don't quote here since $exec may contain args passed by Steam
if [ -n "$launch" ]; then
    exec "$launch" $rest
else
    exec "Timberborn.exe"
fi
