require 'ztk'

require 'testlab/version'

# Top-Level LXC Class
#
# @author Zachary Patten <zachary@jovelabs.net>
class TestLab

  # Top-Level Error Class
  class TestLabError < StandardError; end

  autoload :Provider, 'testlab/provider'
  autoload :Provisioner, 'testlab/provisioner'

  autoload :Container, 'testlab/container'
  autoload :Network, 'testlab/network'

end
