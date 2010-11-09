# users puppet module #

Manages user configuration.

Supported corrective actions under: Debian.

## Classes ##

    * users

### users ###

Realize all useraccount, massuseraccount and lookup defines tagged with
'administrators'. Also, realize User, Group, File and Exec likewise
tagged, to handle exceptional cases.

## Definitions ##

    * users::account
    * users::gidsanity
    * users::lookup
    * users::massuseraccount
    * users::uidsanity

### users::account ###

Create a user account with a primary group of the same name. If uid is provided and the
client supports the custom facts provided with this module, do some sanity checking
beforehand, moving users and groups with conflicting guids to the same guids + 10000.

Note that just like user name and primary group name are kept the same, uid and gid
are kept equal.

Also copy a tree of files in one of two ways:

1. If there's a "managed" directory from one of the options below, use it and control
file content. The file paths checked for are absolute, so it may need changing if the
default file server path is different. Also, it uses a script at
/etc/puppet/modules/users/scripts to check for these files, which may also need changing
depending on the module path and module name.

    * /etc/puppet/files/users/home/managed/host/${username}.$fqdn
    * /etc/puppet/files/users/home/managed/host/${username}.$hostname
    * /etc/puppet/files/users/home/managed/domain/${username}.$domain
    * /etc/puppet/files/users/home/managed/env/${username}.$environment
    * /etc/puppet/files/users/home/managed/user/${username}
    * /etc/puppet/files/users/home/managed/skel

2. Otherwise, use one of the directories below as a default (modified files do
not get replaced).

    * puppet:///files/users/home/default/host/${username}.$fqdn
    * puppet:///files/users/home/default/host/${username}.$hostname
    * puppet:///files/users/home/default/domain/${username}.$domain
    * puppet:///files/users/home/default/env/${username}.$environment
    * puppet:///files/users/home/default/user/${username}
    * puppet:///files/users/home/default/skel
    * puppet:///files/users/home/default/skel
    * puppet:///users/home/default/skel

In neither case will other files be purged. Also, there is no mode control, though all
files will be created with user and group onwership.

Also ensures that the .ssh directory and .bash_history will be kept with appropriate
permissions.

Example:

    @useracount { "bob":
        ensure   => present,
        uid      => 1000,
        groups   => [ "wheel" ], # Extra groups, defaults to none
        shell    => '/bin/bash', # default value
        password => 'hash',
    }

### users::gidsanity ###

Checks that no other group is using this gid, and, if it is, moves it
up 10000.

Also, if the group exists but doesn't presently have this
gid, pre-emptively change group owner ship of all files in the home
directory with the current gid, so that they'll be correct after the
group id was corrected (elsewhere).

### users::lookup ###

Add a user through extdata lookup. The user is added with the extra
groups provided, but name, uid and password come from the csv file.

Example:

    @users::lookup { 'username':
        ensure => present, # default value
        groups => [], # default value
    }

CSV file:

    username_account,uid,Full Name,hashed password

### users::massuseraccount ###

Adds users through extdata lookup. The users are added with the extra
groups provided, but name, uid and password come from the csv files,
as well as the list of users.

Example:

    @users::massuseraccount { 'group':
        ensure => present, # default value
        groups => [], # default value
    }

CSV file:

    group_accounts,username
    username_account,uid,Full Name,hashed password

### users::uidsanity ###

Checks that no other user is using this uid, and, if it is, moves it
up 10000.

