class TestLab
  module Support

    module Lifecycle

      # Build the object
      def build
        create
        up
        provision

        true
      end

      # Demolish the object
      def demolish
        deprovision
        down
        destroy

        true
      end

      # Recycle the object
      def recycle
        demolish
        build

        true
      end

      # Bounce the object
      def bounce
        down
        up

        true
      end

    end

  end
end
