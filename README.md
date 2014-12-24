Hg-Code-Counter
===============
[Background]
This simple tool is aimed at counting the changed lines in Mecurial(hg) version control system. With users and duration specified, this tool can count out the changed lines for each user or in total, the lines with only blanks changed are ignored. It utilizes the existed commands in hg, the precision of this tool relies strongly on the presicion of hg.

[Platform/Tools needed]
1st, *nix or windows OS;
2nd,  Hg client installed, and added into OS Environment Path;
3rd,  Bash shell interepter(Cygwin in windows, for example) installed.

[Configuration]
Most of configuration are done in file confige.properites, here is the intereptations for each item in this file:
1. Item with key [users], specify the users to be counted.
2. Items with key [count_from_time] and [count_end_time], specify the duration to be counted respectively.
3. Item with key [webclaim_root_path], specify the root directory of a project to be counted.

[Execution]
Put count.sh and config.properties in identical directory(Directory Path is unlimited);
Open shell interepter(cygwin etc.) and switch to directory where this tool resides in;
execute: ./count.sh

[Report]
After executing successfully, the reports will be generated in a sub-directory under directory where this tool resides in,
the sub-directory is named according to the time when the script is starting to be executed.

[Customize]
The output can be customized by extending this simple tool.
