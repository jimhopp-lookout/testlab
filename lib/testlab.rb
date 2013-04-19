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
  autoload :Host, 'testlab/host'
  autoload :Router, 'testlab/router'
  autoload :Container, 'testlab/container'
  autoload :Network, 'testlab/network'

  @@ui ||= nil

  def initialize(ui=ZTK::UI.new)
    labfile = ZTK::Locator.find('Labfile')

    @@ui          = ui
    @labfile      = TestLab::Labfile.load(labfile)
  end

  def hosts
    TestLab::Host.all
  end

  def containers
    TestLab::Container.all
  end

  def networks
    TestLab::Network.all
  end

  def config
    @labfile.config
  end

  def method_missing(method_name, *method_args)
    if TestLab::Provider::PROXY_METHODS.include?(method_name.to_s)
      TestLab::Host.all.map do |host|
        host.send(method_name.to_sym, *method_args)
      end
    else
      super(method_name, *method_args)
    end
  end

  class << self

    def ui
      @@ui ||= ZTK::UI.new
    end

    def gem_dir
      File.expand_path(File.join(File.dirname(__FILE__), ".."), File.dirname(__FILE__))
    end

    def build_command(name, *args)
      executable = (ZTK::Locator.find('bin', name) rescue "/bin/env #{name}")
      [executable, args].flatten.compact.join(' ')
    end

  end

end
