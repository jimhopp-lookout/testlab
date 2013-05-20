class TestLab

  # Container Error Class
  class ContainerError < TestLabError; end

  # Container Class
  #
  # This class represents the TestLab Container DSL object.
  #
  # @example A simple container definition with a single interface:
  #   container "server-west-1" do
  #     domain        "west.zone"
  #
  #     distro        "ubuntu"
  #     release       "precise"
  #
  #     interface do
  #       network_id 'west'
  #       name       :eth0
  #       address    '10.11.0.254/16'
  #       mac        '00:00:5e:48:e9:6f'
  #     end
  #   end
  #
  # @example Multiple interfaces can be defined as well:
  #   container "dual-nic" do
  #     distro        "ubuntu"
  #     release       "precise"
  #
  #     interface do
  #       network_id 'east'
  #       name       :eth0
  #       address    '10.10.0.200/16'
  #       mac        '00:00:5e:63:b5:9f'
  #     end
  #
  #     interface do
  #       network_id 'west'
  #       primary    true
  #       name       :eth1
  #       address    '10.11.0.200/16'
  #       mac        '00:00:5e:08:63:df'
  #     end
  #   end
  #
  # The operating system is determined by the *distro* and *release* attributes.
  # The hostname (container ID) is passed as a parameter to the container call.
  # A *domain* may additionally be specified (overriding the global domain, if
  # set).  If the *domain* attributes is omited, then the global domain is use,
  # again only if it is set.  The hostname (container ID) and the domain will be
  # joined together to form the FQDN of the container.
  #
  # @see TestLab::Interface
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Container < ZTK::DSL::Base

    # An array of symbols of the various keys in our status hash.
    #
    # @see TestLab::Container::Status
    STATUS_KEYS   = %w(node_id id clone fqdn state distro release interfaces provisioner).map(&:to_sym)

    # Sub-Modules
    autoload :Actions,       'testlab/container/actions'
    autoload :ClassMethods,  'testlab/container/class_methods'
    autoload :Generators,    'testlab/container/generators'
    autoload :Interface,     'testlab/container/interface'
    autoload :Lifecycle,     'testlab/container/lifecycle'
    autoload :LXC,           'testlab/container/lxc'
    autoload :MethodMissing, 'testlab/container/method_missing'
    autoload :Status,        'testlab/container/status'

    include TestLab::Container::Actions
    include TestLab::Container::Generators
    include TestLab::Container::Interface
    include TestLab::Container::Lifecycle
    include TestLab::Container::LXC
    include TestLab::Container::MethodMissing
    include TestLab::Container::Status

    extend  TestLab::Container::ClassMethods

    include TestLab::Utility::Misc

    # Associations and Attributes
    belongs_to  :node,        :class_name => 'TestLab::Node'
    has_many    :interfaces,  :class_name => 'TestLab::Interface'

    attribute   :provisioner
    attribute   :config,      :default => Hash.new

    attribute   :domain

    attribute   :user,        :default => 'ubuntu'
    attribute   :passwd,      :default => 'ubuntu'
    attribute   :keys

    attribute   :distro,      :default => 'ubuntu'
    attribute   :release,     :default => 'precise'
    attribute   :arch

    attribute   :persist


    def initialize(*args)
      super(*args)

      @ui          = TestLab.ui
      @provisioner = self.provisioner.new(self.config, @ui) if !self.provisioner.nil?
    end

  end

end
