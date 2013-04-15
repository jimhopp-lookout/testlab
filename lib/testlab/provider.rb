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

    def initialize(klass, ui=ZTK::UI.new)
      @ui       = ui
      @provider = klass.new
    end

  end

end
