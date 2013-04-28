class TestLab

  # Utility Error Class
  class UtilityError < TestLabError; end

  # Utility Module
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  module Utility
    autoload :CIDR, 'testlab/utility/cidr'

    extend TestLab::Utility::CIDR

  end

end
