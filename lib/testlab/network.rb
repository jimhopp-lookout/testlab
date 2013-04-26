class TestLab

  # Network Error Class
  class NetworkError < TestLabError; end

  # Network Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Network < ZTK::DSL::Base
    autoload :CIDR, 'testlab/network/cidr'

    STATUS_KEYS   = %w(node_id id state interface).map(&:to_sym)

    belongs_to  :node,        :class_name => 'TestLab::Node'

    attribute   :bridge

    attribute   :ip
    attribute   :config

    include(TestLab::Network::CIDR)

    def initialize(*args)
      super(*args)

      @ui = TestLab.ui
    end

################################################################################

    # Network status
    def status
      interface = "#{bridge}:#{ip}"
      {
        :id => self.id,
        :node_id => self.node.id,
        :state => self.state,
        :interface => interface
      }
    end

################################################################################

    # State of the network
    def state
      output = self.node.ssh.exec(%(sudo ifconfig #{self.bridge} | grep 'MTU'), :silence => true, :ignore_exit_status => true).output.strip
      if ((output =~ /UP/) && (output =~ /RUNNING/))
        :running
      else
        :stopped
      end
    end

################################################################################

    # Create the network
    def create
      @ui.logger.debug { "Network Create: #{self.id} " }

      self.node.ssh.exec(%(sudo brctl addbr #{self.bridge}), :silence => true, :ignore_exit_status => true)
      self.node.ssh.exec(%(sudo ifconfig #{self.bridge} #{self.ip} down), :silence => true, :ignore_exit_status => true)
    end

    # Destroy the network
    def destroy
      @ui.logger.debug { "Network Destroy: #{self.id} " }

      self.node.ssh.exec(%(sudo brctl delbr #{self.bridge}), :silence => true, :ignore_exit_status => true)
    end

    # Start the network
    def up
      @ui.logger.debug { "Network Up: #{self.id} " }

      self.node.ssh.exec(%(sudo ifconfig #{self.bridge} up), :silence => true, :ignore_exit_status => true)
    end

    # Stop the network
    def down
      @ui.logger.debug { "Network Down: #{self.id} " }

      self.node.ssh.exec(%(sudo ifconfig #{self.bridge} down), :silence => true, :ignore_exit_status => true)
    end

################################################################################

    # Network Setup
    def setup
      @ui.logger.debug { "Network Setup: #{self.id} " }

      self.create
      self.up
    end

    # Network Teardown
    def teardown
      @ui.logger.debug { "Network Teardown: #{self.id} " }

      self.down
      self.destroy
    end

################################################################################

    # Method missing handler
    def method_missing(method_name, *method_args)
      @ui.logger.debug { "NETWORK METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }
      super(method_name, *method_args)
    end

  end

end
