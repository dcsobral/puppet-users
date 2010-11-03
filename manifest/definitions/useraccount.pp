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

define users::useraccount ( $ensure = present, $fullname, $uid = '', $groups = [], $shell = '/bin/bash', password = '') {
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

    users::groupsanity { "$uid": groupname => $username }
    users::usersanity { "$uid": username => $username }

    case $uid {
        '': {
            group { "$username":
                ensure   => $ensure,
                allowdup => false,
            }
        }
        default: {
            group { "$username":
                ensure   => $ensure,
                gid      => $uid,
                allowdup => false,
                require  => Users::Groupsanity["$uid"],
            }
        }
    }
    case $uid {
        '': {
            user { "$username":
                ensure     => $ensure,
                gid        => $username,
                groups     => $groups,
                comment    => $fullname,
                home       => "/home/$username",
                shell      => $shell,
                allowdupe  => false,
                passwd     => $password,
                managehome => true,
                require    => Group["$username"],
            }
        }
        default: {
            user { "$username":
                ensure     => $ensure,
                uid        => $uid,
                gid        => $username,
                groups     => $groups,
                comment    => $fullname,
                home       => "/home/$username",
                shell      => $shell,
                allowdupe  => false,
                passwd     => $password,
                managehome => true,
                require    => [ Users::Usersanity["$uid"], Group["$username"], ],
            }
        }
    }
    file { "/home/${username}":
        ensure    => directory,
        owner     => $home_owner,
        group     => $home_group,
#        mode      => 755,
#        recursive => true,
#        source    => [
#            "puppet:///files/users/home/host/${username}.$fqdn",
#            "puppet:///files/users/home/host/${username}.$hostname",
#            "puppet:///files/users/home/domain/${username}.$domain",
#            "puppet:///files/users/home/env/${username}.$environment",
#            "puppet:///files/users/home/skel",
#            "puppet:///users/home",
#        ]
        require   => User["${username}"],
    }
    file { "/home/${username}/.ssh":
        ensure  => directory,
        owner   => $home_owner,
        group   => $home_group,
        mode    => 700,
        require => File["/home/${username}"],
    }
#    file { "/home/${username}/.profile":
#        ensure  => present,
#        owner   => $home_owner,
#        group   => $home_group,
#        mode    => 640,
#        require => File["/home/${username}"],
#
#        source  => "puppet:///users/${username}/.profile",
#        source  => "puppet:///users/skel/.profile",
#    }
#    file { "/home/${username}/.bashrc":
#        ensure  => present,
#        owner   => $home_owner,
#        group   => $home_group,
#        mode    => 640,
#        require => File["/home/${username}"],
#        source  => "puppet:///users/${username}/.bashrc",
#        source  => "puppet:///users/skel/.bashrc",
#    }
#    file { "/home/${username}/.bash_profile":
#        ensure  => "/home/${username}/.bashrc",
#        require => File["/home/${username}/.bashrc"],
#    }
}

# vim modeline - have 'set modeline' and 'syntax on' in your ~/.vimrc.
# vi:syntax=puppet:filetype=puppet:ts=4:et:
