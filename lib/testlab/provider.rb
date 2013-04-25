class TestLab

  # Provider Error Class
  class ProviderError < TestLabError; end

  # Provider Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Provider
    autoload :AWS, 'testlab/providers/aws'
    autoload :Local, 'testlab/providers/local'
    autoload :Vagrant, 'testlab/providers/vagrant'

    PROXY_METHODS = %w(instance_id state user ip port create destroy up down reload status alive? dead? exists?).map(&:to_sym)

    class << self

      # Returns the path to the gems provider templates
      def template_dir
        File.join(TestLab.gem_dir, "lib", "testlab", "providers", "templates")
      end

    end

  end

end
