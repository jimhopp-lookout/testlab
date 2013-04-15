class TestLab

  class Provisioner

    # Chef Provisioner Error Class
    class ChefError < ProvisionerError; end

    # Chef Provisioner Class
    #
    # @author Zachary Patten <zachary@jovelabs.net>
    class Chef

      def initialize(ui=ZTK::UI.new)
        @ui = ui
      end

    end

  end
end
