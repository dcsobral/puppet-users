## Return the gid of a group 

require 'etc'

Etc.group { |g|
    Facter.add("gid_" + g.name) do
        confine :kernel => :linux
        setcode do
            g.gid   
        end     
    end
}
