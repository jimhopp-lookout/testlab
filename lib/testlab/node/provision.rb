class TestLab
  class Node

    module Provision

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

    end
  end
end
