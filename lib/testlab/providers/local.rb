class TestLab

  class Provider

    # Local Provider Error Class
    class LocalError < ProviderError; end

    # Local Provider Class
    #
    # @author Zachary Patten <zachary@jovelabs.net>
    class Local

      def initialize(ui=ZTK::UI.new)
        @ui = ui
      end

    end

  end
end
