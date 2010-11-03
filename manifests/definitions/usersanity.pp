define users::usersanity($username) {
    $uid = $name
    case $operatingsystem {
        "Debian": {
            $intruder = regsubst($etcpasswd, ".*^([^:]*):[^:]*:$uid:.*", '\1', 'M')
            $newuid = $uid + 10000
            exec { "usermod -u $newuid $intruder":
                logoutput => on_failure,
                unless    => "grep -qE '^$username:[^:]*:$uid:' /etc/passwd",
            }
        }
    }
}

# vim modeline - have 'set modeline' and 'syntax on' in your ~/.vimrc.
# vi:syntax=puppet:filetype=puppet:ts=4:et:
