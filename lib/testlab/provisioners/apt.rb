class TestLab

  class Provisioner

    # APT Provisioner Error Class
    class AptError < ProvisionerError; end

    # APT Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Apt

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        @config[:apt] ||= Hash.new
        @config[:apt][:install] ||= Array.new
        @config[:apt][:remove]  ||= Array.new

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # APT: Container Provision
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def on_container_provision(container)
        @ui.logger.debug { "APT Provisioner: Container #{container.id}" }

        container.ssh.bootstrap(ZTK::Template.render(provision_template, @config))
      end

    private

      def provision_template
        File.join(TestLab::Provisioner.template_dir, 'apt', 'provision.erb')
      end

    end

  end
end
