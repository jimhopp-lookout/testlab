class TestLab

  # Interface Error Class
  class InterfaceError < TestLabError; end

  # Interface Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Interface < ZTK::DSL::Base

    # Associations and Attributes
    belongs_to  :container, :class_name => 'TestLab::Container'
    belongs_to  :network, :class_name => 'TestLab::Network'

    attribute   :address
    attribute   :mac
    attribute   :name

    attribute   :primary

    def initialize(*args)
      super(*args)

      @ui = TestLab.ui
    end

    def ip
      TestLab::Utility.ip(self.address)
    end

    def cidr
      TestLab::Utility.cidr(self.address)
    end

    def netmask
      TestLab::Utility.netmask(self.address)
    end

    def ptr
      TestLab::Utility.ptr(self.address)
    end

  end

end
