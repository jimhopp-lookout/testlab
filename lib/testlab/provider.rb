class TestLab

  # Provider Error Class
  class ProviderError < TestLabError; end

  # Provider Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Provider

    autoload :AWS, 'testlab/providers/aws'
    autoload :Local, 'testlab/providers/local'
    autoload :Vagrant, 'testlab/providers/vagrant'

  end

end
