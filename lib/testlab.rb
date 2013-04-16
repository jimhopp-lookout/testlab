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
  autoload :Container, 'testlab/container'
  autoload :Network, 'testlab/network'

  # attr_accessor :provider, :containers

  def initialize(labfile='Labfile', ui=ZTK::UI.new)
    @ui           = ui
    @labfile      = TestLab::Labfile.load(labfile)
  end

  def hosts
    @labfile.hosts
  end

  def config
    @labfile.config
  end

  def provider
    @provider
  end

  def provisioner
    @provisioner
  end

end
