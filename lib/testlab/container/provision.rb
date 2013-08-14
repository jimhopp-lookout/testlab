class TestLab
  class Container

    module Provision

      # Provision the container
      #
      # Attempts to provision the container.  Calls the containers defined
      # provisioners provision methods.
      #
      # @return [Boolean] True if successful.
      def provision
        @ui.logger.debug { "Container Provision: #{self.id} " }

        self.node.alive? or return false

        please_wait(:ui => @ui, :message => format_object_action(self, :provision, :green)) do
          do_provisioner_callbacks(self, :provision, @ui)
        end

        true
      end

      # Deprovision the container
      #
      # Attempts to deprovision the container.  Calls the containers defined
      # provisioners deprovision methods.
      #
      # @return [Boolean] True if successful.
      def deprovision
        @ui.logger.debug { "Container Deprovision: #{self.id} " }

        self.node.alive? or return false

        persistent_operation_check(:deprovision)

        please_wait(:ui => @ui, :message => format_object_action(self, :deprovision, :red)) do
          do_provisioner_callbacks(self, :deprovision, @ui)
        end

        true
      end

    end

  end
end
