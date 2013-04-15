class TestLab

  class Provisioner

    # Shell Provisioner Error Class
    class ShellError < ProvisionerError; end

    # Shell Provisioner Class
    #
    # @author Zachary Patten <zachary@jovelabs.net>
    class Shell

      def initialize(ui=ZTK::UI.new)
        @ui = ui
      end

    end

  end
end
