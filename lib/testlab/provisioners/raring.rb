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

      # Ubuntu Raring Provisioner Node Setup
      #
      # @param [TestLab::Node] node The node which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def node(node)
        @ui.logger.debug { "Ubuntu Raring Provisioner: Node #{node.id}" }

        bootstrap_template = File.join(TestLab::Provisioner.template_dir, "raring", "bootstrap.erb")
        node.ssh.bootstrap(ZTK::Template.render(bootstrap_template, @config))
      end

    end

  end
end
