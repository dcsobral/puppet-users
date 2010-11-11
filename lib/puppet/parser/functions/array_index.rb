module Puppet::Parser::Functions
  newfunction(:array_index, :type => :rvalue) do |args|
    array = args[0]
    index = args[1].to_i
    array[index]
  end
end

