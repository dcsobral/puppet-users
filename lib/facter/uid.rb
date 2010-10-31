#!/usr/bin/env ruby
## Return the uid of all users 

require 'etc'

Etc.passwd { |u|
    Facter.add("uid_" + u.name) do
        confine :kernel => :linux
        setcode do
            u.uid   
        end     
    end
}
