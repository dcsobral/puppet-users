module Puppet::Parser::Functions
  newfunction(:array_slice, :type => :rvalue) do |args|
    array = args[0]
    from = args[1].to_i
    to = args[2].to_i
    array[from .. to]
  end
end

