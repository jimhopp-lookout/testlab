class TestLab
  class Network

    module Lifecycle

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

      # Bounce the network
      def bounce
        self.down
        self.up

        true
      end

    end

  end
end
