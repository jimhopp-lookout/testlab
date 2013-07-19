class TestLab

  class Provisioner

    # Ubuntu Raring Provisioner Error Class
    class RaringError < ProvisionerError; end

    # Ubuntu Raring Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Raring

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        @config[:raring] ||= Hash.new

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # Ubuntu Raring: Node Provision
      #
      # @param [TestLab::Node] node The node which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def on_node_provision(node)
        @ui.logger.debug { "Ubuntu Raring Provisioner: Node #{node.id}" }

        node.ssh.bootstrap(ZTK::Template.render(provision_template, @config))
      end
      alias :on_node_up :on_node_provision

    private

      def provision_template
        File.join(TestLab::Provisioner.template_dir, 'raring', 'provision.erb')
      end

    end

  end
end
