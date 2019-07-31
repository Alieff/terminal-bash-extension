installer_path="$(dirname ${BASH_SOURCE[0]})"
destination_path="$HOME/Documents/.script"
script_name="bash_aliases_portable.sh"


# remove executable
"rm" "$destination_path/$script_name"
echo "executable removed" : "rm $destination_path/$script_name" 

# remove autosource
sed -ie '/# bash_extension.*/,+1d' $HOME/.bashrc
echo "autosource removed"

bash "$installer_path/uninstall2.sh"

