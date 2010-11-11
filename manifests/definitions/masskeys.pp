define users::masskeys($ensure = present) {
        $accounts = extlookup("${name}_sshkeys")
        users::lookupkey { $accounts:
                ensure => $ensure,
        }
}

