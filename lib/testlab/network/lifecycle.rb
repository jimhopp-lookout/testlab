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

    end

  end
end
