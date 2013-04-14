class TestLab

  # Provisioner Error Class
  class ProvisionerError < TestLabError; end

  # Provisioner Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Provisioner

    autoload :Shell, 'testlab/provisioners/shell'
    autoload :Chef, 'testlab/provisioners/chef'

  end

end
