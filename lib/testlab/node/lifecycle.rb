class TestLab
  class Node

    module Lifecycle

      # Setup the node.
      def setup
        @ui.logger.debug { "Node Setup: #{self.id} " }

        bootstrap
        build_resolv_conf
        build_bind_conf
        build_dhcpd_conf

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
