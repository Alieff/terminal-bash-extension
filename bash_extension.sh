#!/bin/bash
# source "$HOME/Documents/.script/library.sh"
# setup folder 
# if [ ! -d "$HOME/Documents/.script/database" ]; then
#   mkdir -p "$HOME/Documents/.script/database";
# fi
# if [ ! -f "$HOME/Documents/.script/database/teleporter_GLOBAL_CONTEXT" ]; then
#   touch "$HOME/Documents/.script/database/teleporter_GLOBAL_CONTEXT";
# fi
# if [ ! -f "$HOME/Documents/.script/database/teleporter_$local_context" ]; then
#   touch "$HOME/Documents/.script/database/teleporter_$local_context";
# fi
# if [ ! -f "$HOME/Documents/.script/database/teleporter_$global_context" ]; then
#   touch "$HOME/Documents/.script/database/teleporter_$global_context";
# fi

#------------------------------------------------------------ FEATURE - FILE MV/CP

if [ ! -d "$HOME/.local/share/Trash/files" ]; then
  mkdir -p "$HOME/.local/share/Trash/files" 
fi

# cd ke folder, dengan menyimpan history cd, biar nanti bisa back ke folder sebelumnya
# cara pakai : `acd _nama_folder_`
function acd(){
  if [ -z "$@" ]; then
    "cd" ~
    pushd ~ > /dev/null
  else
    pushd "$@" > /dev/null
  fi
}

_sudoOn=0
function sacp(){
  _sudoOn=1
  acp "$@"
  _sudoOn=0
}
function samv(){
  _sudoOn=1
  amv "$@"
  _sudoOn=0
}
function srmt(){
  _sudoOn=1
  rmt "$@"
  _sudoOn=0
}

#advanced copy, mirip advanced move
# cara pakai : `acp _nama_file_yang_mau_dicopy_ _tujuan_`
_acpOn=0
function acp(){
  _acpOn=1
  amv "$@"
  _acpOn=0
}

# advanced move , move dengan opsi keep/overwirte/cancel jika ada konflik
# cara pakai : `amv _nama_file_yang_mau_dimove_ _tujuan_`
function amv(){
  local file_to_move=("$@")
  local last_idx=$(( ${#file_to_move[@]} - 1 ))
  local destination=${file_to_move[$last_idx]}
  local realdest=$destination

  # expand shortcut destination
  local destination=$(lengkapi $destination 2> /dev/null )
  if [ -z "$destination" ]; then 
    echo "invalid shortcut $destination" ; 
    read -p "do you want to rename / copy with different name on destination instead ? (y/n)" ans
    case $ans in
      "y" ) if [ $_acpOn -eq 1 ]; then
              handle_file_conflict 0 0 0 "." "$realdest"
              "cp" -R "$1" "$_new_name"; 
              echo -e " > $1 \e[92mcopied to\e[0m $(basename "$_new_name")";
            else 
              handle_file_conflict 0 0 0 "." "$realdest"
              if [ $_sudoOn -eq 1 ]; then 
                sudo "mv" "$1" "$realdest"; 
              else 
                "mv" "$1" "$realdest"; 
              fi
              echo -e " > $1 \e[92mrenamed to\e[0m $(basename "$realdest")";
            fi
            return;;
      "n" ) return;; 
      * ) echo "Please answer with y/n"; return;;
    esac
  fi

  # handle copy, move, remove
  file_to_move[$last_idx]="$destination"
  handle_file_operation "${file_to_move[@]}"
}

# helper amv 
function handle_file_operation(){
  local file_to_move=("$@")
  local last_idx=$(( ${#file_to_move[@]} - 1 ))
  local destination=${file_to_move[$last_idx]}
  unset file_to_move[$last_idx]

  local counter=1
  local oall=0
  local kall=0
  local call=0

  if [ $kallMode -eq 1 ]; then kall=1; fi

  # process(copy/move) all file except last
  for ii in "${file_to_move[@]}" 
  do
    # echo $ii
    if [  -z "$ii" ]; then echo "$ii not exist"; continue; fi
    _new_name=$(basename "$ii")
      # ada conflict di destination path
        # echo "oldname :  $_new_name";
       handle_file_conflict $oall $kall $call "$destination" "$_new_name"
        # echo "handling $_new_name";

      # echo "ii : $ii"
      if [ $_acpOn -eq 1 ]; then 
        copy "$ii" "$destination" "$_new_name"
        # echo copy "|$ii|" "|$destination|" "|$_new_name|"
      else
        # echo "moving $_new_name";
        move "$ii" "$destination" "$_new_name"
        # echo move "$ii" "$destination" "$_new_name"
      fi
    ((counter++))
  done
}

# helper amv 
# mengisi global variable _new_name yang akan digunakan
function handle_file_conflict(){
  oall=$1
  kall=$2
  call=$3
  destination="$4"
  filename="$5"

  # case pindahin file biasa
  if [ ! -e "$destination/$filename" ] ; then #&& [ $destination != $(pwd) ]; then
    _new_name="$filename";
    return;
  fi

   # echo "file $ii exists in $destination, "
    if [ $oall -eq 1 ] ; then 
      yn=o
    elif [ $kall -eq 1 ] ; then 
      yn=k
    elif [ $call -eq 1 ] ; then 
      yn=c
    else
      echo -e "processing \e[34m$filename\e[0m , file with this name already found"
      read -p " > you can overwrite, keep both or cancel (o/k/c/oall/kall/call)" yn </dev/tty
    fi
    case $yn in 
        "oall" ) oall=1; yn=o;;
        "kall" ) kall=1; yn=k;; 
        "call" ) call=1; yn=c;;
    esac
    case $yn in
        [Oo]* ) 
          # echo "lala2"; 
          local bin_path=$(lengkapi bin 2> /dev/null )
          bin_name=$(get_available_name "$bin_path" "$filename")
          if [ -f $destination/$filename ]; then 
            bin_name=$(basename $bin_name)
            "mv" "$destination/$filename" "$bin_path/$bin_name";
            echo " > mv" "$destination/$filename" "$bin_path/$bin_name"  
            echo -e " > old files \e[92mmoved\e[0m to bin";
            _new_name="$filename"
            # echo "lala3" 
          else 
            echo "overwrite folder not supported";
            return;
          fi
          ;;
        [Kk]* ) _new_name=$(get_available_name "$destination" "$filename") ;; 
        [Cc]* ) echo -e "\e[92mcanceled\e[0m"; ((counter++)); continue ;break;;
        * ) echo "Please answer with 'o' or 'k' or 'c'.";;
    esac
}

# helper amv
# test case : - cp temp ninja/te2(file) #overwrite, te2 udah exists di ninja, di bin juga udah eksis, 
function move(){
  ii="$1"
  destination="$2"
  _new_name="$3"  
  # move verbose 
  if [ $verboseMode -eq 1 ]; then echo "trashing $ii" ; fi
  # move 
  if [ -e "$ii" ]; then 
    if [ $_sudoOn -eq 1 ]; then 
      sudo "mv" "$ii" "$destination/$_new_name"
    else 
      "mv" "$ii" "$destination/$_new_name"
    fi
    echo -e $ii" \e[92mmoved\e[0m to $destination/$_new_name"
  else
    echo -e "\e[31mmove failed\e[0m : no such file or directory"
  fi
}
# helper acp
function copy(){
  ii="$1"
  destination="$2"
  _new_name="$3"
  if [ -e "$ii" ]; then 
    if [ $_sudoOn -eq 1 ]; then 
      sudo "cp" -R "$ii" "$destination/$_new_name"
    else 
      "cp" -R "$ii" "$destination/$_new_name"
    fi
    echo -e " > $ii \e[92mcopied\e[0m to $destination/$_new_name\n --"
  else
    echo -e " > \e[31mcopy failed\e[0m : no such file or directory"
  fi
}

#verboseMode ketika move file
verboseMode=0
kallMode=0
# remove to trash, dengan opsi keep/overwirte/cancel
# cara pakai : `rmt _file_yang_mau_diremove_`
function rmt(){
  local OPTIND

  if [ "$(pwd)" == "$HOME/.local/share/Trash/files" ]; then
    "rm" -r "$@"
    return
  fi


  verboseMode=0
  # parameter ketika panggil bash
  while getopts ":v:" opt ; do
    case $opt in
      v)
        verboseMode=1
        ;;
    esac
  done
  if [ $verboseMode -eq 1 ]; then
    shift
  fi

  kallMode=1
  amv "$@" "bin"
  kallMode=0
  verboseMode=0
}


#----------------------------------------------------------------------------------- FEATURE - COPAS
# melist daftar command yang ada di fitur "COPAS"
# cara pakai : `copas`
function copas(){
  echo "lihat_potongan"
  echo "bersihkan_potongan"
  echo "tandai"
  echo "cppas"
  echo "mvpas"
}
alias lihat_potongan="cat -n $HOME/Documents/.script/database/cutter_paster"
alias bersihkan_potongan=' echo "" > $HOME/Documents/.script/database/cutter_paster'

# menyimpan file yang akan dipindahkan ke suatu database temporary
# cara pakai : `tandai _nama_file(bisa > 1)_`
function tandai(){
  if [ ! -f $HOME/Documents/.script/database/cutter_paster ]; then
    touch $HOME/Documents/.script/database/cutter_paster
  fi
  if [ $(wc -l $HOME/Documents/.script/database/cutter_paster | awk '{print $1}') -gt 1 ]; then 
    echo -e "\e[92mappending\e[0m $@" ; 
  else
    echo -e "\e[92madding\e[0m    $@" ;
  fi

  for ii in "$@"; do
    echo "$(pwd)/$ii" >> $HOME/Documents/.script/database/cutter_paster
  done
}
export -f "tandai";


# apply fungsi tandai ke hasil ls 
# cara pakai : `ls | grep lala | tandai_hasil_ls`, akan menandai semua file hasil `ls | grep lala`
function tandai_hasil_ls(){
  xargs -d'\n' -I{} bash -c 'tandai "{}"' 
}

function pipa_hasil_ls(){
  if [ $# -ne 1 ]; then
    echo "usage example : ls| tail -n 2 | pipa_hasil_ls 'tag 0 nama_tag \"@\" <<< y'"
    echo "jangan lupa export fungsi yang ingin dipakai"
    return
  fi
  cmd=$1
  echo "command "$cmd
    echo
  xargs -d'\n' -I@ bash -c "$cmd"   
}

# memindahkan file yang sudah di 'tandai' ke current path 
# cara pakai : `mvpas`
function mvpas(){
  local file_to_move=""
  local counter=0
  while read ii; do
    if [ -z "$ii" ]; then continue; fi
    file_to_move[$counter]="$ii"
    ((counter++))
  done < $HOME/Documents/.script/database/cutter_paster
    amv "${file_to_move[@]}" paste
  echo "" > $HOME/Documents/.script/database/cutter_paster
}
# menyalin file yang sudah di 'tandai' ke current path 
# cara pakai : `cppas`
function cppas(){
  local file_to_copy=""
  local counter=0
  while read ii; do
    if [ -z "$ii" ]; then continue; fi
    file_to_copy[$counter]="$ii"
    ((counter++))
  done < $HOME/Documents/.script/database/cutter_paster
    acp "${file_to_copy[@]}" paste
  echo "" > $HOME/Documents/.script/database/cutter_paster
}

#------------------------------------------------------------------------ MINI FUNCTION
function set-title() {
  if [[ -z "$ORIG" ]]; then
    ORIG=$PS1
  fi
  TITLE="\[\e]2;$*\a\]"
  PS1=${ORIG}${TITLE}
}

#------------------------------------------------------------------------ LIBRARY


# get unused name $2 in specified directory $1
# cara pakai : `get_available_name _directory_ _filename_`
function get_available_name(){
  local dir_dest="$1"
  local file_dest="$2"
  local counter=0
  new_name_candidate="$dir_dest/$file_dest"_"$counter"
  while [ -e "$new_name_candidate" ] || [ -L "$new_name_candidate" ] ; do
    ((counter++))
    new_name_candidate="$dir_dest/$file_dest"_"$counter"
  done
  echo $file_dest"_"$counter
}

# shortcut for dir path 
# cara pakai : `lengkapi _shortcut_`
# contoh : `lengkapi des`
function lengkapi(){
  local destination=$1
  # echo destination
  if [ "$destination" == "des" ]; then
    local destination="$HOME/Desktop"
  elif [ "$destination" == "doc" ]; then
    local destination="$HOME/Documents"
  elif [ "$destination" == "dow" ]; then
    local destination="$HOME/Downloads"
  elif [ "$destination" == "pic" ] || [ "$destination" == "pik" ]; then
    local destination="$HOME/Pictures/temporary"
  elif [ "$destination" == "temp" ]; then
    local destination="$HOME/.temp"
  elif [ "$destination" == "hides" ]; then
    local destination="$HOME/Desktop/.hidden-desktop"
  elif [ "$destination" == "vid" ]; then
    local destination="$HOME/Videos"
  elif [ "$destination" == "trash" ] || [ "$destination" == "bin" ]; then
    local destination="$HOME/.local/share/Trash/files"
  elif [ "$destination" == "clip" ]; then
    # move files to pasted location in clipboard(pasted clipboard)
    local destination=$(xsel --clipboard)
    if [ ! -e "$destination" ]; then 
      (>&2 echo "clipboard value not valid destination")  
      return 
    fi
  elif [ "$destination" == "paste" ]; then
    local destination=$(pwd)
  elif [ "$destination" == "reckless" ]; then #recless clip, clip without verification
    local destination=$(xsel --clipboard)
  else 
    if [ ! -d "$destination" ]; then
      >&2 echo "shortcut not found"
      return
    fi
  fi
  echo $destination
}


# mengisi file $1 di baris ke $3 dengan string $2
function list_manager(){
  local nama_file=$1
  local isi_list=$2
  # cek apakah ada file
  if [ ! -f $nama_file ]; then
      echo > $nama_file
  fi
  if [ "$#" -lt 3 ]; then
    local num=1
  else
    local num=$3
  fi
  local currentLineNum=$(wc -l $nama_file | awk '{print $1}')
  if [ $currentLineNum -le $num ]; then 
    local def=$((num - currentLineNum))
    for ii in $(seq 0 $def) ; do
      echo >> $nama_file
    done
  fi
  sed -i "${num}s/^.*/${isi_list}/" $nama_file
  echo "Marked in index $num"
}

# tag
# cara pakai
# tag 1 sesuatu a
#   nanti filename a berubah jadi sesuatu-a 
# tag 2 sesuatu a
#   nanti filename a berubah jadi a-sesuatu 
# tag 3 sesuatu a
#   nanti filename a berubah jadi a--sesuatu 
function tag(){
  if [ $# -lt 3 ]; then
    echo "usage : tag <tag_position> <tag_name> <filename>"
    echo "tag_position : 0-n, 0 to prepend tag"
    echo "tag_name : isinya bebas"
  fi

  local tag_pos=$1
  local tag=$2
  local input=$@
  IFS=" " read -r -a input <<< "$@" # read as array to variable input
  # echo "tag_pos : $tag_pos"
  # echo "tag : '$tag'"
  local current_filename
  local currnt_fname_chunks
  local last_input_idx=$(($#))
  local index 
  local index2
  # echo "last_input_idx $last_input_idx"

  IFS=$'\n'
  for index in $(seq 3 $last_input_idx);
  do

      current_filename="${!index}"
      # echo "current_filename $current_filename"
      IFS="-"  read -r -a currnt_fname_chunks <<< "$current_filename" # read as array to variable input

      # get build length
      IFS=$'\n'
      local build_length=$tag_pos
      if [ ${#currnt_fname_chunks[@]} -gt $tag_pos ]; then
        build_length=${#currnt_fname_chunks[@]}
      fi

      #build the new name
      local new_name=""
      for index2 in $(seq 1 $build_length)
      do
        if [ $tag_pos == 0 ]; then
          new_name="$tag-$current_filename-" #tambah strip dummy buat dipotong dibawah          
          break;
        elif [ $index2 == $tag_pos ]; then
          new_name="$new_name$tag-"
          if [ -z $tag ]; then
            new_name=${new_name::-1} # remove_usbove last char
          fi
        else
          local offbyone=$((index2 - 1))
          new_name="$new_name${currnt_fname_chunks[offbyone]}-"
        fi
      done
      new_name=${new_name::-1} # remove_usbove last char
      echo "$current_filename => $new_name"
      mv "$current_filename" "$new_name"
  done

  IFS=$'\n'' '' '
}

# mengcopy fullpath suatu file 
# cara pakai : `xf _nama_file_`
function xf(){
  filename=$1
  echo "$(pwd)/$filename" | xclip;
  echo "$(pwd)/$filename copied"
}

# cd ke directory dari suatu path file 
# cara pakai : `cdf nama_file` 
function cdf(){
  cd "$(dirname "$(xsel --clipboard)")"
}
function cdd(){
  cd "$(xsel --clipboard)"
}

# memindahkan file $1 ke $2 dan membuat symbolic link ke path file $1
# misal : preserve Desktop/la.txt dow  
# function preserve(){
  # // TODO
# }


# remove usb 
# cara pakai : `remove_usb /dev/sdb1`, remove usb sdb1
function remove_usb(){
  local aa="$@"
  if [ -z "$aa" ]; then 
    aa="/dev/sdb1" ; 
  else 
    aa="$@" ;
  fi  
  udisksctl unmount -b "$aa"; 
  udisksctl power-off  -b "$aa";
}


# rename file dengan menambahkan prefix ke file target  
# cara pakai : `catagorize _namafile(string)_ _katagorinya(string)_`
function catagorize(){
  local last_arg=$#
  local catagory=${!last_arg}
  local counter=1

  for ii in "$@" 
  do
    if [ $counter -ne $last_arg ]; then 
      local stemName=$(basename "$ii" | perl -pe 's/\([^\(\)]*\)$//g')
      
      if [ -e "$(dirname $stemName)/$stemName($catagory)" ]; then
        echo "file/folder $(dirname $stemName)/$stemName($catagory) exists, skipping"
        ((counter++))
        continue        
      else
        if [ -z $catagory ]; then 
          "mv" "$ii" "$(dirname $stemName)/$stemName"          
        else
          "mv" "$ii" "$(dirname $ii)/$(basename $stemName)($catagory)"
          # echo "mv" "$ii" "$(dirname $stemName)/$stemName($catagory)"
        fi
      fi    
    fi
    ((counter++))
  done

}

# menambahkan path ke environtment system
# cara pakai : `add_path _namapath(string)_`
function add_path(){
  if ! echo $PATH | grep $1 > /dev/null ; then 
    export PATH=$PATH:$1
  fi
}

# append string ke file "fast-log" (buat dulu filenya coy)
# cara pakai : `tc _string_yg_di_append_ke_file(string)_`
function tc(){
  # read pipa; 
  # echo "$pipa" $HOME/Documents/.note/fast-log.txt
  # echo $@ >> $HOME/Documents/.note/fast-log.txt;
  echo 'end with ctrl+c'
  tee -a $HOME/Documents/.note/fast-log.txt > /dev/null;
}

# mencari file
# cara pakai : `cari _substring_yg_ingin_dicari(string)_ _depth(int)_`
function cari(){

  if [ $# -lt 2 ]; then #The $# variable will tell you the number of input arguments the script was passed.
      echo "cara pakai : cari sesuatu 1 <folder:optional>"
  fi
  if [ -z $2 ]; then # if empty
    $3='.'
  fi
  
  local eps='*$1*'
  # find $3 -maxdepth $2 -iname "*$1*" | grep -i "$1" ;
  find $3 -maxdepth $2 -iregex ".*$1.*" | grep -i "$1" ;
}

# ls berdasarkan waktuyang akan dipindahkan mvlas
# cara pakai : `lslas -7000 +5000`, mencari file yang diedit dari 5000-7000 menit yang lalu 
function lslas(){
  if [ "$#" -eq 2 ]; then
    find . -mindepth 1 -maxdepth 1 -mmin $1 -mmin $2
  else  
    find . -mindepth 1 -maxdepth 1 -mmin $1
  fi
}
# memindahkan file terakhir yang baru diedit, cara pakai mirip lslas
# cara pakai : `mvlas $HOME/Desktop`,  
function mvlas(){
  local namaFolder=baru_$(date | tr '[A-Z ]' '[a-z\-]')
  mkdir -p $namaFolder # -p = bikin sub dir if not exists
  touch -t 000001010000 $namaFolder

  # last a day
  # find . -mindepth 1 -maxdepth 1 -mtime -1 -exec mv -t baru {} +

  if [ $# -lt 1 ]; then #The $# variable will tell you the number of input arguments the script was passed.
      echo "cara pakai : mvlas <lebih_dari_brp_menit_terakhir(optional)(harus positif)> <kurang_dari_brp_menit_terakhir(harus negatif)> "
      echo "misal mau cari di rentang 5000-7000 menit yang lalu. ''mvlas +5000 -7000 '' "
  fi

  if [ "$#" -eq 2 ]; then
    find . -mindepth 1 -maxdepth 1 -mmin $1 -mmin $2 -exec mv -t $namaFolder {} +
  else  
    find . -mindepth 1 -maxdepth 1 -mmin $1 -exec mv -t $namaFolder {} +
  fi
}


# melakukan normalisasi nama file (buang semua non alfabetik)
# cara pakai : `normalize_file _nama_file_`
function normalize_file(){
  local namaBaru=$(echo $1 | sed -rz "s/[^a-zA-Z0-9._]+/_/g");  
  # echo $namaBaru;
  mv "$1" $namaBaru;
}

# standardize filename (ubah semua nama file jadi lowercase)
# cara pakai : `standardize _nama_file_`
function standardize(){
  for f in "$@"; do
    local new_name="$(echo $f | sed -e 's/[^A-Za-z0-9\.]/_/g' | tr '[A-Z]' '[a-z]')"
    "mv" -v "$f" "$new_name"; 
  done
}

# membuka file(semua ekstensi) sesuai programnya
# cara pakai : `buka _nama_file_`
function buka(){
  if echo "$1" |lowercase | grep -q '\.csv\|\.xls\|\.ods\|\.doc\|\.docx'; then 
    libreoffice "$1"; 
  elif echo "$1" |lowercase | grep -q '\.sh\|\.html\|\.java\|\.py\|\.txt' ; then
    vi "$1"
  elif echo "$1" |lowercase | grep -q '\.svg' ; then
    inkscape "$1"
  elif echo "$1" |lowercase | grep -q '\.png\|\.jpg\|\.jpeg\|\.gif' ; then
    eog "$1"
  elif echo "$1" |lowercase | grep -q '\.pdf' ; then
    evince "$1"
  elif echo "$1" |lowercase | grep -q '\.mkv\|\.3gp\|\.mp4' ; then
    vlc "$1"
  elif echo "$1" |lowercase | grep -q '\.mp3' ; then
    audacious "$1"
  else
    vi "$1"
  fi
}




# DEVELOPMENTAL
#--------------------------------------

function sceless(){
  scele $@ | less;
} 

# mencari 
function vlookup(){
  $1 | grep '$2' | awk '{printf "%s \n",$'$3'}'; 
}

function ftpupload(){
  local username=$1
  local password=$2
  local host=$3
  local server_root_on_local=$4
  local file_to_move=$5

  echo "ncftpput -u $1 -p $2 $3 $4 $5";
}


# add the first parameter (the file) to tracked list  
function track_add(){
  if [ $# -eq 0 ]
  then echo "please input filename" 
  else

  for names in "$@"
  do
    if [[ -f $names ]]; then
      echo $(pwd)/$names >> $HOME/.catatan-in-dropbox;
    fi 
  done
  fi
}

function track_list(){
  cat $HOME/.catatan-in-dropbox;
}

function track_edit(){
  gvim $HOME/.catatan-in-dropbox;
}

function track_backup(){
  cp $HOME/.catatan-in-dropbox $HOME/Dropbox/my-cat/backup-tracked-files
  while read p; do
      cp "$p" $HOME/Dropbox/my-cat/backup-tracked-files 
  done < $HOME/.catatan-in-dropbox
}

function track_open(){
  cd "$HOME/Dropbox/my-cat/backup-tracked-files"
}

# this function move the first parameter (file) to dropbox and create symbolic link to that file
function track_substitute(){
  if [ -f "$1" ]; then 
    local newname=$(pwd | sed 's/\//#/g')"#$1"
    local destination=$HOME/Dropbox/my-cat/backup-tracked-files/$newname
    mv "$1" "$destination"
    local filename=$(basename "$destination")
    ln -s "$HOME/Dropbox/my-cat/backup-tracked-files/$filename" "$1"
  else 
    echo "file not found | can only substitute file"
  fi
}

# this function move the first parameter (file) to dropbox and create symbolic link to that file
function track_revert_substitute(){
  echo "not implemented yet";
}

# find all symbolic link in current dir
# usage : track_list_broken_link > a.txt # nanti a.txt buat input fungsi track_generate_links 
function track_list_broken_link(){
  for filename in $(find . -maxdepth 1 -type l); do
    echo "ln -s|"$(readlink $filename)"|"$(basename $filename) 
  done
}
# generate symlink from a file
# usage : track_generate_links <file_name>
function track_generate_links(){
  while read command; do
    IFS='|' read -ra cmd_array <<< "$command"
    echo "ln -s "${cmd_array[1]} ${cmd_array[2]}
    ln -s ${cmd_array[1]} ${cmd_array[2]}
  done < "$1"
}
