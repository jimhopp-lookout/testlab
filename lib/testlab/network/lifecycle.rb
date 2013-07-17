class TestLab
  class Network

    module Lifecycle

      # Network Provision
      def provision
        @ui.logger.debug { "Network Provision: #{self.id} " }

        (self.node.state != :running) and return false
        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Provision', :green)) do

          self.network_provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NETWORK PROVISIONER: #{provisioner} (#{self.bridge}) <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_network_provision) and p.on_network_provision(self)
          end

        end

        true
      end

      # Network Teardown
      def teardown
        @ui.logger.debug { "Network Teardown: #{self.id} " }

        (self.node.state != :running) and return false
        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do

          self.network_provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NETWORK PROVISIONER TEARDOWN: #{provisioner} (#{self.bridge}) <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_network_teardown) and p.on_network_teardown(self)
          end

        end

        true
      end

      # Build the network
      def build
        self.create
        self.up
        self.provision

        true
      end

      # Demolish the network
      def demolish
        self.teardown
        self.down
        self.destroy

        true
      end

      # Returns all defined provisioners for this network's containers and the network iteself.
      def network_provisioners
        [self.node.provisioners, self.provisioners, self.interfaces.map(&:container).map(&:provisioners)].flatten.compact.uniq
      end

    end

  end
end
