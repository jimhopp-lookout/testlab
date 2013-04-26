require 'ztk'

require 'testlab/version'

# Top-Level LXC Class
#
# @author Zachary Patten <zachary@jovelabs.net>
class TestLab

  # Top-Level Error Class
  class TestLabError < StandardError; end

  autoload :Provider, 'testlab/provider'
  autoload :Provisioner, 'testlab/provisioner'

  autoload :Labfile, 'testlab/labfile'
  autoload :Node, 'testlab/node'
  autoload :Router, 'testlab/router'
  autoload :Container, 'testlab/container'
  autoload :Network, 'testlab/network'
  autoload :Link, 'testlab/link'

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

  def routers
    TestLab::Router.all
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
      @@ui.stdout.puts("NODES:")
      ZTK::Report.new(:ui => @@ui).spreadsheet(TestLab::Node.all, TestLab::Node::STATUS_KEYS) do |node|
        OpenStruct.new(node.status.merge(:id => node.id))
      end
      @@ui.stdout.puts
      @@ui.stdout.puts("NETWORKS:")
      ZTK::Report.new(:ui => @@ui).spreadsheet(TestLab::Network.all, TestLab::Network::STATUS_KEYS) do |network|
        OpenStruct.new(network.status.merge(:id => network.id))
      end
      @@ui.stdout.puts
      @@ui.stdout.puts("CONTAINERS:")
      ZTK::Report.new(:ui => @@ui).spreadsheet(TestLab::Container.all, TestLab::Container::STATUS_KEYS) do |container|
        OpenStruct.new(container.status.merge(:id => container.id))
      end

      true
    else
      @@ui.stdout.puts("Looks like your test lab is dead; fix this and try again.")

      false
    end
  end

  # Proxy various method calls to our subordinate classes
  def method_proxy(method_name, *method_args)
    @@ui.logger.debug { "TestLab.#{method_name}" }
    TestLab::Node.all.map do |node|
      node.send(method_name.to_sym, *method_args)
    end
  end

  # Method missing handler
  def method_missing(method_name, *method_args)
    @@ui.logger.debug { "TESTLAB METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

    if (TestLab::Provider::PROXY_METHODS.include?(method_name) || %w(setup teardown).map(&:to_sym).include?(method_name))
      method_proxy(method_name, *method_args)
    else
      super(method_name, *method_args)
    end
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
