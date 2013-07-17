class TestLab

  class Provisioner

    # Shell Provisioner Error Class
    class ShellError < ProvisionerError; end

    # Shell Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Shell
      require 'tempfile'

      def initialize(config={}, ui=nil)
        @ui     = (ui     || TestLab.ui)
        @config = (config || Hash.new)
      end

      # Shell: Container Provision
      #
      # Renders the defined script to a temporary file on the target container
      # and proceeds to execute said script as root via *lxc-attach*.
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def on_container_provision(container)
        @config[:script].nil? and raise ShellError, "You must supply a script to bootstrap!"

        container.bootstrap(@config[:script])

        true
      end

    end

  end
end
