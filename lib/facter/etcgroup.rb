# etcgroup.rb

Facter.add("etcgroup") do
        setcode do
                File.read('/etc/group')
        end
end

