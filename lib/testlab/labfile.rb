class TestLab

  # Labfile Error Class
  class LabfileError < TestLabError; end

  # Labfile Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Labfile < ZTK::DSL::Base
    has_many :labs, :class_name => 'TestLab::Lab'
  end

end
