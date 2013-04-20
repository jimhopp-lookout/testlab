require 'lxc'

class TestLab

  # Node Error Class
  class NodeError < TestLabError; end

  # Node Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Node < ZTK::DSL::Base
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

    # SSH to the Node
    def ssh(options={})
      if (!defined?(@ssh) || @ssh.nil?)
        @ssh ||= ZTK::SSH.new({:ui => @ui, :timeout => 1200}.merge(options))
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
      @arch ||= self.ssh.exec(%(uname -m), :silence => true, :ignore_exit_status => true).output.strip
    end

################################################################################

    # Callback: After Up
    # Ensure our packages are installed.
    def after_up
      self.ssh.exec(%(sudo apt-get -qq -y --force-yes update), :silence => true)
      self.ssh.exec(%(sudo apt-get -qq -y --force-yes install lxc bridge-utils debootstrap yum isc-dhcp-server bind9 ntpdate ntp), :silence => true)
    end

################################################################################

    # Provides a generic interface for triggering our callback framework
    def do_callbacks(action, objects, method_name, *method_args)
      callback_method = "#{action}_#{method_name}".to_sym

      objects.each do |object|
        if object.respond_to?(callback_method)
          object.send(callback_method, *method_args)
        end
      end
    end

    # Provides a generic interface for triggering our callback framework
    def self_callbacks(action, method_name, *method_args)
      callback_method = "#{action}_#{method_name}".to_sym

      if self.respond_to?(callback_method)
        self.send(callback_method, *method_args)
      end
    end

    # Method missing handler
    def method_missing(method_name, *method_args)
      @ui.logger.debug { "NODE METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

      if TestLab::Provider::PROXY_METHODS.include?(method_name)
        result = nil
        object_collections = [self.containers, self.routers, self.networks]

        self_callbacks(:before, method_name, *method_args)

        object_collections.each do |object_collection|
          do_callbacks(:before, object_collection, method_name, *method_args)
        end

        @ui.logger.debug { "method_name == #{method_name.inspect}" }
        if @provider.respond_to?(method_name)
          @ui.logger.debug { "@provider.send(#{method_name.inspect}, #{method_args.inspect})" }
          result = @provider.send(method_name, *method_args)
        else
          raise TestLab::ProviderError, "Your provider does not respond to the method '#{method_name}'!"
        end

        self_callbacks(:after, method_name, *method_args)

        object_collections.reverse.each do |object_collection|
          do_callbacks(:after, object_collection, method_name, *method_args)
        end

        result
      else
        super(method_name, *method_args)
      end
    end

  end

end
