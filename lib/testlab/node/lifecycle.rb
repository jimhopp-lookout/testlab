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

      # Setup the node.
      def setup
        @ui.logger.debug { "Node Setup: #{self.id} " }

        self.create
        self.up

        please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do

          node_setup

          self.provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NODE PROVISIONER: #{provisioner} <<<<<" }
            p = provisioner.new(container.config, @ui)
            p.respond_to?(:node) and p.node(self)
          end

          self.containers.each do |container|
            container.provisioners.each do |provisioner|
              @ui.logger.info { ">>>>> NODE PROVISIONER: #{provisioner} <<<<<" }
              p = provisioner.new(container.config, @ui)
              p.respond_to?(:node) and p.node(self)
            end
          end

        end

        call_collections([self.networks, self.containers], :setup)

        true
      end

      # Teardown the node.
      def teardown
        @ui.logger.debug { "Node Teardown: #{self.id} " }

        call_collections([self.containers.reverse, self.networks.reverse], :teardown)

        please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do
          # NOOP
        end

        self.down
        self.destroy

        true
      end

    end

  end
end
