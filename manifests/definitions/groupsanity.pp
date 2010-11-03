define users::groupsanity($groupname) {
    $gid = $name
    case $operatingsystem {
        "Debian": {
            # Check if there's some other group with the desired gid
            $whohas = regsubst($etcgroup, ".*^([^:]*):[^:]*:$gid:.*", '\1', 'M')
            $intruder = $whohas ? {
                $etcgroup => 'puppetfailure && false',
                default   => $whohas,
            }

            # If so, change the other group's gid to gid + 10000, and fix /home ownership
            $newgid = $gid + 10000
            exec { "groupmod -g $newgid $intruder && find /home/$intruder -gid $gid -exec chgrp $newgid {} \\;":
                logoutput => on_failure,
                unless    => "grep -qEv '^[^:]*:[^:]*:$gid:' /etc/group || grep -qE '^$groupname:[^:]*:$gid:' /etc/passwd",
                path      => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
            }

            # Check the group exists with a distinct gid
            $mygid = regsubst($etcgroup, ".*^$groupname:[^:]*:([^:]*):.*", '\1', 'M')
            $currentgid = $mygid ? {
                $etcgroup => '0 -false',
                default   => $mygid,
            }

            # If so, fix /home ownership in advance (groupmod doesn't fix /home)
            exec { "find /home/$groupname -gid $currentgid -exec chgrp $gid {} \\;":
                logoutput => on_failure,
                onlyif    => "grep -E '^$groupname:' /etc/group | grep -qEv '^$groupname:[^:]*:$gid:'",
                path      => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
            }
        }
    }
}

# vim modeline - have 'set modeline' and 'syntax on' in your ~/.vimrc.
# vi:syntax=puppet:filetype=puppet:ts=4:et:
