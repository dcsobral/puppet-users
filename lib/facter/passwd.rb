# passwd.rb

Facter.add("passwd") do
        setcode do
                File.read('/etc/passwd')
        end
end

