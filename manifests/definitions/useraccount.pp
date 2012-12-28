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

    # Default user settings
    user { "$username":
        ensure     => $ensure,
        gid        => $username,
        groups     => $groups,
        comment    => "$fullname,,,",
        home       => "/home/$username",
        shell      => $shell,
        allowdupe  => false,
        managehome => true,
    }

    # Default group settings
    group { "$username":
        ensure    => $ensure,
        allowdupe => false,
    }

    # Ordering of dependencies, just in case
    case $ensure {
        present: { User <| title == "$username" |> { require => Group["$username"] } }
        absent: { Group <| title == "$username" |> { require => User["$username"] } }
    }

    # Set password if available
    if $password != '' {
        User <| title == "$username" |> { password => $password }
    }

    # uid/gid management
    if $uid != '' {
        # Manage uid if etcpasswd is available
        if $etcpasswd != '' {
            User <| title == "$username" |> { uid => $uid }
            users::uidsanity { "$uid": username => $username }
        }

        # Manage gid if etcgroup is available
        if $etcgroup != '' {
            User <| title == "$username" |> { gid => $uid }
            Group <| title == "$username" |> { gid => $uid }
            users::gidsanity { "$uid": groupname => $username }
        }
    }

    case $ensure {
        present: {
            if versioncmp($puppetversion, '0.25') >= 0 {
                $managedDirs = [
                    "/etc/puppet/files/users/home/managed/host/${username}.$fqdn",
                    "/etc/puppet/files/users/home/managed/host/${username}.$hostname",
                    "/etc/puppet/files/users/home/managed/domain/${username}.$domain",
                    "/etc/puppet/files/users/home/managed/env/${username}.$environment",
                    "/etc/puppet/files/users/home/managed/user/${username}",
                    "/etc/puppet/files/users/home/managed/skel",
                ]

                case generate('/etc/puppet/modules/users/scripts/findDirs.sh', $managedDirs) {
                    '': {
                        file { "/home/${username}":
                            ensure       => $ensure ? {
                                present => directory,
                                absent  => absent,
                            },
                            owner        => $home_owner,
                            group        => $home_group,
                            #mode        => 644,    # Cannot apply mode, or it will change ALL files
                            recurse      => remote,
                            replace      => false,
                            ignore       => [ '*.git', '*.swp', '*.un~' ],
                            source       => [
                                "puppet:///files/users/home/default/host/${username}.$fqdn",
                                "puppet:///files/users/home/default/host/${username}.$hostname",
                                "puppet:///files/users/home/default/domain/${username}.$domain",
                                "puppet:///files/users/home/default/env/${username}.$environment",
                                "puppet:///files/users/home/default/user/${username}",
                                "puppet:///files/users/home/default/skel",
                                "puppet:///users/home/default",
                            ],
                            sourceselect => all,
                            require      => User["${username}"],
                        }
                    }
                    default: {
                        file { "/home/${username}":
                            ensure       => $ensure ? {
                                present => directory,
                                absent  => absent,
                            },
                            owner        => $home_owner,
                            group        => $home_group,
                            #mode        => 644, # Cannot apply mode, or it will change ALL files
                            recurse      => remote,
                            replace      => true,
                            force        => true,
                            ignore       => '.git',
                            source       => [
                                "puppet:///files/users/home/managed/host/${username}.$fqdn",
                                "puppet:///files/users/home/managed/host/${username}.$hostname",
                                "puppet:///files/users/home/managed/domain/${username}.$domain",
                                "puppet:///files/users/home/managed/env/${username}.$environment",
                                "puppet:///files/users/home/managed/user/${username}",
                                "puppet:///files/users/home/managed/skel",
                            ],
                            sourceselect => all,
                            require      => User["${username}"],
                        }
                    }
                }
            } else {
                file { "/home/${username}":
                    ensure  => $ensure ? {
                        present => directory,
                        absent  => absent,
                    },
                    owner   => $home_owner,
                    group   => $home_group,
                    mode    => 644, # Cannot apply mode, or it will change ALL files
                    require   => User["${username}"],
                }
            }

            file { "/home/${username}/.bash_history":
                mode => 600,
                owner   => $home_owner,
                group   => $home_group,
                require => File["/home/${username}"],
            }

            file { "/home/${username}/.ssh":
                ensure  => directory,
                owner   => $home_owner,
                group   => $home_group,
                mode    => 700,
                require => File["/home/${username}"],
            }
        }
    }
}

# vim modeline - have 'set modeline' and 'syntax on' in your ~/.vimrc.
# vi:syntax=puppet:filetype=puppet:ts=4:et:
