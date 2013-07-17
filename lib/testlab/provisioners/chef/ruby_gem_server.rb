class TestLab
  class Provisioner
    class Chef

      # RubyGemServer Provisioner Error Class
      class RubyGemServerError < ChefError; end

      # RubyGemServer Provisioner Class
      #
      # @author Zachary Patten <zachary AT jovelabs DOT com>
      class RubyGemServer
        require 'json'

        def initialize(config={}, ui=nil)
          @config = (config || Hash.new)
          @ui     = (ui || TestLab.ui)

          @config[:chef] ||= Hash.new
          @config[:chef][:server] ||= Hash.new
          @config[:chef][:server][:version]     ||= %(10.24.0)
          @config[:chef][:server][:server_url]  ||= "https://127.0.0.1"

          @ui.logger.debug { "config(#{@config.inspect})" }
        end

        # RubyGemServer: Container Provision
        #
        # Renders the defined script to a temporary file on the target container
        # and proceeds to execute said script as root via *lxc-attach*.
        #
        # @param [TestLab::Container] container The container which we want to
        #   provision.
        # @return [Boolean] True if successful.
        def on_container_provision(container)
          rubygemserver_template = File.join(TestLab::Provisioner.template_dir, 'chef', 'ruby_gem_server.erb')

          config = {}.merge!({
            :server_name => container.ip,
            :chef_solo_attributes => build_chef_solo_attributes(container),
            :chef_validator => '/etc/chef/validation.pem',
            :chef_webui => '/etc/chef/webui.pem',
            :chef_admin => '/etc/chef/admin.pem',
            :default_password => "p@ssw01d",
            :local_user => ENV['USER'],
            :sudo_user => container.primary_user.username,
            :sudo_uid => container.primary_user.uid,
            :sudo_gid => container.primary_user.gid,
            :home_dir => container.primary_user.home_dir,
            :chef_gems => %w(chef chef-solr chef-expander chef-server-api chef-server-webui),
            :chef_services => %w(couchdb rabbitmq-server chef-solr chef-expander chef-server chef-server-webui apache2)
          }).merge!(@config)

          container.bootstrap(ZTK::Template.render(rubygemserver_template, config))

          true
        end

      private

        def build_chef_solo_attributes(container)
          {
            "chef_server" => {
              "url" => @config[:chef][:server][:server_url],
              "webui_enabled" => true
            },
            "run_list" => %w(recipe[chef-server::rubygems-install] recipe[chef-server::apache-proxy])
          }
        end

      end

    end
  end
end
