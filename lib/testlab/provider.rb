class TestLab

  # Provider Error Class
  class ProviderError < TestLabError; end

  # Provider Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Provider
    PROXY_METHODS = %w(create destroy up down reload status id state username ip port alive? dead? exists?)

    autoload :AWS, 'testlab/providers/aws'
    autoload :Local, 'testlab/providers/local'
    autoload :Vagrant, 'testlab/providers/vagrant'

    attr_accessor :provider

    def initialize(klass, config={}, ui=nil)
      @ui       = (ui || TestLab.ui)

      @config   = config
      @provider = klass.new(@config, @ui)
    end

    def method_missing(method_name, *method_args)
      if TestLab::Provider::PROXY_METHODS.include?(method_name.to_s)
        @ui.logger.debug { "Provider.#{method_name}" }
        result = @provider.send(method_name.to_sym, *method_args)
        # splat = [method_name, *method_args].flatten.compact
        # @ui.logger.debug { "Provider: #{splat.inspect}=#{result.inspect}" }
        result
      else
        super(method_name, *method_args)
      end
    end

  end

end
