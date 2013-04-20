class TestLab

  class Provisioner

    # Chef Provisioner Error Class
    class ChefError < ProvisionerError; end

    # Chef Provisioner Class
    #
    # @author Zachary Patten <zachary@jovelabs.net>
    class Chef

      def initialize(config={}, ui=nil)
        @config   = config
        @ui       = (ui || TestLab.ui)
      end

    end

  end
end
