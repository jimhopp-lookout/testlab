class TestLab

  # Utility Error Class
  class UtilityError < TestLabError; end

  # Utility Module
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  module Utility
    autoload :CIDR, 'testlab/utility/cidr'
    autoload :Misc, 'testlab/utility/misc'

    extend TestLab::Utility::CIDR
    extend TestLab::Utility::Misc

  end

end
