define users::groupsanity($groupname) {
    $gid = $name
    if $etcgroup != '' {
        case $operatingsystem {
            "Debian": {
                # Check if there's some other group with the desired gid
                $whohas = regsubst($etcgroup, ".*^([^:]*):[^:]*:$gid:.*", '\1', 'M')
                $intruder = $whohas ? {
                    $etcgroup => '',
                    default   => $whohas,
                }

                case $intruder {
                    ''       : {
                        debug("gid $gid is not in use")
                    }
                    $username: {
                        debug("gid $gid already belong to $username")
                    }
                    default  : {
                        # If so, change the other group's gid to gid + 10000, and fix /home ownership
                        $newgid = $gid + 10000
                        exec { "groupmod -g $newgid $intruder && find /home/$intruder -gid $gid -exec chgrp $newgid {} \\;": logoutput => on_failure }
                    }
                }

                # Check if the group exists with a distinct gid
                $mygid = regsubst($etcgroup, ".*^$groupname:[^:]*:([^:]*):.*", '\1', 'M')
                $currentgid = $mygid ? {
                    $etcgroup => '',
                    default   => $mygid,
                }

                case $currentgid {
                    ''     : {
                        debug("group $username doesn't exist")
                    }
                    $gid   : {
                        debug("$username already has gid $gid")
                    }
                    default: {
                        # If so, fix /home ownership in advance (groupmod doesn't fix /home)
                        exec { "find /home/$groupname -gid $currentgid -exec chgrp $gid {} \\;": logoutput => on_failure }
                    }
                }
            }
        }
    } else {
        fail("etcpasswd fact not available")
    }
}

# vim modeline - have 'set modeline' and 'syntax on' in your ~/.vimrc.
# vi:syntax=puppet:filetype=puppet:ts=4:et:
