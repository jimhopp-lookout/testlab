class TestLab

  # Labfile Error Class
  class LabfileError < TestLabError; end

  # Labfile Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Labfile < ZTK::DSL::Base
    has_many    :nodes,       :class_name => 'TestLab::Node'

    attribute   :config
  end

end
