class TestLab

  # Lab Error Class
  class LabError < TestLabError; end

  # Lab Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Lab < ZTK::DSL::Base
    belongs_to  :labfile,     :class_name => 'TestLab::Labfile'

    has_many    :containers,  :class_name => 'TestLab::Container'
    has_many    :networks,    :class_name => 'TestLab::Network'

    attribute   :provider
    attribute   :provisioner
  end

end
