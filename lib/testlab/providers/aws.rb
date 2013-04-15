class TestLab

  class Provider

    # AWS Provider Error Class
    class AWSError < ProviderError; end

    # AWS Provider Class
    #
    # @author Zachary Patten <zachary@jovelabs.net>
    class AWS

      def initialize(ui=ZTK::UI.new)
        @ui = ui
      end

    end

  end
end
