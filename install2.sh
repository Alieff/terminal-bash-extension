# create directory to store data
mkdir -p "$HOME/Documents/.script/database"
installer_path="$(dirname ${BASH_SOURCE[0]})"
destination_path="$HOME/Documents/.script"
script_name="./bash_aliases_portable.sh"

# copy the script 
if [[ -z "$(ls $HOME/Documents/.script | grep bash_extension\.sh)" ]]; then 
  # copy source
  "cp" "$installer_path/$script_name" "$destination_path"
  echo "Copying done" : "cp $installer_path/$script_name" "$destination_path"
else # case if already installed
  echo 
  echo "Bash extension executable is already exist"
  echo
fi

# register the script for auto source
if [[ -z "$(cat $HOME/.bashrc | grep bash_extension)" ]]; then 
  # add auto source script
  echo "# bash_extension, don't change 1 line below this line, use uninstall instead" >> $HOME/.bashrc
  "echo" "source $HOME/Documents/.script/$script_name" >> $HOME/.bashrc
  echo "registering to bashrc done"
  # source bashrc
  source "$HOME/.bashrc"
else # case if already installed
  echo 
  echo "Bash extension system auto source is already defined"
  echo
fi

