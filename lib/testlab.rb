require 'ztk'

require 'testlab/version'

# Monkey Patch the String class so we can have some easy ANSI methods
class String
  include ZTK::ANSI
end

# Top-Level LXC Class
#
# @author Zachary Patten <zachary@jovelabs.net>
class TestLab

  # Top-Level Error Class
  class TestLabError < StandardError; end

  # Main Classes
  autoload :Container,   'testlab/container'
  autoload :Interface,   'testlab/interface'
  autoload :Labfile,     'testlab/labfile'
  autoload :Network,     'testlab/network'
  autoload :Node,        'testlab/node'
  autoload :Provider,    'testlab/provider'
  autoload :Provisioner, 'testlab/provisioner'
  autoload :Router,      'testlab/router'
  autoload :Utility,     'testlab/utility'

  include TestLab::Utility::Misc

  @@ui ||= nil

  def initialize(options={})
    labfile      = (options[:labfile] || 'Labfile')
    labfile_path = ZTK::Locator.find(labfile)

    @@ui         = (options[:ui] || ZTK::UI.new)

    @labfile     = TestLab::Labfile.load(labfile_path)
  end

  def nodes
    TestLab::Node.all
  end

  def containers
    TestLab::Container.all
  end

  def networks
    TestLab::Network.all
  end

  # def config
  #   @labfile.config
  # end

  def alive?
    nodes.map(&:state).all?{ |state| state == :running }
  end

  def dead?
    !alive?
  end

  def status
    if alive?
      %w(nodes networks containers).map(&:to_sym).each do |object_symbol|
        @@ui.stdout.puts
        @@ui.stdout.puts("#{object_symbol}:".upcase.green.bold)

        klass = object_symbol.to_s.singularize.capitalize
        status_keys = "TestLab::#{klass}::STATUS_KEYS".constantize

        ZTK::Report.new(:ui => @@ui).spreadsheet(self.send(object_symbol), status_keys) do |object|
          OpenStruct.new(object.status)
        end
      end

      true
    else
      @@ui.stdout.puts("Looks like your test lab is dead; fix this and try again.")

      false
    end
  end

  def setup
    self.dead? and raise TestLabError, "You must have a running node in order to setup your infrastructure!"

    node_method_proxy(:setup)
  end

  def teardown
    self.dead? and raise TestLabError, "You must have a running node in order to teardown your infrastructure!"

    node_method_proxy(:teardown)
  end

  # Proxy various method calls to our subordinate classes
  def node_method_proxy(method_name, *method_args)
    TestLab::Node.all.map do |node|
      node.send(method_name.to_sym, *method_args)
    end
  end

  # Method missing handler
  def method_missing(method_name, *method_args)
    @@ui.logger.debug { "TESTLAB METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

    if TestLab::Provider::PROXY_METHODS.include?(method_name) # || %w(setup teardown).map(&:to_sym).include?(method_name))
      node_method_proxy(method_name, *method_args)
    else
      super(method_name, *method_args)
    end
  end

  def ui
    @@ui ||= ZTK::UI.new
  end

  # Class Helpers
  class << self

    def ui
      @@ui ||= ZTK::UI.new
    end

    def gem_dir
      directory = File.join(File.dirname(__FILE__), "..")
      File.expand_path(directory, File.dirname(__FILE__))
    end

    def build_command(name, *args)
      executable = (ZTK::Locator.find('bin', name) rescue "/bin/env #{name}")
      [executable, args].flatten.compact.join(' ')
    end

  end

end
