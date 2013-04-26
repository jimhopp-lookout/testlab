require 'lxc'

class TestLab

  # Node Error Class
  class NodeError < TestLabError; end

  # Node Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Node < ZTK::DSL::Base
    STATUS_KEYS   = %w(id instance_id state user ip port provider con net rtr).map(&:to_sym)

    belongs_to :labfile,    :class_name => 'TestLab::Lab'

    has_many   :routers,    :class_name => 'TestLab::Router'
    has_many   :containers, :class_name => 'TestLab::Container'
    has_many   :networks,   :class_name => 'TestLab::Network'

    attribute  :provider
    attribute  :config

    def initialize(*args)
      super(*args)

      @ui       = TestLab.ui
      @provider = self.provider.new(self.config)
    end

    def status
      {
        :instance_id => @provider.instance_id,
        :state => @provider.state,
        :user => @provider.user,
        :ip => @provider.ip,
        :port => @provider.port,
        :provider => @provider.class,
        :con => self.containers.count,
        :net => self.networks.count,
        :rtr => self.routers.count
      }
    end

    # SSH to the Node
    def ssh(options={})
      if (!defined?(@ssh) || @ssh.nil?)
        @ssh ||= ZTK::SSH.new({:ui => @ui, :timeout => 1200, :silence => true}.merge(options))
        @ssh.config do |c|
          c.host_name = @provider.ip
          c.user      = @provider.user
          c.keys      = @provider.identity
        end
      end
      @ssh
    end

    # SSH to a container running on the Node
    def ssh_container(id, options={})
    end

    # Returns the LXC object for this Node
    #
    # This object is used to control containers on the node via it's provider
    def lxc(options={})
      if (!defined?(@lxc) || @lxc.nil?)
        @lxc ||= LXC.new
        @lxc.use_sudo = true
        @lxc.use_ssh = self.ssh
      end
      @lxc
    end

    def arch
      @arch ||= self.ssh.exec(%(uname -m)).output.strip
    end

################################################################################

    # Setup the node.
    def setup
      self.ssh.exec(%(sudo apt-get -qq -y --force-yes update))
      self.ssh.exec(%(sudo apt-get -qq -y --force-yes install lxc bridge-utils debootstrap yum isc-dhcp-server bind9 ntpdate ntp))

      call_collections([self.networks, self.routers, self.containers], :setup)

      true
    end

    # Teardown the node.
    def teardown
      call_collections([self.containers, self.routers, self.networks], :teardown)

      true
    end

################################################################################

    # Iterates an array of arrays calling the specified method on all the
    # collections of objects
    def call_collections(collections, method_name)
      collections.each do |collection|
        call_methods(collection, method_name)
      end
    end

    # Calls the specified method on all the objects supplied
    def call_methods(objects, method_name)
      objects.each do |object|
        if object.respond_to?(method_name)
          object.send(method_name)
        end
      end
    end

    # Method missing handler
    def method_missing(method_name, *method_args)
      @ui.logger.debug { "NODE METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

      if TestLab::Provider::PROXY_METHODS.include?(method_name)
        result = nil

        if @provider.respond_to?(method_name)
          @ui.logger.debug { "@provider.send(#{method_name.inspect}, #{method_args.inspect})" }
          result = @provider.send(method_name, *method_args)
        else
          raise TestLab::ProviderError, "Your provider does not respond to the method '#{method_name}'!"
        end

        result
      else
        super(method_name, *method_args)
      end
    end

  end

end
