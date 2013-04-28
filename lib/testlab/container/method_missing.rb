class TestLab
  class Container

    module MethodMissing

      # Method missing handler
      def method_missing(method_name, *method_args)
        @ui.logger.debug { "CONTAINER METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

        if (defined?(@provisioner) && @provisioner.respond_to?(method_name))
          @provisioner.send(method_name, [self, *method_args].flatten)
        else
          super(method_name, *method_args)
        end
      end

    end

  end
end
