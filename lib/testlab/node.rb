class TestLab

  # Node Error Class
  class NodeError < TestLabError; end

  # Node Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Node < ZTK::DSL::Base
    belongs_to  :labfile,     :class_name => 'TestLab::Lab'

    has_many    :routers,     :class_name => 'TestLab::Router'
    has_many    :containers,  :class_name => 'TestLab::Container'
    has_many    :networks,    :class_name => 'TestLab::Network'

    attribute   :config
    attribute   :provider

    attribute   :ip
    attribute   :port

    def initialize(*args)
      super(*args)

      @ui       = TestLab.ui
      @provider = self.provider.new(self.config)
    end

    # Provides a generic interface for triggering our callback framework
    def do_callbacks(action, objects, method_name, *method_args)
      callback_method = "#{action}_#{method_name}".to_sym

      objects.each do |object|
        @ui.logger.debug { "Callback Object: #{object.inspect}" }

        if object.respond_to?(callback_method)
          @ui.logger.debug { "Callback Triggered: #{callback_method}" }

          object.send(callback_method, *method_args)
        else
          @ui.logger.debug { "Callback Warning: #{object.class} does not have a '#{callback_method}' method!" }
        end
      end
    end

    def method_missing(method_name, *method_args)
      if TestLab::Provider::PROXY_METHODS.include?(method_name)
        result = nil
        object_collections = [self.containers, self.routers, self.networks]

        object_collections.each do |object_collection|
          do_callbacks(:before, object_collection, method_name, *method_args)
        end

        @ui.logger.debug { "method_name == #{method_name.inspect}" }
        if @provider.respond_to?(method_name)
          @ui.logger.debug { "@provider.send(#{method_name.inspect}, #{method_args.inspect})" }
          result = @provider.send(method_name, *method_args)
        else
          raise TestLab::ProviderError, "Your provider does not respond to the method '#{method_name}'!"
        end

        object_collections.reverse.each do |object_collection|
          do_callbacks(:after, object_collection, method_name, *method_args)
        end

        result
      else
        super(method_name, *method_args)
      end
    end

  end

end
