class TestLab
  class Node

    module Lifecycle

      # Provision the node.
      def provision
        @ui.logger.debug { "Node Provision: #{self.id} " }

        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Provision', :green)) do
          do_provisioner_callbacks(self, :provision, @ui)
        end

        true
      end

      # Deprovision the node.
      def deprovision
        @ui.logger.debug { "Node Deprovision: #{self.id} " }

        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Deprovision', :red)) do
          do_provisioner_callbacks(self, :deprovision, @ui)
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
        self.deprovision
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
