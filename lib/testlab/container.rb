class TestLab

  # Container Error Class
  class ContainerError < TestLabError; end

  # Container Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Container < ZTK::DSL::Base
    STATUS_KEYS   = %w(node_id id state distro release interfaces provisioner).map(&:to_sym)

    belongs_to  :node,        :class_name => 'TestLab::Node'

    attribute   :provisioner
    attribute   :config

    attribute   :tld

    attribute   :user
    attribute   :keys

    attribute   :interfaces

    attribute   :distro
    attribute   :release
    attribute   :arch

    attribute   :persist

    autoload :Actions,    'testlab/container/actions'
    autoload :Args,       'testlab/container/args'
    autoload :Detect,     'testlab/container/detect'
    autoload :Generators, 'testlab/container/generators'
    autoload :Lifecycle,  'testlab/container/lifecycle'
    autoload :Network,    'testlab/container/network'
    autoload :Status,     'testlab/container/status'

    include TestLab::Container::Actions
    include TestLab::Container::Args
    include TestLab::Container::Detect
    include TestLab::Container::Generators
    include TestLab::Container::Lifecycle
    include TestLab::Container::Network
    include TestLab::Container::Status

    def initialize(*args)
      super(*args)

      @ui          = TestLab.ui
      @provisioner = self.provisioner.new(self.config) if !self.provisioner.nil?
    end

################################################################################

    # Does the container exist?
    def exists?
      @ui.logger.debug { "Container Exists?: #{self.id} " }

      self.lxc.exists?
    end

################################################################################

    # Our LXC Container class
    def lxc
      @lxc ||= self.node.lxc.container(self.id)
    end

    # SSH to the container
    def ssh(options={})
      self.node.container_ssh(self, options)
    end

    def ip
      self.primary_interface.last[:ip].split('/').first
    end

    def primary_interface
      if self.interfaces.any?{ |i,c| c[:primary] == true }
        self.interfaces.find{ |i,c| c[:primary] == true }
      else
        self.interfaces.first
      end
    end

    class << self

      def tlds
        self.all.map(&:tld).compact
      end

    end

################################################################################

    # Method missing handler
    def method_missing(method_name, *method_args)
      @ui.logger.debug { "CONTAINER METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

      if (defined?(@provisioner) && @provisioner.respond_to?(method_name))
        @provisioner.send(method_name, [self, *method_args].flatten)
      else
        super(method_name, *method_args)
      end
    end

  end

end
