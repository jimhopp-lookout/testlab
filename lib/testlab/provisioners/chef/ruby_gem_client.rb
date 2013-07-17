class TestLab
  class Provisioner
    class Chef

      # RubyGemClient Provisioner Error Class
      class RubyGemClientError < ChefError; end

      # RubyGemClient Provisioner Class
      #
      # @author Zachary Patten <zachary AT jovelabs DOT com>
      class RubyGemClient
        require 'json'

        def initialize(config={}, ui=nil)
          @config = (config || Hash.new)
          @ui     = (ui || TestLab.ui)

          @chef_server = TestLab::Container.first('chef-server')

          @config[:chef] ||= Hash.new
          @config[:chef][:client] ||= Hash.new
          @config[:chef][:client][:version]    ||= %(10.24.0)
          @config[:chef][:client][:log_level]  ||= :info
          @config[:chef][:client][:server_url] ||= "https://#{@chef_server.ip}"
          @config[:chef][:client][:attributes] ||= Hash.new

          @ui.logger.debug { "config(#{@config.inspect})" }
        end

        # RubyGemClient: Container Provision
        #
        # Renders the defined script to a temporary file on the target container
        # and proceeds to execute said script as root via *lxc-attach*.
        #
        # @param [TestLab::Container] container The container which we want to
        #   provision.
        # @return [Boolean] True if successful.
        def on_container_provision(container)
          @config[:chef][:client][:node_name] ||= container.id

          rubygem_client_template = File.join(TestLab::Provisioner::Chef.template_dir, 'ruby_gem_client.erb')

          config = {}.merge!({
            :chef_client_cli => chef_client_cli(container),
            :chef_client_rb => chef_client_rb(container),
            :validation_pem => validation_pem,
            :sudo_user => container.primary_user.username,
            :sudo_uid => container.primary_user.uid,
            :sudo_gid => container.primary_user.gid,
            :home_dir => container.primary_user.home_dir
          }).merge!(@config)

          container.bootstrap(ZTK::Template.render(rubygem_client_template, config))

          true
        end

        # RubyGemClient: Container Deprovision
        #
        # @return [Boolean] True if successful.
        def on_container_deprovision(container)
          if @chef_server.state == :running
            @chef_server.ssh.exec(%(knife node delete #{container.id} --yes), :ignore_exit_status => true)
            @chef_server.ssh.exec(%(knife client delete #{container.id} --yes), :ignore_exit_status => true)
          end

          true
        end

      private

        def chef_client_cli(container, *args)
          arguments = Array.new

          arguments << %(chef-client)
          arguments << [args]
          arguments << %(--node-name #{container.id})
          arguments << %(--environment #{@config[:chef][:client][:environment]}) if !@config[:chef][:client][:environment].nil?
          arguments << %(--json-attributes /etc/chef/attributes.json)
          arguments << %(--server #{@config[:chef][:client][:server_url]})
          arguments << %(--once)

          arguments.flatten.compact.join(' ')
        end

        def chef_client_rb(container)
          <<-EOF
#{ZTK::Template.do_not_edit_notice(:message => "TestLab Chef-Client Configuration")}
log_level               #{@config[:chef][:client][:log_level].inspect}
log_location            STDOUT
chef_server_url         #{@config[:chef][:client][:server_url].inspect}
validation_client_name  "chef-validator"
node_name               #{@config[:chef][:client][:node_name].inspect}
          EOF
        end

        def validation_pem
          @chef_server.ssh.exec(%((cat ~/.chef/validation.pem || cat ~/.chef/chef-validator.pem) 2> /dev/null)).output.strip
        end

      end

    end
  end
end
