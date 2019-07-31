#================ Port-able (to be used in a bare server)

#>>>>>>>>>>>>> Functional
alias prettify='python -mjson.tool'; #dependency: python2.7
alias lslasr='find . -type f -exec ls -lrt {} +';
alias pindahin_terbaru='cari_terbaru_hari_ini  | xargs -0 mv -t terbaru/'
alias normalize='echo | xclip -o | sed -rz "s/[^a-zA-Z0-9._]+/_/g"';
alias renlas='clip_temp=$(xsel --clipboard);echo $(pwd)/$(normalize).pdf | xclip ; amv "$(ls -tr | tail -n 1)" reckless; echo $clip_temp | xclip ';
alias lowercase="tr '[:upper:]' '[:lower:]'"
alias infinite="while true :; do sleep 1; echo 1; done"
alias infinite2="while true :; do sleep 1; notify-send 1; done"
# alias cari='ls | grep'
# alias carir= carir text <depth>
alias check_what_makes_busy='lsof | grep /media/pulpen';
alias alhamdulillah='systemctl poweroff -i';
alias goodbyecruelworld='systemctl poweroff -i';
alias stealth='export STEALTH=1;export PS1="\[\e[31m\]\u\[\e[m\]\[\e[37m\] : "'
alias unstealth='export STEALTH=0;export PS1="\[\e[31m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[36m\]\w\[\e[m\] \[\e[36m\]:\[\e[m\] "'
alias getsize='python /home/pulpen/Documents/.script/get-dir-total-size.py';
alias cdlas='cd $(ls -tr | tail -n 1)';
alias get_git_push_size='echo $(git merge-base HEAD origin/master)..HEAD | git pack-objects --revs --thin --stdout --all-progress-implied > packfile';
alias generate_password="head /dev/urandom | tr -dc A-Za-z0-9 | head -c 1000 ; echo ''"
alias git_update="git add . ; git commit -m 'update' ; git push origin"; #dependency: git
alias ls_terakhir="ls -tr | tail -n 1";
alias teleport_="teleport | grep -i " #dependency
alias ls_="ls | grep -i "
alias newls='ls -tp | grep -v /$  ';
alias oldls='ls -ltr --color=always';
alias ls_dir='ls -d */'
alias ls_file='find . -type f'
alias ls_type='ls -p | grep -v / |rev | cut -d"." -f1|rev | sort | uniq -c'
alias ls_size='du -ahd 1 .'
alias ls_sortnum='ls | sort -V'
alias python_pake_2="sudo update-alternatives --remove python /usr/bin/python3; sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1"
alias python_pake_3="sudo update-alternatives --remove python /usr/bin/python2; sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1"
alias apache_reload='service apache2 reload'
alias apache_restart='service apache2 restart'
#@@@@@@@@@@@@@@@@@@ Server functional
alias server_last='last'
alias server_last_reboot='last reboot'
alias server_last_shutdown='last shutdown'
alias server_architecture='cat /proc/cpuinfo'
alias server_architecture2='uname -m'
alias server_architecture3='uname -a'
alias server_architecture4='lsb_release -a'
alias server_architecture4='cat /etc/lsb-release'
alias server_gtk_version='dpkg -l libgtk*'
alias server_error_log='journalctl'
alias server_graphic_card='lspci | grep VGA'
alias server_disks='lsblk'
alias server_kernel_message='sudo dmesg'
alias server_paritition_size='df -h'
alias server_paritition_type='df -T'
alias server_get_port_user='lsof -i tcp:80'
alias server_get_pid_user='lsof -p 18311'
alias networking_list_interface='ip link show'
alias networking_get_network_interface_relation='ip address'
alias networking_get_all_connected_ip='sudo netstat -tn'
alias networking_list_all_openned_port='sudo netstat -tulpn '
alias networking_get_process_name_from_pid='sudo ls -l /proc/5668/exe '
alias networking_get_cwd_of_proc='sudo ls -l /proc/5668/cwd'
alias networking_list_firewall='sudo ufw app list'
alias networking_get_routing='ip -4 route'

#>>>>> CD#TELEPORT#PATH#PROJECT ======
alias vim='cd ~/.vim'
alias dow='cd ~/Downloads';	
alias vim_swp='cd "~/.vim-backups"; ls -a'
alias htdocs='cd /var/www/html/';
alias web='cd /var/www/html/';
alias html='cd /var/www/html/';
alias var='cd /var/www/html/';
alias vhost='cd /etc/apache2/sites-available'

#>>>>>>>> File Editing ======
alias valias='vim ~/.bash_aliases';
alias srcbashrc='source ~/.bashrc; echo "source done"';



