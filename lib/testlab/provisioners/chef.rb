class TestLab
  class Provisioner

    # Chef Provisioner Error Class
    class ChefError < ProvisionerError; end

    # Chef Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Chef

      autoload :RubyGemClient,  'testlab/provisioners/chef/ruby_gem_client'
      autoload :RubyGemServer,  'testlab/provisioners/chef/ruby_gem_server'
      autoload :OmniBus,        'testlab/provisioners/chef/omni_bus'
      autoload :OmniTruck,      'testlab/provisioners/chef/omni_truck'

      class << self

        # Returns the path to the gems provisioner templates
        def template_dir
          File.join(TestLab::Provisioner.template_dir, "chef")
        end

      end

    end
  end
end
