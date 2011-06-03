define users::lookupkey($ensure = present) {
    # Waiting for fix #5127
    $data = extlookup("${name}_sshkey")
    $type = array_index($data, "-3")
    $key = array_index($data, "-2")
    $comment = array_index($data, "-1")
    $rest = array_slice($data, 0, "-4")
    $options = array_length($rest) ? {
        0       => absent,
        default => $rest,
    }

    ssh_authorized_key { "${name}_${comment}":
        ensure  => $ensure,
        key     => "$key",
        type    => "$type",
        user    => "$name",
        options => $options,
        target  => "/home/${name}/.ssh/authorized_keys",
        require => [ User["$name"], File["/home/${name}/.ssh"], ],
    }
}

# vi:syntax=puppet:filetype=puppet:ts=4:et:
