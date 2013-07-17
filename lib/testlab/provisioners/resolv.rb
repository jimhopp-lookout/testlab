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
        @config[:resolv][:servers] ||= [TestLab::Network.ips, '8.8.8.8', '8.8.4.4'].flatten.compact.uniq
        @config[:resolv][:search]  ||= TestLab::Container.domains.join(' ')

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # Resolv: Node Provision
      #
      # @param [TestLab::Node] node The node which we want to provision.
      # @return [Boolean] True if successful.
      def on_node_provision(node)
        @ui.logger.debug { "RESOLV Provisioner: Node #{node.id}" }

        @config[:resolv][:servers] = ['127.0.0.1', '8.8.8.8', '8.8.4.4']

        render_resolv_conf(node)

        true
      end

      # Resolv: Container Provision
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def on_container_provision(container)
        @ui.logger.debug { "RESOLV Provisioner: Container #{container.id}" }

        render_resolv_conf(container)

        true
      end

      def render_resolv_conf(object)
        resolv_conf_template = File.join(TestLab::Provisioner.template_dir, "resolv", "resolv.conf.erb")

        object.ssh.file(:target => %(/etc/resolv.conf), :chown => "root:root") do |file|
          file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} RESOLVER Configuration"))
          file.puts(ZTK::Template.render(resolv_conf_template, @config))
        end
      end

    end

  end
end
