# bash-extension

Doing various task at bash terminal

## Installation

1. execute 

    ``bash install.sh``

## Usage / Workflow : 

1. acp/amv (advanced copy/move) : this command same as ordinary cp/mv but when there is a file conflict, it will not immidiately replace the conflicted target file, but it will ask your confirmation first wether to "keep both", "overwrite" or "cancel" the operation
2. rmt (remove to trash) : this command same as ordinary rm but instead of removing the file permanently, it will move the target into `/home/pulpen/.local/share/Trash/files` directory
3. tandai : mark the designated file / folder for future operation (move / copy)
4. mvpas:  move the marked (by tandai) file / folder into current directory
5. cppas :  copy the marked (by tandai) file / folder into current directory
6. lihat_potongan: list the marked (by tandai) file / folder
7. bersihkan_potongan: clear marked (by tandai) file / folder
8. tandai_hasil_ls : a command that has functionality to mark (by tandai) file /folder from pipe , example
ls -tr| tail -n 3 | tandai_hasil_ls, it will mark 3 last modified file
9. pipa_hasil_ls: do certain script for each piped file name
ls -tr | tail -n 3 | pipa_hasil_ls 'rm "@"', it will remove 3 last modfified file
10.  set-title: simply change terminal tab name
11. get_available_name: find available name in a directory given a prefix.
get_available_name . lala,
it will return "lala_3" if in directoy "." there is file named "lala_0", "lala_1",  "lala_2"
12. lengkapi: expand abbreviation
lengkapi des , will return /home/$USER/Desktop
13. list_manager: put designated text on designated line
list_manager test.txt "pinnaple" 3 ,
it will put "pinnaple" on line 3 (no conflict resolution, it will replace the previous line 3 content
14. tag: give postfix to a file / folder name
15. xf: copy result of pwd to clipboard
16. cdf: cd to path in clipboard
17. cdd: cd to path in clipboard (ignoring tail)
18. remove_usb: you know lah
19. catagorize: add prefix to a filename
20. add_path: add a path to env variable
21. tc: append arguments into  `$HOME/Documents/.note/fast-log.txt`
22. cari: short hand for find
23. lslas: find file that is modified within certain time range
24. mvlas: mv file that is modified within certain time range
25. normalize_file: make a file name alphanumeric , and not contain other special char except under score
26. standardize: make a file name lower case alphanumeric , and not contain other special char except under score
27. buka: open file using app that can open it

and other feature that still in development
1. sceless: scrap information from scele.cs.ui.ac.id automatically
2. vlookup
3. ftpupload: shortcut to upload file
4. track_add: mark file for automatic backup
5. track_list
6. track_edit
7. track_backup
8. track_open
9. track_substitute: move file into certain folder, and make that file symbolic link into current folder
10. track_revert_substitute: reverse of track_substitute
11. track_list_broken_link
12. track_generate_links


I am aware that above description is still too abstract, so in the future I will revise this post :)



## License : 
GNU GPL


## TODO : 
- many things

## Contribution

Found bugs, want to contribute, etc?, 
contact me : serdralfs@gmail.com
