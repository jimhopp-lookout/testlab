class TestLab
  class Network

    module Provision

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

    end

  end
end
