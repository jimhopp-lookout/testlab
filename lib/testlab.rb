require 'ztk'
require 'active_support/inflector'

require 'testlab/version'
require 'testlab/monkeys'

# TestLab - A framework for building lightweight virtual infrastructure using LXC
#
# The core concept with the TestLab is the *Labfile*.  This file dictates the
# topology of your virtual infrastructure.  With simple commands you can setup
# and teardown this infrastructure on the fly for all sorts of purposes from
# automating infrastructure testing to testing new software to experimenting
# in general where you want to spin up alot of servers but do not want the
# overhead of virtualization.  At it's core TestLab uses Linux Containers (LXC)
# to accomplish this.
#
# @example Sample Labfile:
#   shell_provision_script = <<-EOF
#   set -x
#   apt-get -y update
#   apt-get -y install dnsutils
#   EOF
#
#   config Hash[
#     :domain => "default.zone",
#     :repo => File.join(ENV['HOME'], "code", "personal", "testlab-repo")
#   ]
#
#   node :localhost do
#     components %w(resolv bind)
#     route true
#
#     provider    TestLab::Provider::Vagrant
#     config      Hash[
#       :vagrant => {
#         :id       => "mytestlab-#{ENV['USER']}".downcase,
#         :ip       => "192.168.13.37",
#         :user     => "vagrant",
#         :port     => 22,
#         :cpus     => 8,
#         :memory   => 16384,
#         :box      => 'raring64'
#       }
#     ]
#
#     network :east do
#       address '10.10.0.1/16'
#       bridge  :br0
#     end
#
#     container "server-east-1" do
#       domain        "east.zone"
#
#       distro        "ubuntu"
#       release       "precise"
#
#       provisioner   TestLab::Provisioner::Shell
#       config        Hash[:setup => shell_provision_script]
#
#       interface do
#         name       :eth0
#         network_id :east
#         address    '10.10.0.254/16'
#         mac        '00:00:5e:b7:e5:15'
#       end
#     end
#
#   end
#
# @example TestLab can be instantiated easily:
#   log_file = File.join(Dir.pwd, "testlab.log")
#   logger = ZTK::Logger.new(log_file)
#   ui = ZTK::UI.new(:logger => logger)
#   testlab = TestLab.new(:ui => ui)
#
# @example We can control things via code easily as well:
#   testlab.create   # creates the lab
#   testlab.up       # ensures the lab is up and running
#   testlab.setup    # setup the lab, creating all networks and containers
#   testlab.teardown # teardown the lab, destroy all networks and containers
#
# @author Zachary Patten <zachary AT jovelabs DOT com>
class TestLab

  # TestLab Error Class
  class TestLabError < StandardError; end

  # Main Classes
  autoload :Container,   'testlab/container'
  autoload :Interface,   'testlab/interface'
  autoload :Labfile,     'testlab/labfile'
  autoload :Network,     'testlab/network'
  autoload :Node,        'testlab/node'
  autoload :Provider,    'testlab/provider'
  autoload :Provisioner, 'testlab/provisioner'
  autoload :User,        'testlab/user'
  autoload :Utility,     'testlab/utility'

  include TestLab::Utility::Misc

  def initialize(options={})
    self.ui      = (options[:ui] || ZTK::UI.new)

    labfile      = (options[:labfile] || 'Labfile')
    labfile_path = ZTK::Locator.find(labfile)
    @labfile     = TestLab::Labfile.load(labfile_path)
    @labfile.config.merge!(:testlab => self)
  end

  # Test Lab Nodes
  #
  # Returns an array of our defined nodes.
  #
  # @return [Array<TestLab::Node>] An array of all defined nodes.
  def nodes
    TestLab::Node.all
  end

  # Test Lab Containers
  #
  # Returns an array of our defined containers.
  #
  # @return [Array<TestLab::Container>] An array of all defined containers.
  def containers
    TestLab::Container.all
  end

  # Test Lab Networks
  #
  # Returns an array of our defined networks.
  #
  # @return [Array<TestLab::Network>] An array of all defined networks.
  def networks
    TestLab::Network.all
  end

  # Test Lab Configuration
  #
  # The hash defined in our *Labfile* DSL object which represents any high-level
  # lab configuration options.
  #
  # @return [Hash] A hash representing the labs configuration options.
  def config
    @labfile.config
  end

  # Test Lab Alive?
  #
  # Are all of our nodes up and running?
  #
  # @return [Boolean] True if all nodes are running; false otherwise.
  def alive?
    nodes.map(&:state).all?{ |state| state == :running }
  end

  # Test Lab Dead?
  #
  # Are any of our nodes not up and running?
  #
  # @return [Boolean] False is all nodes are running; true otherwise.
  def dead?
    !alive?
  end

  # Test Lab Up
  #
  # Attempts to up our lab topology.  This calls the up method on all of
  # our nodes.
  #
  # @return [Boolean] True if successful.
  def up
    method_proxy(:up)

    true
  end

  # Test Lab Down
  #
  # Attempts to down our lab topology.  This calls the down method on all of
  # our nodes.
  #
  # @return [Boolean] True if successful.
  def down
    reverse_method_proxy(:down)

    true
  end

  # Test Lab Setup
  #
  # Attempts to setup our lab topology.  This calls the setup method on all of
  # our nodes.
  #
  # @return [Boolean] True if successful.
  def setup
    method_proxy(:setup)

    true
  end

  # Test Lab Teardown
  #
  # Attempts to tearddown our lab topology.  This calls the teardown method on
  # all of our nodes.
  #
  # @return [Boolean] True if successful.
  def teardown
    reverse_method_proxy(:teardown)

    true
  end

  # Test Lab Build
  #
  # Attempts to build our lab topology.  This calls various methods on
  # all of our nodes, networks and containers.
  #
  # @return [Boolean] True if successful.
  def build
    nodes.each do |node|
      node.create
      node.up
      node.setup

      node.networks.each do |network|
        network.create
        network.up
        network.setup
      end

      node.containers.each do |container|
        container.create
        container.up
        container.setup
      end
    end

    true
  end

  # Node Method Proxy
  #
  # Iterates all of the lab nodes, sending the supplied method name and arguments
  # to each node.
  #
  # @return [Boolean] True if successful.
  def node_method_proxy(method_name, *method_args)
    nodes.each do |node|
      node.send(method_name.to_sym, *method_args)
    end

    true
  end

  # Method Proxy
  #
  # Iterates all of the lab objects sending the supplied method name and
  # arguments to each object.
  #
  # @return [Boolean] True if successful.
  def method_proxy(method_name, *method_args)
    nodes.each do |node|
      node.send(method_name, *method_args)
      node.networks.each do |network|
        network.send(method_name, *method_args)
      end
      node.containers.each do |container|
        container.send(method_name, *method_args)
      end
    end
  end

  # Reverse Method Proxy
  #
  # Iterates all of the lab objects sending the supplied method name and
  # arguments to each object.
  #
  # @return [Boolean] True if successful.
  def reverse_method_proxy(method_name, *method_args)
    nodes.reverse.each do |node|
      node.containers.reverse.each do |container|
        container.send(method_name, *method_args)
      end
      node.networks.reverse.each do |network|
        network.send(method_name, *method_args)
      end
      node.send(method_name, *method_args)
    end
  end

  # TestLab Configuration Directory
  #
  # Returns the path to the test lab configuration directory which is located
  # off the repo directory under '.testlab'.
  #
  # @return [String] The path to the TestLab configuration directory.
  def config_dir
    directory = File.join(self.config[:repo], '.testlab')
    File.expand_path(directory, File.dirname(__FILE__))
  end

  # Provider Method Handler
  #
  # Proxies missing provider method calls to all nodes.
  #
  # @see TestLab::Provider::PROXY_METHODS
  def method_missing(method_name, *method_args)
    self.ui.logger.debug { "TESTLAB METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

    if TestLab::Provider::PROXY_METHODS.include?(method_name)
      node_method_proxy(method_name, *method_args)
    else
      super(method_name, *method_args)
    end
  end

  # Test Lab Class Methods
  #
  # These are special methods that we both include and extend on the parent
  # class.
  module DualMethods

    @@ui = nil

    # Get Test Lab User Interface
    #
    # Returns the instance of ZTK:UI the lab is using for its user interface.
    #
    # @return [ZTK::UI] Our user interface instance of ZTK::UI.
    def ui
      @@ui ||= ZTK::UI.new
    end

    # Set Test Lab User Interface
    #
    # Sets the instance of ZTK::UI the lab will use for its user interface.
    #
    # @param [ZTK:UI] value The instance of ZTK::UI to use for the labs user
    #   interface.
    #
    # @return [ZTK::UI]
    def ui=(value)
      @@ui = value
      value
    end

    # Test Lab Gem Directory
    #
    # Returns the directory path to where the gem is installed.
    #
    # @return [String] The directory path to the gem installation.
    def gem_dir
      directory = File.join(File.dirname(__FILE__), "..")
      File.expand_path(directory, File.dirname(__FILE__))
    end

    # Build Command Line
    #
    # Attempts to build a command line to a binary for us.  We use ZTK::Locator
    # to attempt to determine if we are using bundler binstubs; otherwise we
    # simply rely on */bin/env* to find the executable for us via the
    # *PATH* environment variable.
    #
    # @return [String] Constructed command line with arguments.
    def build_command_line(name, *args)
      executable = (ZTK::Locator.find('bin', name) rescue "/usr/bin/env #{name}")
      [executable, args].flatten.compact.join(' ')
    end

  end

  extend  TestLab::DualMethods
  include TestLab::DualMethods

end
