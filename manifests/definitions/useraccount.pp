# define useraccount
# creates a user with their complete home directory, including ssh key(s),
# shell profile(s) and anything else.
# This define should be called to create a virtual resource so it can
# be used to create all users, and then the users required on the particular
# node are specified through the various user classes.
# Example:
# @useraccount { "username":
#   ensure   => "present",
#   fullname => "New User",
#   uid      => 500,
#   groups   => ["staff", "other"],
#   shell    => "/bin/bash",
#   password   => "password hash",
# }

define users::useraccount ( $ensure = present, $fullname, $uid = '', $groups = [], $shell = '/bin/bash', $password = '') {
    $username = $name
    # This case statement will allow disabling an account by passing
    # ensure => absent, to set the home directory ownership to root.
    case $ensure {
        present: {
            $home_owner = $username
            $home_group = $username
        }
        default: {
            $home_owner = "root"
            $home_group = "root"
        }
    }

    # Do not try to manage gid unless etcgroup is available
    case $etcgroup {
        '': {
            group { "$username":
                ensure    => $ensure,
                allowdupe => false,
            }
        }
        default: {
            users::groupsanity { "$uid": groupname => $username }
            group { "$username":
                ensure    => $ensure,
                gid       => $uid,
                allowdupe => false,
                require   => Users::Groupsanity["$uid"],
            }
        }
    }

    # Do not try to manage uid unless etcpass is available
    case $etcpasswd {
        '': {
            user { "$username":
                ensure     => $ensure,
                gid        => $username,
                groups     => $groups,
                comment    => $fullname,
                home       => "/home/$username",
                shell      => $shell,
                allowdupe  => false,
                password   => $password,
                managehome => true,
                require    => Group["$username"],
            }
        }
        default: {
            users::usersanity { "$uid": username => $username }
            user { "$username":
                ensure     => $ensure,
                uid        => $uid,
                gid        => $username,
                groups     => $groups,
                comment    => $fullname,
                home       => "/home/$username",
                shell      => $shell,
                allowdupe  => false,
                password   => $password,
                managehome => true,
                require    => [ Users::Usersanity["$uid"], Group["$username"], ],
            }
        }
    }

    $managedDirs = [
        "/etc/puppet/files/users/home/managed/host/${username}.$fqdn",
        "/etc/puppet/files/users/home/managed/host/${username}.$hostname",
        "/etc/puppet/files/users/home/managed/domain/${username}.$domain",
        "/etc/puppet/files/users/home/managed/env/${username}.$environment",
        "/etc/puppet/files/users/home/managed/user/${username}",
        "/etc/puppet/files/users/home/managed/skel",
    ]

    case generate('/etc/puppet/scripts/findDirs.sh', $managedDirs) {
        '': {
            file { "/home/${username}":
                ensure  => directory,
                owner   => $home_owner,
                group   => $home_group,
                #mode    => 644,    # Cannot apply mode, or it will change ALL files
                recurse => true,
                replace => false,
                ignore  => '.git',
                source  => [
                    "puppet:///files/users/home/default/host/${username}.$fqdn",
                    "puppet:///files/users/home/default/host/${username}.$hostname",
                    "puppet:///files/users/home/default/domain/${username}.$domain",
                    "puppet:///files/users/home/default/env/${username}.$environment",
                    "puppet:///files/users/home/default/user/${username}",
                    "puppet:///files/users/home/default/skel",
                    "puppet:///users/home/default",
                ],
                require   => User["${username}"],
            }
        }
        default: {
            file { "/home/${username}":
                ensure  => directory,
                owner   => $home_owner,
                group   => $home_group,
                #mode    => 644, # Cannot apply mode, or it will change ALL files
                recurse => true,
                replace => true,
                force   => true,
                ignore  => '.git',
                source  => [
                    "puppet:///files/users/home/managed/host/${username}.$fqdn",
                    "puppet:///files/users/home/managed/host/${username}.$hostname",
                    "puppet:///files/users/home/managed/domain/${username}.$domain",
                    "puppet:///files/users/home/managed/env/${username}.$environment",
                    "puppet:///files/users/home/managed/user/${username}",
                    "puppet:///files/users/home/managed/skel",
                ],
                require   => User["${username}"],
            }
        }
    }

    file { "/home/${username}/.bash_history": mode => 600 }

    file { "/home/${username}/.ssh":
        ensure  => directory,
        owner   => $home_owner,
        group   => $home_group,
        mode    => 700,
        require => File["/home/${username}"],
    }
}

# vim modeline - have 'set modeline' and 'syntax on' in your ~/.vimrc.
# vi:syntax=puppet:filetype=puppet:ts=4:et:
