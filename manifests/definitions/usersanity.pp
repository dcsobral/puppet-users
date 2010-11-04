define users::usersanity($username) {
    $uid = $name
    if $etcpasswd != '' {
        case $operatingsystem {
            "Debian": {
                $whohas = regsubst($etcpasswd, ".*^([^:]*):[^:]*:$uid:.*", '\1', 'M')
                $intruder = $whohas ? {
                    $etcpasswd => '',
                    default    => $whohas,
                }
                case $intruder {
                    ''       : {
                        debug("uid $uid is not in use")
                    }
                    $username: {
                        debug("uid $uid already belong to $username")
                    }
                    default  : {
                        $newuid = $uid + 10000
                        exec { "usermod -u $newuid $intruder": logoutput => on_failure }
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
