class TestLab

  # Container Error Class
  class ContainerError < TestLabError; end

  # Container Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Container < ZTK::DSL::Base
    STATUS_KEYS   = %w(node_id id fqdn state distro release interfaces provisioner).map(&:to_sym)

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


    autoload :Actions,    'testlab/container/actions'
    autoload :Generators, 'testlab/container/generators'
    autoload :Lifecycle,  'testlab/container/lifecycle'
    autoload :LXC,        'testlab/container/lxc'
    autoload :Network,    'testlab/container/network'
    autoload :Status,     'testlab/container/status'

    include TestLab::Container::Actions
    include TestLab::Container::Generators
    include TestLab::Container::Lifecycle
    include TestLab::Container::LXC
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

    # SSH to the container
    def ssh(options={})
      self.node.container_ssh(self, options)
    end

    def ip
      self.primary_interface.last[:ip].split('/').first
    end

    # Returns the CIDR of the container
    def cidr
      self.primary_interface.last[:ip].split('/').last.to_i
    end

    def ptr
      octets = self.ip.split('.')

      result = case self.cidr
      when 0..7 then
        octets[-4,4]
      when 8..15 then
        octets[-3,3]
      when 16..23 then
        octets[-2,2]
      when 24..31 then
        octets[-1,1]
      end

      result.reverse.join('.')
    end

    def primary_interface
      if self.interfaces.any?{ |i,c| c[:primary] == true }
        self.interfaces.find{ |i,c| c[:primary] == true }
      else
        self.interfaces.first
      end
    end

    class << self

      def domains
        self.all.map(&:domain).compact
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
