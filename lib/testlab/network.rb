class TestLab

  # Network Error Class
  class NetworkError < TestLabError; end

  # Network Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Network < ZTK::DSL::Base
    belongs_to  :lab,         :class_name => 'TestLab::Lab'

    has_many    :containers,  :class_name => 'TestLab::Container'

    attribute   :name
    attribute   :network
    attribute   :netmask
  end

end
