class TestLab

  # Provisioner Error Class
  class ProvisionerError < TestLabError; end

  # Provisioner Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Provisioner
    autoload :Apt,         'testlab/provisioners/apt'
    autoload :AptCacherNG, 'testlab/provisioners/apt_cacher_ng'
    autoload :Bind,        'testlab/provisioners/bind'
    autoload :ChefGem,     'testlab/provisioners/chef_gem'
    autoload :OmniBus,     'testlab/provisioners/omnibus'
    autoload :OmniTruck,   'testlab/provisioners/omnitruck'
    autoload :Raring,      'testlab/provisioners/raring'
    autoload :Resolv,      'testlab/provisioners/resolv'
    autoload :Route,       'testlab/provisioners/route'
    autoload :Shell,       'testlab/provisioners/shell'

    class << self

      # Returns the path to the gems provisioner templates
      def template_dir
        File.join(TestLab.gem_dir, "lib", "testlab", "provisioners", "templates")
      end

    end

  end

end
