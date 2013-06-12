class TestLab

  class Provisioner

    # Apt Provisioner Error Class
    class AptError < ProvisionerError; end

    # Apt Provisioner Class
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

      # Apt Provisioner Container Setup
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def setup(container)
        @ui.logger.debug { "Apt Provisioner: Container #{container.id}" }

        bootstrap_template = File.join(TestLab::Provisioner.template_dir, "apt", "bootstrap.erb")
        container.ssh.bootstrap(ZTK::Template.render(bootstrap_template, @config))
      end

    end

  end
end
