class TestLab

  # Interface Error Class
  class InterfaceError < TestLabError; end

  # Interface Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Interface < ZTK::DSL::Base
    # STATUS_KEYS   = %w(node_id id fqdn state distro release interfaces provisioner).map(&:to_sym)

    # Sub-Modules
    # autoload :Actions,       'testlab/interface/actions'
    # autoload :ClassMethods,  'testlab/interface/class_methods'
    # autoload :Generators,    'testlab/interface/generators'
    # autoload :Interface,     'testlab/interface/interface'
    # autoload :Lifecycle,     'testlab/interface/lifecycle'
    # autoload :LXC,           'testlab/interface/lxc'
    # autoload :MethodMissing, 'testlab/interface/method_missing'
    # autoload :Status,        'testlab/interface/status'

    # include TestLab::Interface::Actions
    # include TestLab::Interface::Generators
    # include TestLab::Interface::Interface
    # include TestLab::Interface::Lifecycle
    # include TestLab::Interface::LXC
    # include TestLab::Interface::MethodMissing
    # include TestLab::Interface::Status

    # extend  TestLab::Interface::ClassMethods

    # include TestLab::Utility::Misc

    # Associations and Attributes
    belongs_to  :container, :class_name => 'TestLab::Container'
    belongs_to  :network, :class_name => 'TestLab::Network'

    attribute   :address
    attribute   :mac
    attribute   :name

    attribute   :primary

    def initialize(*args)
      super(*args)

      @ui = TestLab.ui
    end

    def ip
      TestLab::Utility.ip(self.address)
    end

    def cidr
      TestLab::Utility.cidr(self.address)
    end

    def netmask
      TestLab::Utility.netmask(self.address)
    end

  end

end
