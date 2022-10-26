#!/bin/bash

showHelp()
{
cat << EOF

-----------------------------------------------------------------------------------------------------------------
   This script is designed to remove a range of lines from files, while protecting symlinks, user/group file
     permissions and avoiding file locking which causes the files to be write protected during processing.
-----------------------------------------------------------------------------------------------------------------

      Example: script.sh --follow-symlinks --verbose --start-line 11 --end-line 20 --filepath "/var/log/app/*.log"
      Example: script.sh -lv -s 11 -e 20 -f "/var/log/app/*.log"

      Required options:
      -s, --start-line           Define the initial line number within the range to remove.
      -e, --end-line             Define the final line number within the range to remove.
      -f, --filepath             Define the full filepath of the files to remove the line range from.

      Optional options:
      -l, --follow-symlinks      Include symlinks when replacing a range of lines.
      -m, --max-depth            Maximum amount of directory levels to decend while scanning for files (default: 0).
      -v, --verbose              Prints the files that are being modified as the program processes.
      -h, --help                 Display help options for this script to function correctly.

      Hint: When testing this script, you can output the contents of a file with line numbers.

      Example: cat test.txt  | awk '{print "Line "NR ": " \$0}'

EOF
}

optionlist=("-h" "-help" "--help" "-e" "-end-line" "--end-line" "-f" "-filepath" "--filepath" "-s" "-start-line" "--start-line" "-l" "-follow-symlinks" "--follow-symlinks" "-m" "-max-depth" "--max-depth" "-v" "-verbose" "--verbose")

declare -i start end
declare filepath symlink verbose
maxdepth=0

# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# -a is for long options with single dash like -version
if ! options=$(getopt -n "Line Remover" -l help,end-line:,filepath:,start-line:,follow-symlinks,max-depth:,verbose -o he:f:s:m:lv -a -- "$@")
then
    exit 1
fi

# If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters
# are set to the arguments, even if some of them begin with a '-'.
eval set -- "$options"

while true
do
   case "$1" in
      -h|--help)
         showHelp
         exit
         ;;
      -e|--end-line)
         shift
         if [[ " ${optionlist[@]} " =~ " $1 " ]]
         then
             echo "Line Remover: option requires an argument -- 'e'"
             exit 1
         elif [[ $1 == -* ]]
         then
             echo "Line Remover: unrecognized option '$1'"
             exit 1
         elif [ ! -z "${1//[0-9]}" ]
         then
             echo "Line Remover: the end-line option must be an integer"
             exit 1
         else
             end="$1"
         fi
         ;;
      -f|--filepath)
         shift
         if [[ " ${optionlist[@]} " =~ " $1 " ]]
         then
             echo "Line Remover: option requires an argument -- 'f'"
             exit 1
         elif [[ $1 == -* ]]
         then
             echo "Line Remover: unrecognized option '$1'"
             exit 1
         else
             filepath="$1"
         fi
         ;;
      -s|--start-line)
         shift
         if [[ " ${optionlist[@]} " =~ " $1 " ]]
         then
             echo "Line Remover: option requires an argument -- 's'"
             exit 1
         elif [[ $1 == -* ]]
         then
             echo "Line Remover: unrecognized option '$1'"
             exit 1
         elif [ ! -z "${1//[0-9]}" ]
         then
             echo "Line Remover: the start-line option must be an integer"
             exit 1
         else
             start="$1"
         fi
         ;;
      -m|--max-depth)
         shift
         if [[ " ${optionlist[@]} " =~ " $1 " ]]
         then
             echo "Line Remover: option requires an argument -- 'm'"
             exit 1
         elif [[ $1 == -* ]]
         then
             echo "Line Remover: unrecognized option '$1'"
             exit 1
         elif [ ! -z "${1//[0-9]}" ]
         then
             echo "Line Remover: the max-depth option must be an integer"
             exit 1
         else
             maxdepth="$1"
         fi
         ;;
      -l|--follow-symlinks)
         symlink="-L"
         ;;
      -v|--verbose)
         verbose="-print"
         ;;
      --)
         shift
         break
         ;;
      esac
      shift
done
shift $((OPTIND-1))

if [ -z $start ] || [ -z $end ] || [ -z "$filepath" ]
then
    echo "Line Remover: the start-line, end-line and filepath options are a requirement"
    exit 1
elif [ $end -le $start ]
then
    echo "Line Remover: the start of the removal range must be a lower value than the end"
    exit 1
fi

find $symlink $filepath -maxdepth $maxdepth ! -type d ! -type l $verbose -execdir vi +"$start","$end"d +wq "{}" \;
