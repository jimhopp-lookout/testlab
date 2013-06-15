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
        @config = (config || Hash.new)
        @ui     = (ui || TestLab.ui)
      end

      # Shell Provisioner Container Setup
      #
      # Renders the defined script to a temporary file on the target container
      # and proceeds to execute said script as root via *lxc-attach*.
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def on_container_setup(container)
        if !@config[:script].nil?
          container.bootstrap(@config[:script])
        end

        true
      end

    end

  end
end
