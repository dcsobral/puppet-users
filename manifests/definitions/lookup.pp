define users::lookup($ensure = present, $groups = []) {
    # Waiting for fix #5127
    $data = extlookup("${name}_account")
    $uid = array_index($data, 0)
    $fullname = array_index($data, 1)
    $password = array_index($data, 2)

    users::useraccount { "$name":
            ensure   => $ensure,
            fullname => $fullname,
            uid      => $uid,
            groups   => $groups,
            password => $password,
    }
}

