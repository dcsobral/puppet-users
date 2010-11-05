define users::massuseraccount($ensure = present, $groups = []) {
	$accounts = extlookup("${name}_accounts")
	users::lookup { $accounts:
		ensure => $ensure,
		groups => $groups,
	}
}

