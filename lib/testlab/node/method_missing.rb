class TestLab
  class Node

    module MethodMissing

      # Node Method Missing Handler
      def method_missing(method_name, *method_args)
        @ui.logger.debug { "NODE METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

        if TestLab::Provider::PROXY_METHODS.include?(method_name)
          result = nil

          if @provider.respond_to?(method_name)
            @ui.logger.debug { "@provider.send(#{method_name.inspect}, #{method_args.inspect})" }
            result = @provider.send(method_name, *method_args)
          else
            raise TestLab::ProviderError, "Your provider does not respond to the method '#{method_name}'!"
          end

          result
        else
          super(method_name, *method_args)
        end
      end

    end

  end
end
