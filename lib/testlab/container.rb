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

    attribute   :user
    attribute   :keys

    attribute   :interfaces

    attribute   :distro
    attribute   :release
    attribute   :arch

    attribute   :persist

    autoload :Actions, 'testlab/container/actions'
    autoload :Args, 'testlab/container/args'
    autoload :Detect, 'testlab/container/detect'
    autoload :Generators, 'testlab/container/generators'
    autoload :Network, 'testlab/container/network'

    include TestLab::Container::Actions
    include TestLab::Container::Args
    include TestLab::Container::Detect
    include TestLab::Container::Generators
    include TestLab::Container::Network

    def initialize(*args)
      super(*args)

      @ui          = TestLab.ui
      @provisioner = self.provisioner.new(self.config) if !self.provisioner.nil?
    end

    def status
      interfaces = self.interfaces.collect{ |network, network_config| "#{network}:#{network_config[:name]}:#{network_config[:ip]}" }.join(', ')

      {
        :id => self.id,
        :state => self.state,
        :distro => self.distro,
        :release => self.release,
        :interfaces => interfaces,
        :provisioner => self.provisioner,
        :node_id => self.node.id
      }
    end

################################################################################

    # State of the container
    def state
      self.lxc.state
    end

################################################################################

    # Does the container exist?
    def exists?
      @ui.logger.debug { "Container Exists?: #{self.id} " }

      self.lxc.exists?
    end

    # Container Setup
    def setup
      @ui.logger.debug { "Container Setup: #{self.id} " }

      self.create
      self.up
    end

    # Container Teardown
    def teardown
      @ui.logger.debug { "Container Teardown: #{self.id} " }

      self.down
      self.destroy
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
      self.interfaces.values.first[:ip].split('/').first
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
