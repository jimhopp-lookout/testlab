class TestLab

  # Provisioner Error Class
  class ProvisionerError < TestLabError; end

  # Provisioner Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Provisioner

    autoload :Shell, 'testlab/provisioners/shell'
    autoload :Chef, 'testlab/provisioners/chef'

    attr_accessor :provisioner

    def initialize(klass, ui=ZTK::UI.new)
      @ui           = ui
      @provisioner  = klass.new
    end

  end

end
