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

# NODES
########
build_lab_commands(:node, TestLab::Node) do |c|

  # NODE STATUS
  ##############
  c.desc 'Display nodes status'
  c.long_desc 'Displays the status of all nodes or a single node if supplied via the ID parameter.'
  c.command :status do |status|
    status.action do |global_options, options, args|
      nodes = iterate_objects_by_name(options[:name], TestLab::Node)

      if (nodes.count == 0)
        @testlab.ui.stderr.puts("You either have no nodes defined or dead nodes!".yellow)
      else
        ZTK::Report.new(:ui => @testlab.ui).list(nodes, TestLab::Node::STATUS_KEYS) do |node|
          OpenStruct.new(node.status)
        end
      end
    end
  end

  # NODE SSH
  ###########
  c.desc 'Node SSH console'
  c.command :ssh do |ssh|
    ssh.action do |global_options,options,args|
      node = iterate_objects_by_name(options[:name], TestLab::Node).first

      node.ssh.console
    end
  end

end
