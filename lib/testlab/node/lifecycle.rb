class TestLab
  class Node

    module Lifecycle

      # Bootstrap the node
      def node_setup
        node_setup_template = File.join(self.class.template_dir, 'node-setup.erb')
        self.ssh.bootstrap(ZTK::Template.render(node_setup_template))
      end

      # Setup the node.
      def setup
        @ui.logger.debug { "Node Setup: #{self.id} " }

        node_setup

        if self.components.include?('resolv')
          build_resolv_conf
        end

        if self.components.include?('bind')
          bind_setup
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
