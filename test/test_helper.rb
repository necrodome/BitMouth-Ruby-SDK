require 'test/unit'
require 'fakeweb'
require 'rr'

begin
  require 'redgreen'
rescue LoadError
end

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

class Test::Unit::TestCase
   include RR::Adapters::TestUnit
end
