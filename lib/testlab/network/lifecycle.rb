class TestLab
  class Network

    module Lifecycle

      # Network Provision
      def provision
        @ui.logger.debug { "Network Provision: #{self.id} " }

        (self.node.state != :running) and return false
        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Provision', :green)) do
          do_provisioner_callbacks(self, :provision, @ui)
        end

        true
      end

      # Network Deprovision
      def deprovision
        @ui.logger.debug { "Network Deprovision: #{self.id} " }

        (self.node.state != :running) and return false
        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Deprovision', :red)) do
          do_provisioner_callbacks(self, :deprovision, @ui)
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
        self.deprovision
        self.down
        self.destroy

        true
      end

    end

  end
end
