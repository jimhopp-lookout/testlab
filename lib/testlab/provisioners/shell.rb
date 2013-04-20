class TestLab

  class Provisioner

    # Shell Provisioner Error Class
    class ShellError < ProvisionerError; end

    # Shell Provisioner Class
    #
    # @author Zachary Patten <zachary@jovelabs.net>
    class Shell

      def initialize(config={}, ui=nil)
        @config   = config
        @ui       = (ui || TestLab.ui)
      end

    end

  end
end
