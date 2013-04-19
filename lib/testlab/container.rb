class TestLab

  # Container Error Class
  class ContainerError < TestLabError; end

  # Container Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Container < ZTK::DSL::Base
    belongs_to  :host,        :class_name => 'TestHost::Host'
    # belongs_to  :network,     :class_name => 'TestLab::Network'
    attribute   :links

    attribute   :config
    attribute   :provisioner

    attribute   :name
    attribute   :ip
    attribute   :mac
    attribute   :persist
    attribute   :distro
    attribute   :release
    attribute   :arch
  end

end
