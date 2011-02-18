define users::gidsanity($groupname) {
    $gid = $name
    if $etcgroup != '' {
        case $operatingsystem {
            "Debian": {
                # Always move the group id before fixing it, but this won't work on older versions of puppet client
                if versioncmp($puppetversion, '0.25') >= 0 {
                    Exec <| tag == "movegid_$name" |> -> Exec <| tag == "fixgid_$name" |>
                }

                # Check if there's some other group with the desired gid
                $whohas = regsubst($etcgroup, ".*^([^:]*):[^:]*:$gid:.*", '\1', 'M')
                $intruder = $whohas ? {
                    $etcgroup => '',
                    default   => $whohas,
                }

                case $intruder {
                    # Gid not in use
                    ''       : {
                        debug("gid $gid is not in use")
                    }

                    # Gid already correctly assigned
                    $username: {
                        debug("gid $gid already belong to $username")
                    }

                    # Gid with another group -- change the other group's gid to gid + 10000, and fix /home ownership
                    default  : {
                        # Sanity must be done before affected groups, but it won't work on older versions of puppet client
                        if versioncmp($puppetversion, '0.25') >= 0 {
                            Exec <| tag == "movegid_$name" |> -> Group <| title == "$intruder" or title == "$groupname" |>
                        }

                        # Move group and fix ownership
                        $newgid = $gid + 10000
                        exec { "/usr/sbin/groupmod -g $newgid $intruder && /usr/bin/test ! -d /home/$intruder || /usr/bin/find /home/$intruder -gid $gid -exec /bin/chgrp $newgid {} \\;":
                            logoutput => on_failure,
                            tag       => "movegid_$name",
                        }
                    }
                }

                # Check if the group exists with a distinct gid
                $mygid = regsubst($etcgroup, ".*^$groupname:[^:]*:([^:]*):.*", '\1', 'M')
                $currentgid = $mygid ? {
                    $etcgroup => '',
                    default   => $mygid,
                }

                case $currentgid {
                    # Group not created
                    ''     : {
                        debug("group $username doesn't exist")
                    }

                    # Group already correctly assigned
                    $gid   : {
                        debug("$username already has gid $gid")
                    }

                    # Group with different gid -- fix /home ownership in advance (groupmod doesn't fix /home)
                    default: {
                        # Sanity must be done before affected groups, but it won't work on older version of puppet client
                        if versioncmp($puppetversion, '0.25') >= 0 {
                            Exec <| tag == "fixgid_$name" |> -> Group <| title == "$groupname" |>
                        }

                        # Move group and fix ownership
                        exec { "/usr/bin/test ! -d /home/$groupname || /usr/bin/find /home/$groupname -gid $currentgid -exec /bin/chgrp $gid {} \\;":
                            logoutput => on_failure,
                            tag       => "fixgid_$name",
                        }
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
