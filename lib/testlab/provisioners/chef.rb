class TestLab

  class Provisioner

    # Chef Provisioner Error Class
    class ChefError < ProvisionerError; end

    # Chef Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Chef

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
