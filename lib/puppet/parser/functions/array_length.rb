module Puppet::Parser::Functions
  newfunction(:array_length, :type => :rvalue) do |args|
    array = args[0]
    array.length
  end
end

