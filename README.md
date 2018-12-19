# auto-gcov-marker

This plugin provides a simple way to build load and reload gcov files for an open
source file. It will highlight the covered and uncovered lines and branches.

![Screenshot](/img/screenshot.png)

This plugin is based on [m42e/vim-gcov-marker](https://github.com/m42e/vim-gcov-marker)

## Install

If you use Vundle plugin manager for vim then auto-gcov-marker can be installed by adding

```vimrc
Plugin 'jauler/vim-auto-gcov-marker'

```
to your vimrc and running
```
PluginInstall
```

## Usage

This plugin assumes that `gcov` is installed on your machine and binary has been compiled with
coverage support. After running your test suite use command:
```
GcovBuild
```
In order for plugin to search recursively for gcno and gcda files and build gcov file.
After building gcov file it will automatically show coverage information for you.

In order to clear coverage information run:
```
GcovClear
```
command.

If you would like to specify exact gcov file to use:
```
GcovLoad <filename>.gcov
```
Note that plugin exepects gcov files in intermediate format.


## Configuration

Default markers can be customized using the variables below.
```vimrc
let g:auto_gcov_marker_line_covered = '✓'
let g:auto_gcov_marker_line_uncovered = '✘'
let g:auto_gcov_marker_branch_covered = '✓✓'
let g:auto_gcov_marker_branch_partly_covered = '✓✘'
let g:auto_gcov_marker_branch_uncovered = '✘✘'

```

By default GcovBuild searches for gcna and gcno files recursively from vim working directory, but this can be customized with following parameter:
```vimrc
let g:auto_gcov_marker_gcno_path  = 'path/to/gcno/files/'
```

Generated gcov files by default are put in vim working directory also.
This might clutter working directory - therefore it is recommended to create seperate directory for gcov files.
After creating empty directory configure plugin to use it:
```vimrc
let g:auto_gcov_marker_gcov_path  = 'path/to/gcov/files/'
```

