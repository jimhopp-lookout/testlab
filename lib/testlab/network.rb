class TestLab

  # Network Error Class
  class NetworkError < TestLabError; end

  # Network Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Network < ZTK::DSL::Base
    belongs_to  :host,        :class_name => 'TestLab::Host'

    has_many    :containers,  :class_name => 'TestLab::Container'

    attribute   :netaddr
    attribute   :netmask

    attribute   :config
  end

end
