define users::uidsanity($username) {
    $uid = $name
    if $etcpasswd != '' {
        case $operatingsystem {
            "Debian": {
                # Check if there's some other group with the desired gid
                $whohas = regsubst($etcpasswd, ".*^([^:]*):[^:]*:$uid:.*", '\1', 'M')
                $intruder = $whohas ? {
                    $etcpasswd => '',
                    default    => $whohas,
                }

                case $intruder {
                    # Uid not in use
                    ''       : {
                        debug("uid $uid is not in use")
                    }

                    # Uid already correctly assigned
                    $username: {
                        debug("uid $uid already belong to $username")
                    }

                    # Uid with another user -- change the other users's uid to uid + 10000
                    default  : {
                        # Sanity must be done before affected users, but it won't work with older puppet clients
                        if versioncmp($puppetversion, '0.25') >= 0 {
                            Exec <| tag == "moveuid_$name" |> -> User <| title == "$intruder" or title == "$username" |>
                        }

                        # Move conflicting user's uid
                        $newuid = $uid + 10000
                        exec { "/usr/sbin/usermod -u $newuid $intruder":
                            logoutput => on_failure,
                            tag       => "moveuid_$name",
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
