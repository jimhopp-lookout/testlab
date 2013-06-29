class TestLab
  class Provisioner
    class Chef

      # OmniTruck Provisioner Error Class
      class OmniTruckError < ChefError; end

      # OmniTruck Provisioner Class
      #
      # @author Zachary Patten <zachary AT jovelabs DOT com>
      class OmniTruck
        require 'json'

        def initialize(config={}, ui=nil)
          @config = (config || Hash.new)
          @ui     = (ui || TestLab.ui)

          @config[:version]     ||= "latest"
          @config[:prereleases] ||= false
          @config[:nightlies]   ||= false

          @ui.logger.debug { "config(#{@config.inspect})" }
        end

        # OmniTruck Provisioner Container Setup
        #
        # Renders the defined script to a temporary file on the target container
        # and proceeds to execute said script as root via *lxc-attach*.
        #
        # @param [TestLab::Container] container The container which we want to
        #   provision.
        # @return [Boolean] True if successful.
        def on_container_setup(container)
          omnibus_template = File.join(TestLab::Provisioner.template_dir, 'chef', 'omnitruck.erb')
          config = {}.merge!({
            :server_name => container.fqdn,
            :chef_pre_11 => chef_pre_11?,
            :chef_solo_attributes => build_chef_solo_attributes(container),
            :chef_validator => (chef_pre_11? ? '/etc/chef/validation.pem' : '/etc/chef-server/chef-validator.pem'),
            :chef_webui => (chef_pre_11? ? '/etc/chef/webui.pem' : '/etc/chef-server/chef-webui.pem'),
            :chef_admin => (chef_pre_11? ? '/etc/chef/admin.pem' : '/etc/chef-server/admin.pem'),
            :default_password => "p@ssw01d",
            :user => ENV['USER'],
            :hostname_short => container.id,
            :hostname_full => container.fqdn,
            :omnibus_version => omnibus_version
          }).merge!(@config)
          container.bootstrap(ZTK::Template.render(omnibus_template, config))
        end

        # OmniTruck Provisioner Container Teardown
        #
        # This is a NO-OP currently.
        #
        # @return [Boolean] True if successful.
        def on_container_teardown(container)
          # NOOP

          true
        end

      private

        def build_chef_solo_10_attributes(container)
          {
            "chef_server" => {
              "url" => "https://#{container.fqdn}",
              "webui_enabled" => true
            },
            "run_list" => %w(recipe[chef-server::rubygems-install] recipe[chef-server::apache-proxy])
          }
        end

        def build_chef_solo_11_attributes(container)
          {
            "chef-server" => {
              "api_fqdn" => container.fqdn,
              "nginx" => {
                "enable_non_ssl" => true,
                "server_name" => container.fqdn,
                "url" => "https://#{container.fqdn}"
              },
              "lb" => {
                "fqdn" => container.fqdn
              },
              "bookshelf" => {
                "vip" => container.fqdn
              },
              "chef_server_webui" => {
                "enable" => true
              },
              "version" => @config[:version],
              "prereleases" => @config[:prereleases],
              "nightlies" => @config[:nightlies]
            },
            "run_list" => %w(recipe[chef-server::default])
          }
        end

        def build_chef_solo_attributes(container)
          if chef_pre_11?
            build_chef_solo_10_attributes(container)
          else
            build_chef_solo_11_attributes(container)
          end
        end

        def chef_pre_11?
          if (@config[:version].to_s.downcase != "latest") && (@config[:version].to_f < 11.0)
            true
          else
            false
          end
        end

        def omnibus_version
          if (@config[:version].to_f == 0.1)
            "10.12.0"
          else
            @config[:version]
          end
        end

      end

    end
  end
end
