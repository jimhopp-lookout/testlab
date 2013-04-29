class TestLab
  class Node

    module Lifecycle

      # Iterates an array of arrays calling the specified method on all the
      # collections of objects
      def call_collections(collections, method_name)
        collections.each do |collection|
          call_methods(collection, method_name)
        end
      end

      # Calls the specified method on all the objects supplied
      def call_methods(objects, method_name)
        objects.each do |object|
          if object.respond_to?(method_name)
            object.send(method_name)
          end
        end
      end

      # Bootstrap the node
      def node_setup
        node_setup_template = File.join(self.class.template_dir, 'node-setup.erb')
        self.ssh.bootstrap(ZTK::Template.render(node_setup_template))
      end

      def create
        @provider.create

        true
      end

      def destroy
        @provider.destroy

        true
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

        if self.components.include?('bind')
          bind_reload
        end

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
