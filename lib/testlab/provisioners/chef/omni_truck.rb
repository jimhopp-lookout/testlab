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

          @config[:chef] ||= Hash.new

          @config[:chef][:client] ||= Hash.new
          @config[:chef][:client][:version]     ||= %(latest)

          @config[:chef][:server] ||= Hash.new
          @config[:chef][:server][:version]     ||= %(latest)
          @config[:chef][:server][:prereleases] ||= false
          @config[:chef][:server][:nightlies]   ||= false
          @config[:chef][:server][:server_url]  ||= "https://127.0.0.1"

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
          omnitruck_template = File.join(TestLab::Provisioner::Chef.template_dir, 'omni_truck.erb')
          home_dir           = (container.primary_user.id == "root" ? "/root" : "/home/#{container.primary_user.id}")

          config = {}.merge!({
            :server_name => container.ip,
            :chef_solo_attributes => build_omni_truck_attributes(container),
            :chef_validator => '/etc/chef-server/chef-validator.pem',
            :chef_webui => '/etc/chef-server/chef-webui.pem',
            :chef_admin => '/etc/chef-server/admin.pem',
            :local_user => ENV['USER'],
            :default_password => "p@ssw01d",
            :sudo_user => container.primary_user.id,
            :sudo_uid => container.primary_user.uid,
            :sudo_gid => container.primary_user.gid,
            :home_dir => home_dir,
            :omnibus_version => @config[:chef][:client][:version]
          }).merge!(@config)

          container.bootstrap(ZTK::Template.render(omnitruck_template, config))
        end

      private

        def build_omni_truck_attributes(container)
          {
            "chef-server" => {
              "api_fqdn" => container.ip,
              "nginx" => {
                "enable_non_ssl" => true,
                "server_name" => container.ip,
                "url" => @config[:chef][:server][:server_url]
              },
              "lb" => {
                "fqdn" => container.ip
              },
              "bookshelf" => {
                "vip" => container.ip
              },
              "chef_server_webui" => {
                "enable" => true
              },
              "version" => @config[:chef][:server][:version],
              "prereleases" => @config[:chef][:server][:prereleases],
              "nightlies" => @config[:chef][:server][:nightlies]
            },
            "run_list" => %w(recipe[chef-server::default])
          }
        end

      end

    end
  end
end
