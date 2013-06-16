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
desc 'Manage nodes'
arg_name 'Describe arguments to node here'
command :node do |c|

  c.desc 'Node ID or Name'
  c.arg_name 'node'
  c.flag [:n, :name]

  # NODE CREATE
  ##############
  c.desc 'Create a node'
  c.long_desc <<-EOF
Create a node.  The node is created.
EOF
  c.command :create do |create|
    create.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        node = @testlab.nodes.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        node.nil? and raise TestLab::TestLabError, "We could not find the node you screateplied!"

        node.create
      end
    end
  end

  # NODE DESTROY
  ############
  c.desc 'Destroy a node'
  c.long_desc <<-EOF
Destroy a node.  The node is stopped and destroyed.
EOF
  c.command :destroy do |destroy|
    destroy.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        node = @testlab.nodes.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        node.nil? and raise TestLab::TestLabError, "We could not find the node you supplied!"

        node.destroy
      end
    end
  end

  # NODE UP
  ##########
  c.desc 'Up a node'
  c.long_desc <<-EOF
Up a node.  The node is started and brought online.
EOF
  c.command :up do |up|
    up.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        node = @testlab.nodes.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        node.nil? and raise TestLab::TestLabError, "We could not find the node you supplied!"

        node.up
      end
    end
  end

  # NODE DOWN
  ############
  c.desc 'Down a node'
  c.long_desc <<-EOF
Down a node.  The node is stopped taking it offline.
EOF
  c.command :down do |down|
    down.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        node = @testlab.nodes.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        node.nil? and raise TestLab::TestLabError, "We could not find the node you supplied!"

        node.down
      end
    end
  end

  # NODE SETUP
  #############
  c.desc 'Setup a node'
  c.long_desc <<-EOF
Setup a node.  The node is created, started and provisioned.
EOF
  c.command :setup do |setup|
    setup.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        node = @testlab.nodes.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        node.nil? and raise TestLab::TestLabError, "We could not find the node you supplied!"

        node.setup
      end
    end
  end

  # NODE TEARDOWN
  ################
  c.desc 'Teardown a node'
  c.long_desc <<-EOF
Teardown a node.  The node is offlined and destroyed.
EOF
  c.command :teardown do |teardown|
    teardown.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        node = @testlab.nodes.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        node.nil? and raise TestLab::TestLabError, "We could not find the node you supplied!"

        node.teardown
      end
    end
  end

  # NODE STATUS
  ##############
  c.desc 'Display the status of node(s)'
  c.long_desc 'Displays the status of all nodes or a single node if supplied via the ID parameter.'
  c.command :status do |status|
    status.action do |global_options, options, args|
      if options[:name].nil?
        # No ID supplied; show everything
        ZTK::Report.new(:ui => @testlab.ui).list(@testlab.nodes, TestLab::Node::STATUS_KEYS) do |node|
          OpenStruct.new(node.status)
        end
      else
        # ID supplied; show just that item
        node = @testlab.nodes.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        node.nil? and raise TestLab::TestLabError, "We could not find the node you supplied!"

        ZTK::Report.new(:ui => @testlab.ui).list(node, TestLab::Node::STATUS_KEYS) do |node|
          OpenStruct.new(node.status)
        end
      end
    end
  end

  # NODE SSH
  ###########
  c.desc 'Open an SSH console to a node'
  c.command :ssh do |ssh|
    ssh.action do |global_options,options,args|
      help_now!('a name is required') if options[:name].nil?

      node = @testlab.nodes.select{ |n| n.id.to_sym == options[:name].to_sym }.first
      node.nil? and raise TestLab::TestLabError, "We could not find the node you supplied!"

      node.ssh.console
    end
  end

end
