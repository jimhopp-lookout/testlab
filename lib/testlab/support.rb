class TestLab

  # Support Error Class
  class SupportError < TestLabError; end

  # Support Module
  #
  # This module defines our object support namespace.  This namespace should
  # provide modules we can mixin to our various objects (containers, networks,
  # nodes).
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  module Support
    autoload :Execution, 'testlab/support/execution'
    autoload :Lifecycle, 'testlab/support/lifecycle'
  end

end
