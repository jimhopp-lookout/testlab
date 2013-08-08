class TestLab

  class Provisioner

    # Resolv Provisioner Error Class
    class ResolvError < ProvisionerError; end

    # Resolv Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Resolv

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        @config[:resolv] ||= Hash.new

        @config[:resolv][:servers] ||= Array.new
        @config[:resolv][:servers].unshift([TestLab::Network.ips]).flatten!.compact!

        @config[:resolv][:search] ||= Array.new
        @config[:resolv][:search].unshift([TestLab::Container.domains]).flatten!.compact!

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # Resolv: Node Provision
      #
      # @param [TestLab::Node] node The node which we want to provision.
      # @return [Boolean] True if successful.
      def on_node_provision(node)
        @ui.logger.debug { "RESOLV Provisioner: Node #{node.id}" }

        @config[:resolv].merge!(
          :servers => %w(127.0.0.1),
          :object => :node
        )

        node.bootstrap(ZTK::Template.render(provision_template, @config))

        true
      end
      alias :on_node_up :on_node_provision

      # Resolv: Container Provision
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def on_container_provision(container)
        @ui.logger.debug { "RESOLV Provisioner: Container #{container.id}" }

        @config[:resolv].merge!(
          :object => :container
        )

        container.bootstrap(ZTK::Template.render(provision_template, @config))

        true
      end

    private

      def provision_template
        File.join(TestLab::Provisioner.template_dir, 'resolv', 'provision.erb')
      end

    end

  end
end
