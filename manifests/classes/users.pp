class users {
    # Default way to add administrators
    Users::Useraccount <| tag == 'administrators' |>

    # Also realize users, groups, files and execs tagged with administrators
    User <| tag == 'administrators' |>
    Group <| tag == 'administrators' |>
    File <| tag == 'administrators' |>
    Exec <| tag == 'administrators' |>
}

