define users::userkey($key, $ensure = present, $type = "ssh-rsa", $comment = "default-key" ) {
                       if ($key != "" ) {
                         ssh_authorized_key { "${title}_${comment}": 
                           ensure  => $ensure,
                           key     => $key,
                           type    => $type,
                           user    => $name,
                           options => $options,
                           require => [ User[$name], File["/home/${name}/.ssh"], ],
                         }
                       }
}
# vi:syntax=puppet:filetype=puppet:ts=4:et:
