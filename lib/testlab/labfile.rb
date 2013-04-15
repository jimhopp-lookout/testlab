class TestLab

  # Labfile Error Class
  class LabfileError < TestLabError; end

  # Labfile Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Labfile < ZTK::DSL::Base
    has_many    :hosts,       :class_name => 'TestLab::Host'

    attribute   :config
  end

end
