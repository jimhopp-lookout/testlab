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

        please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do

          global_provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NODE PROVISIONER SETUP: #{provisioner} <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_node_setup) and p.on_node_setup(self)
          end

        end

        true
      end

      # Teardown the node.
      def teardown
        @ui.logger.debug { "Node Teardown: #{self.id} " }

        (self.state == :not_created) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do

          global_provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NODE PROVISIONER TEARDOWN: #{provisioner} <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_node_teardown) and p.on_node_teardown(self)
          end

        end

        true
      end

      def global_provisioners
        [self.provisioners, self.containers.map(&:provisioners)].flatten.compact.uniq
      end

    end

  end
end
