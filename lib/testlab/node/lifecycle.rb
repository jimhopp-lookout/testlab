class TestLab
  class Node

    module Lifecycle

      # Provision the node.
      def provision
        @ui.logger.debug { "Node Provision: #{self.id} " }

        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Provision', :green)) do

          self.all_provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NODE PROVISIONER PROVISION: #{provisioner} (#{self.id}) <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_node_provision) and p.on_node_provision(self)
          end

        end

        true
      end

      # Teardown the node.
      def teardown
        @ui.logger.debug { "Node Teardown: #{self.id} " }

        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do

          self.all_provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NODE PROVISIONER TEARDOWN: #{provisioner} (#{self.id}) <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_node_teardown) and p.on_node_teardown(self)
          end

        end

        true
      end

      # Build the node
      def build
        self.create
        self.up
        self.provision

        true
      end

      # Demolish the node
      def demolish
        self.teardown
        self.down
        self.destroy

        true
      end

      # Returns all defined provisioners for this node and it's networks and containers.
      def all_provisioners
        [self.provisioners, self.networks.map(&:provisioners), self.containers.map(&:provisioners)].flatten.compact.uniq
      end

    end
  end
end
