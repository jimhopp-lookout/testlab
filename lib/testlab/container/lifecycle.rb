class TestLab
  class Container

    module Lifecycle

      # Build the container
      def build
        self.create
        self.up
        self.provision

        true
      end

      # Demolish the container
      def demolish
        self.deprovision
        self.down
        self.destroy

        true
      end

    end

  end
end
