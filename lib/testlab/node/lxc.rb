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

    module LXC
      require 'lxc'

      # Returns the LXC object for this Node
      #
      # This object is used to control containers on the node via it's provider
      #
      # @return [LXC] An instance of LXC configured for this node.
      def lxc(options={})
        if (!defined?(@lxc) || @lxc.nil?)
          @lxc ||= ::LXC.new
          @lxc.use_sudo = true
          @lxc.use_ssh = self.ssh
        end
        @lxc
      end

      # Returns the machine type of the node.
      #
      # @return [String] The output of 'uname -m'.
      def arch
        @arch ||= self.ssh.exec(%(uname -m)).output.strip
      end

    end

  end
end
