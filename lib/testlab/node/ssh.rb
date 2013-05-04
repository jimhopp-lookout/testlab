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

    module SSH

      # SSH to the Node
      def ssh(options={})
        if (!defined?(@ssh) || @ssh.nil?)
          @ssh ||= ZTK::SSH.new({:ui => @ui, :timeout => 1200, :silence => true}.merge(options))
          @ssh.config do |c|
            c.host_name = @provider.ip
            c.port      = @provider.port
            c.user      = @provider.user
            c.keys      = @provider.identity
          end
        end
        @ssh
      end

      # SSH to a container running on the Node
      def container_ssh(container, options={})
        name = container.id
        @container_ssh ||= Hash.new
        if @container_ssh[name].nil?
          @container_ssh[name] ||= ZTK::SSH.new({:ui => @ui, :timeout => 1200, :silence => true}.merge(options))
          @container_ssh[name].config do |c|
            c.proxy_host_name = @provider.ip
            c.proxy_port      = @provider.port
            c.proxy_user      = @provider.user
            c.proxy_keys      = @provider.identity

            c.host_name       = container.ip
            c.user            = (container.user || "ubuntu")
            if container.keys.nil?
              c.password      = (container.passwd || "ubuntu")
            else
              c.keys          = container.keys
            end
          end
        end
        @container_ssh[name]
      end

    end

  end
end
