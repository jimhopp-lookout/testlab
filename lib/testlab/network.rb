class TestLab

  # Network Error Class
  class NetworkError < TestLabError; end

  # Network Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Network < ZTK::DSL::Base
    STATUS_KEYS   = %w(node_id id state interface network netmask broadcast).map(&:to_sym)

    # Sub-Modules
    autoload :Actions, 'testlab/network/actions'
    autoload :CIDR, 'testlab/network/cidr'
    autoload :Lifecycle, 'testlab/network/lifecycle'
    autoload :Status, 'testlab/network/status'

    include TestLab::Network::Actions
    include TestLab::Network::CIDR
    include TestLab::Network::Lifecycle
    include TestLab::Network::Status

    # Associations and Attributes
    belongs_to  :node,        :class_name => 'TestLab::Node'

    attribute   :bridge

    attribute   :ip
    attribute   :config


    def initialize(*args)
      super(*args)

      @ui = TestLab.ui
    end

  end

end
