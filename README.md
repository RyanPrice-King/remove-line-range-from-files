# remove-line-range-from-files

```

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

      Example: cat test.txt  | awk '{print "Line "NR ": " $0}'

```

You can use `sed`, but you have to make the changes to a temporary file and use `cp` to overwrite the original, avoiding issues with symlinks and permissions.


Alternatively, you can just automate the `vi` text editor to do it. 

This retains symlinks and user/group and file permissions, whilst avoiding file locking and causing the file to be write protected during processing.

`vi +<Start line to remove>,<End line to remove>d +wq <file>`

For instance:

`vi +13,26d +wq my.log`

Which would remove lines 13-26 (including 13 and 26) from the file `my.log`.

Unfortunately, this did not work properly with multiple files or wildcard patterns.

For instance:
`vi +13,26d +wq my*` - Would not find `my.log` and only the files `my*` without a filename extension `.xxx`.


So a better way would be to use the `find` package to find the files first and execute the command for each one.

`find -L my* ! -type d -execdir vi +13,26d +wq "{}" \;`

This method will allow for wildcard patterns and with the `-L` argument, will also follow symlinks.
