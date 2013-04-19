class TestLab

  # Router Error Class
  class RouterError < TestLabError; end

  # Router Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Router < ZTK::DSL::Base
    belongs_to  :host,        :class_name => 'TestHost::Host'

    attribute   :links
  end

end
