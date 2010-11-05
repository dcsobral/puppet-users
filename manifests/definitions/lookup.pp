define users::lookup($ensure = present, $groups = []) {
    # Waiting for fix #5127
    $data = extlookup("${name}_account")
    $uid = inline_template("<%= data[0] %>") # $data[0]
    $fullname = inline_template("<%= data[1] %>") # $data[1]
    $password = inline_template("<%= data[2] %>") # $data[2]

    users::useraccount { "$name":
            ensure   => $ensure,
            fullname => $fullname,
            uid      => $uid,
            groups   => $groups,
            password => $password,
    }
}

