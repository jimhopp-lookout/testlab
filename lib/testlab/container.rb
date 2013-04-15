class TestLab

  # Container Error Class
  class ContainerError < TestLabError; end

  # Container Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Container < ZTK::DSL::Base
    belongs_to  :lab,         :class_name => 'TestLab::Lab'
    belongs_to  :network,     :class_name => 'TestLab::Network'

    attribute   :name
    attribute   :ip
    attribute   :mac
    attribute   :persist
    attribute   :distro
    attribute   :release
    attribute   :arch

    attribute   :provider
    attribute   :provisioner
  end

end
