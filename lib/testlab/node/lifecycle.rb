class TestLab
  class Node

    module Lifecycle

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

      # Bounce the node
      def bounce
        self.down
        self.up

        true
      end

    end
  end
end
