class TestLab

  # Utility Error Class
  class UtilityError < TestLabError; end

  # Utility Module
  #
  # This provides an interface to our various child utility modules.  We also at
  # times mix those child modules in instead of calling them here.
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  module Utility
    autoload :CIDR,   'testlab/utility/cidr'
    autoload :Logger, 'testlab/utility/logger'
    autoload :Misc,   'testlab/utility/misc'

    extend TestLab::Utility::CIDR
    extend TestLab::Utility::Logger
    extend TestLab::Utility::Misc

  end

end
