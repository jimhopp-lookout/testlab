class TestLab

  # Host Error Class
  class HostError < TestLabError; end

  # Host Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Host < ZTK::DSL::Base
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
      @provider = TestLab::Provider.new(self.provider, self.config)
    end

    def method_missing(method_name, *method_args)
      if TestLab::Provider::PROXY_METHODS.include?(method_name.to_s)
        @ui.logger.debug { "Host.#{method_name}" }
        result = @provider.send(method_name.to_sym, *method_args)
        # splat = [method_name, *method_args].flatten.compact
        # @ui.logger.debug { "Host: #{splat.inspect}=#{result.inspect}" }
        result
      else
        super(method_name, *method_args)
      end
    end

  end

end
