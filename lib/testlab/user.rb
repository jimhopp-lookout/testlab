class TestLab

  # User Error Class
  class UserError < TestLabError; end

  # User Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class User < ZTK::DSL::Base

    # Sub-Modules
    autoload :Actions,       'testlab/user/actions'

    include TestLab::User::Actions

    # Associations and Attributes
    belongs_to  :container,  :class_name => 'TestLab::Container'

    attribute   :user
    attribute   :password
    attribute   :keys
    attribute   :uid
    attribute   :gid

    attribute   :primary,    :default => false

    def initialize(*args)
      super(*args)

      @ui = TestLab.ui
    end

  end

end
