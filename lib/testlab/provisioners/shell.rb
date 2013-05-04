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

  class Provisioner

    # Shell Provisioner Error Class
    class ShellError < ProvisionerError; end

    # Shell Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Shell
      require 'tempfile'

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui || TestLab.ui)

        @config[:shell] ||= "/bin/bash"
      end

      def setup(container)
        if !@config[:setup].nil?
          ZTK::RescueRetry.try(:tries => 2, :on => ShellError) do
            tempfile = Tempfile.new("bootstrap")
            container.node.ssh.file(:target => File.join(container.lxc.fs_root, tempfile.path), :chmod => '0777', :chown => 'root:root') do |file|
              file.puts(@config[:setup])
            end
            if container.lxc.attach(@config[:shell], tempfile.path) =~ /No such file or directory/
              raise ShellError, "We could not find the bootstrap file!"
            end
          end
        end
      end

      def teardown(container)
        # NOOP
      end

    end

  end
end
