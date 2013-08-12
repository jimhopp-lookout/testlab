class TestLab
  class Node

    module Actions

      # Create the node
      def create
        @ui.logger.debug { "Node Create: #{self.id} " }

        (self.state == :not_created) or return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Create', :green)) do
          @provider.create

          do_provisioner_callbacks(self, :create, @ui)
        end

        true
      end

      # Destroy the node
      def destroy
        @ui.logger.debug { "Node Destroy: #{self.id} " }

        (self.state != :not_created) or return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Destroy', :red)) do
          @provider.destroy

          do_provisioner_callbacks(self, :destroy, @ui)
        end

        true
      end

      # Start the node
      def up
        @ui.logger.debug { "Node Up: #{self.id} " }

        (self.state != :running) or return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Up', :green)) do
          @provider.up

          do_provisioner_callbacks(self, :up, @ui)
        end

        true
      end

      # Stop the node
      def down
        @ui.logger.debug { "Node Down: #{self.id} " }

        (self.state == :running) or return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Down', :red)) do
          @provider.down

          do_provisioner_callbacks(self, :down, @ui)
        end

        true
      end

    end

  end
end
