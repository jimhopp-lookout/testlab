class TestLab

  # Container Error Class
  class ContainerError < TestLabError; end

  # Container Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Container < ZTK::DSL::Base
    STATUS_KEYS   = %w(node_id id fqdn state distro release interfaces provisioner).map(&:to_sym)

    # Sub-Modules
    autoload :Actions,       'testlab/container/actions'
    autoload :ClassMethods,  'testlab/container/class_methods'
    autoload :Generators,    'testlab/container/generators'
    autoload :Interface,     'testlab/container/interface'
    autoload :Lifecycle,     'testlab/container/lifecycle'
    autoload :LXC,           'testlab/container/lxc'
    autoload :MethodMissing, 'testlab/container/method_missing'
    autoload :Status,        'testlab/container/status'

    include TestLab::Container::Actions
    include TestLab::Container::Generators
    include TestLab::Container::Interface
    include TestLab::Container::Lifecycle
    include TestLab::Container::LXC
    include TestLab::Container::MethodMissing
    include TestLab::Container::Status

    extend  TestLab::Container::ClassMethods

    # Associations and Attributes
    belongs_to  :node,        :class_name => 'TestLab::Node'

    attribute   :provisioner
    attribute   :config

    attribute   :domain

    attribute   :user
    attribute   :keys

    attribute   :interfaces

    attribute   :distro
    attribute   :release
    attribute   :arch

    attribute   :persist


    def initialize(*args)
      super(*args)

      @ui          = TestLab.ui
      @provisioner = self.provisioner.new(self.config, @ui) if !self.provisioner.nil?
    end

  end

end
