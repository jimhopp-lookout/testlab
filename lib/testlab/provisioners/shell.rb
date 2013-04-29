class TestLab

  class Provisioner

    # Shell Provisioner Error Class
    class ShellError < ProvisionerError; end

    # Shell Provisioner Class
    #
    # @author Zachary Patten <zachary@jovelabs.net>
    class Shell

      def initialize(config={}, ui=nil)
        @config   = (config || Hash.new)
        @ui       = (ui || TestLab.ui)
      end

      def setup(container)
      end

      def teardown(container)
      end

    end

  end
end
