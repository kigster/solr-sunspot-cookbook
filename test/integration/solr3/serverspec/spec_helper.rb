require 'serverspec'
require 'pathname'
require 'net/http'
require 'net/smtp'
require 'json'

set :backend, :exec

# Allow chef node attributes to be
# accessed inside of RSpec examples.
module NodeHelpers
  def node
    @node ||= ::JSON.parse(File.read('/tmp/kitchen/cache/node.json'))
  end
end

RSpec.configure do |c|
  c.include NodeHelpers
end
