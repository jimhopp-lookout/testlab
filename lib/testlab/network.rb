class TestLab

  # Network Error Class
  class NetworkError < TestLabError; end

  # Network Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Network < ZTK::DSL::Base
    STATUS_KEYS   = %w(id node_id state interface network netmask broadcast provisioners).map(&:to_sym)

    # Sub-Modules
    autoload :Actions,      'testlab/network/actions'
    autoload :Bind,         'testlab/network/bind'
    autoload :ClassMethods, 'testlab/network/class_methods'
    autoload :Lifecycle,    'testlab/network/lifecycle'
    autoload :Provision,    'testlab/network/provision'
    autoload :Status,       'testlab/network/status'

    include TestLab::Network::Actions
    include TestLab::Network::Bind
    include TestLab::Network::Lifecycle
    include TestLab::Network::Provision
    include TestLab::Network::Status

    extend  TestLab::Network::ClassMethods

    include TestLab::Utility::Misc

    # Associations and Attributes
    belongs_to  :node,          :class_name => 'TestLab::Node'
    has_many    :interfaces,    :class_name => 'TestLab::Interface'

    attribute   :provisioners,  :default => Array.new
    attribute   :config,        :default => Hash.new

    attribute   :address
    attribute   :bridge


    def initialize(*args)
      @ui     = TestLab.ui

      super(*args)

      @ui.logger.info { "Network '#{self.id}' Loaded" }
    end

  end

end
