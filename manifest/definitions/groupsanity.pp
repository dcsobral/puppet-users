define users::groupsanity($groupname) {
    $gid = $name
    case $operatingsystem {
        "Debian": {
            $intruder = regsubst($etcgroup, ".*^([^:]*):[^:]*:$gid:.*", '\1', 'M')
            $newgid = $gid + 10000
            exec { "groupmod -u $newgid $intruder && find /home/$intruder -gid $gid -exec chgrp $newgid {} \\;":
                logoutput => on_failure,
                unless    => "grep -qE '^$groupname:[^:]*:$gid:' /etc/group",
            }
        }
    }
}

# vim modeline - have 'set modeline' and 'syntax on' in your ~/.vimrc.
# vi:syntax=puppet:filetype=puppet:ts=4:et:
