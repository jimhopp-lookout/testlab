################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################
class TestLab
  class Node

    module Bind
      require 'tempfile'

      # Builds the main bind configuration sections
      def build_bind_main_partial(file)
        bind_conf_template = File.join(self.class.template_dir, "bind.erb")

        file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND Configuration", :char => '//'))
        file.puts(ZTK::Template.render(bind_conf_template, {}))
      end

      def build_bind_records
        forward_records = Hash.new
        reverse_records = Hash.new

        TestLab::Container.all.each do |container|
          container.domain ||= container.node.labfile.config[:domain]

          container.interfaces.each do |interface|
            forward_records[container.domain] ||= Array.new
            forward_records[container.domain] << %(#{container.id} IN A #{interface.ip})

            reverse_records[interface.network_id] ||= Array.new
            reverse_records[interface.network_id] << %(#{interface.ptr} IN PTR #{container.fqdn}.)
          end

        end
        { :forward => forward_records, :reverse => reverse_records }
      end

      # Builds the bind configuration sections for our zones
      def build_bind_zone_partial(file)
        bind_zone_template = File.join(self.class.template_dir, 'bind-zone.erb')

        bind_records = build_bind_records
        forward_records = bind_records[:forward]
        reverse_records = bind_records[:reverse]

        TestLab::Network.all.each do |network|
          context = {
            :zone => network.arpa
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(network.arpa, reverse_records[network.id])
        end

        TestLab::Container.domains.each do |domain|
          context = {
            :zone => domain
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(domain, forward_records[domain])
        end
      end

      def build_bind_db(zone, records)
        bind_db_template = File.join(self.class.template_dir, 'bind-db.erb')

        self.ssh.file(:target => "/etc/bind/db.#{zone}", :chown => "bind:bind") do |file|
          file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND DB: #{zone}", :char => ';'))
          file.puts(ZTK::Template.render(bind_db_template, { :zone => zone, :records => records }))
        end
      end

      # Builds the BIND configuration
      def build_bind_conf
        self.ssh.file(:target => File.join("/etc/bind/named.conf"), :chown => "bind:bind") do |file|
          build_bind_main_partial(file)
          build_bind_zone_partial(file)
        end
      end

      def bind_install
        self.ssh.exec(%(sudo apt-get -y install bind9))
        self.ssh.exec(%(sudo rm -fv /etc/bind/{*.arpa,*.zone,*.conf*}))
      end

      def bind_reload
        self.ssh.exec(%(sudo chown -Rv bind:bind /etc/bind))
        self.ssh.exec(%(sudo rndc reload))
      end

      def bind_setup
        bind_install
        build_bind_conf
        bind_reload
      end

    end

  end
end
