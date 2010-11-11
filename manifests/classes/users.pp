class users {
    # Default ways to add administrators
    Users::Massuseraccount <| tag == 'administrators' |>
    Users::Lookup <| tag == 'administrators' |>
    Users::Useraccount <| tag == 'administrators' |>
    Users::Masskeys <| tag == 'administrators' |>
    Users::Lookupkey <| tag == 'administrators' |>

    # Also realize users, groups, files and execs tagged with administrators
    User <| tag == 'administrators' |>
    Group <| tag == 'administrators' |>
    File <| tag == 'administrators' |>
    Exec <| tag == 'administrators' |>
}

