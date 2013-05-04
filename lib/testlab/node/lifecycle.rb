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

    module Lifecycle

      # Iterates an array of arrays calling the specified method on all the
      # collections of objects
      def call_collections(collections, method_name)
        collections.each do |collection|
          call_methods(collection, method_name)
        end
      end

      # Calls the specified method on all the objects supplied
      def call_methods(objects, method_name)
        objects.each do |object|
          if object.respond_to?(method_name)
            object.send(method_name)
          end
        end
      end

      # Bootstrap the node
      def node_setup
        node_setup_template = File.join(self.class.template_dir, 'node-setup.erb')
        self.ssh.bootstrap(ZTK::Template.render(node_setup_template))
      end

      def route_setup(action)
        self.networks.each do |network|
          command = ZTK::Command.new(:silence => true, :ignore_exit_status => true)
          command.exec(%(sudo route #{action} -net #{TestLab::Utility.network(network.address)} netmask #{TestLab::Utility.netmask(network.address)} gw #{network.node.ip}))
        end
      end

      # Setup the node.
      def setup
        @ui.logger.debug { "Node Setup: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do

          if (self.route == true)
            route_setup(:add)
          end

          node_setup

          if self.components.include?('resolv')
            build_resolv_conf
          end

          if self.components.include?('bind')
            bind_setup
          end
        end

        call_collections([self.networks, self.containers], :setup)

        if self.components.include?('bind')
          bind_reload
        end

        true
      end

      # Teardown the node.
      def teardown
        @ui.logger.debug { "Node Teardown: #{self.id} " }

        call_collections([self.containers, self.networks], :teardown)

        please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do

          if (self.route == true)
            route_setup(:del)
          end
        end

        true
      end

    end

  end
end
