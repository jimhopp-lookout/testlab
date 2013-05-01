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
          # @ui.stdout.puts(format_message(format_object(object, (method_name == :setup ? :green : :red))))

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

      def route_setup(action)
        self.networks.each do |network|
          command = ZTK::Command.new(:silence => true, :ignore_exit_status => true)
          command.exec(%(sudo route #{action} -net #{TestLab::Utility.network(network.ip)} netmask #{TestLab::Utility.netmask(network.ip)} gw #{network.node.ip}))
        end
      end

      # Setup the node.
      def setup
        @ui.logger.debug { "Node Setup: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do

          if (self.route == true)
            route_setup(:add)
          end

          node_setup

          if self.components.include?('resolv')
            build_resolv_conf
          end

          if self.components.include?('bind')
            bind_setup
          end
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

        please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do

          if (self.route == true)
            route_setup(:del)
          end
        end

        true
      end

    end

  end
end
