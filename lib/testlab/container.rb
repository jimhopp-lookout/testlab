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
  #     user do
  #       username "deployer"
  #       password "deployer"
  #       uid 2600
  #       gid 2600
  #     end
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
  #     user do
  #       username "deployer"
  #       password "deployer"
  #       uid 2600
  #       gid 2600
  #     end
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
    STATUS_KEYS   = %w(id node_id clone fqdn state distro release interfaces provisioners).map(&:to_sym)

    # Sub-Modules
    autoload :Actions,       'testlab/container/actions'
    autoload :ClassMethods,  'testlab/container/class_methods'
    autoload :Execution,     'testlab/container/execution'
    autoload :Generators,    'testlab/container/generators'
    autoload :Interface,     'testlab/container/interface'
    autoload :IO,            'testlab/container/io'
    autoload :Lifecycle,     'testlab/container/lifecycle'
    autoload :LXC,           'testlab/container/lxc'
    autoload :MethodMissing, 'testlab/container/method_missing'
    autoload :SSH,           'testlab/container/ssh'
    autoload :Status,        'testlab/container/status'
    autoload :User,          'testlab/container/user'

    include TestLab::Container::Actions
    include TestLab::Container::Execution
    include TestLab::Container::Generators
    include TestLab::Container::Interface
    include TestLab::Container::IO
    include TestLab::Container::Lifecycle
    include TestLab::Container::LXC
    include TestLab::Container::MethodMissing
    include TestLab::Container::SSH
    include TestLab::Container::Status
    include TestLab::Container::User

    extend  TestLab::Container::ClassMethods

    include TestLab::Utility::Misc

    # Associations and Attributes
    belongs_to  :node,          :class_name => 'TestLab::Node'
    has_many    :interfaces,    :class_name => 'TestLab::Interface'
    has_many    :users,         :class_name => 'TestLab::User'

    attribute   :provisioners,  :default => Array.new
    attribute   :config,        :default => Hash.new

    attribute   :domain

    attribute   :distro,        :default => 'ubuntu'
    attribute   :release,       :default => 'precise'
    attribute   :arch

    # Instructs ephemeral containers to persist; otherwise tmpfs will be used
    # as the backend store for ephemeral containers.
    # NOTE: tmpfs is very memory intensive and is disabled by default.
    attribute   :persist,       :default => true


    def initialize(*args)
      @ui          = TestLab.ui

      super(*args)

      @ui.logger.info { "Container '#{self.id}' Loaded" }
    end

    def config_dir
      self.node.config_dir
    end

    def repo_dir
      self.node.repo_dir
    end

  end

end
