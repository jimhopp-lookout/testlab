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

        self.create
        self.up

        please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do

          global_provisioners = [self.provisioners, self.containers.map(&:provisioners)].flatten.compact.uniq

          global_provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NODE PROVISIONER: #{provisioner} <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:node) and p.node(self)
          end

        end

        true
      end

      # Teardown the node.
      def teardown
        @ui.logger.debug { "Node Teardown: #{self.id} " }

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
