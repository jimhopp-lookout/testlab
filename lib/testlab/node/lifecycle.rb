class TestLab
  class Node

    module Lifecycle

      # Setup the node.
      def setup
        @ui.logger.debug { "Node Setup: #{self.id} " }

        bootstrap

        if self.components.include?('resolv')
          build_resolv_conf
        end

        if self.components.include?('dhcpd')
          bind_setup
          dhcpd_setup
        end

        call_collections([self.networks, self.routers, self.containers], :setup)

        true
      end

      # Teardown the node.
      def teardown
        @ui.logger.debug { "Node Teardown: #{self.id} " }

        call_collections([self.containers, self.routers, self.networks], :teardown)

        true
      end

    end

  end
end
