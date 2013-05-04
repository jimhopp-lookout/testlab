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

    module Resolv
      require 'tempfile'

      # Builds the main resolv configuration sections
      def build_resolv_main_conf(file)
        resolv_conf_template = File.join(self.class.template_dir, "resolv.erb")

        context = {
          :servers => [TestLab::Network.ips, "8.8.8.8", "8.8.4.4" ].flatten,
          :search => TestLab::Container.domains.join(' ')
        }

        file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} RESOLVER Configuration"))
        file.puts(ZTK::Template.render(resolv_conf_template, context))
      end

      def build_resolv_conf
        self.ssh.file(:target => File.join("/etc/resolv.conf"), :chown => "root:root") do |file|
          build_resolv_main_conf(file)
        end
      end

    end

  end
end
