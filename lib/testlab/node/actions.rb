class TestLab
  class Node

    module Actions

      # Create the node
      def create
        @ui.logger.debug { "Node Create: #{self.id} " }

        (self.state != :not_created) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Create', :green)) do
          @provider.create
        end

        true
      end

      # Destroy the node
      def destroy
        @ui.logger.debug { "Node Destroy: #{self.id} " }

        (self.state == :not_created) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Destroy', :red)) do
          @provider.destroy
        end

        true
      end

      # Start the node
      def up
        @ui.logger.debug { "Node Up: #{self.id} " }

        (self.state == :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Up', :green)) do
          @provider.up
        end

        true
      end

      # Stop the node
      def down
        @ui.logger.debug { "Node Down: #{self.id} " }

        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Down', :red)) do
          @provider.down
        end

        true
      end

    end

  end
end
