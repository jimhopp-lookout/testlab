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

# CONTAINERS
#############
desc 'Manage containers'
arg_name 'Describe arguments to container here'
command :container do |c|

  c.desc 'Container ID or Name'
  c.arg_name 'container'
  c.flag [:n, :name]

  # CONTAINER CREATE
  ###################
  c.desc 'Create a container'
  c.long_desc <<-EOF
Create a container.  The container is created.
EOF
  c.command :create do |create|
    create.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        container = @testlab.containers.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        container.nil? and raise TestLab::TestLabError, "We could not find the container you screateplied!"

        container.create
      end
    end
  end

  # CONTAINER DESTROY
  ####################
  c.desc 'Destroy a container'
  c.long_desc <<-EOF
Destroy a container.  The container is stopped and destroyed.
EOF
  c.command :destroy do |destroy|
    destroy.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        container = @testlab.containers.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

        container.destroy
      end
    end
  end

  # CONTAINER UP
  ###############
  c.desc 'Up a container'
  c.long_desc <<-EOF
Up a container.  The container is started and brought online.
EOF
  c.command :up do |up|
    up.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        container = @testlab.containers.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

        container.up
      end
    end
  end

  # CONTAINER DOWN
  #################
  c.desc 'Down a container'
  c.long_desc <<-EOF
Down a container.  The container is stopped taking it offline.
EOF
  c.command :down do |down|
    down.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        container = @testlab.containers.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

        container.down
      end
    end
  end

  # CONTAINER SETUP
  ####################
  c.desc 'Setup a container'
  c.long_desc <<-EOF
Setup a container.  The container is created, started and provisioned.
EOF
  c.command :setup do |setup|
    setup.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        container = @testlab.containers.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

        container.setup
      end
    end
  end

  # CONTAINER TEARDOWN
  ####################
  c.desc 'Teardown a container'
  c.long_desc <<-EOF
Teardown a container.  The container is offlined and destroyed.
EOF
  c.command :teardown do |teardown|
    teardown.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        container = @testlab.containers.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

        container.teardown
      end
    end
  end

  # CONTAINER STATUS
  ###################
  c.desc 'Display the status of container(s)'
  c.long_desc <<-EOF
Displays the status of all containers or a single container if supplied via the ID parameter.
EOF
  c.command :status do |status|
    status.action do |global_options, options, args|
      if options[:name].nil?
        # No ID supplied; show everything
        containers = @testlab.containers.delete_if{ |c| c.node.dead? }
        if containers.count == 0
          @testlab.ui.stderr.puts("You either have no containers defined or dead nodes!".yellow)
        else
          # ZTK::Report.new(:ui => @testlab.ui).spreadsheet(containers, TestLab::Container::STATUS_KEYS.reject{|k| k == :fqdn}) do |container|
          ZTK::Report.new(:ui => @testlab.ui).list(containers, TestLab::Container::STATUS_KEYS) do |container|
            # OpenStruct.new(container.status.reject{|k,v| k == :fqdn})
            OpenStruct.new(container.status)
          end
        end
      else
        # ID supplied; show just that item
        container = @testlab.containers.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

        ZTK::Report.new(:ui => @testlab.ui).list(container, TestLab::Container::STATUS_KEYS) do |container|
          OpenStruct.new(container.status)
        end
      end
    end
  end

  # CONTAINER SSH
  ################
  c.desc 'Open an SSH console to a container'
  c.command :ssh do |ssh|

    ssh.desc 'Specify an SSH Username to use'
    ssh.arg_name 'username'
    ssh.flag [:u, :user]

    ssh.desc 'Specify an SSH Identity Key to use'
    ssh.arg_name 'filename'
    ssh.flag [:i, :identity]

    ssh.action do |global_options, options, args|
      help_now!('a name is required') if options[:name].nil?

      container = @testlab.containers.select{ |n| n.id.to_sym == options[:name].to_sym }.first
      container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

      ssh_options = Hash.new
      ssh_options[:user] = options[:user]
      ssh_options[:keys] = options[:identity]

      container.ssh(ssh_options).console
    end
  end

  # CONTAINER RECYCLE
  ####################
  c.desc 'Recycles a container'
  c.long_desc <<-EOF
Recycles a container.  The container is taken through a series of state changes to ensure it is pristine.

The containers is cycled in this order:

Teardown -> Down -> Destroy -> Create -> Up -> Setup
EOF
  c.command :recycle do |recycle|
    recycle.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        container = @testlab.containers.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

        container.teardown
        container.down
        container.destroy

        container.create
        container.up
        container.setup
      end
    end
  end

  # CONTAINER CLONE
  ##################
  c.desc 'Clone a container'
  c.long_desc <<-EOF
Clone a container.  The container is offlined and an ephemeral copy of it is started.
EOF
  c.command :clone do |clone|
    clone.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        container = @testlab.containers.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

        container.clone
      end
    end
  end

  # CONTAINER EXPORT
  ###################
  c.desc 'Export a container to a shipping container (file)'
  c.command :export do |export|

    export.desc 'Specify the level of bzip2 compression to use (1-9)'
    export.default_value 9
    export.arg_name 'level'
    export.flag [:c, :compression]

    export.desc 'Specify the shipping container file to export to.'
    # export.default_value nil
    export.arg_name 'filename'
    export.flag [:output]

    export.action do |global_options, options, args|
      help_now!('a name is required') if options[:name].nil?

      container = @testlab.containers.select{ |n| n.id.to_sym == options[:name].to_sym }.first
      container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

      container.export(options[:compression], options[:output])
    end
  end

  # CONTAINER IMPORT
  ###################
  c.desc 'Import a shipping container (file)'
  c.command :import do |import|

    import.desc 'Specify the shipping container file to import from.'
    import.arg_name 'filename'
    import.flag [:input]

    import.action do |global_options, options, args|
      help_now!('a name is required') if options[:name].nil?
      help_now!('a filename is required') if options[:input].nil?

      container = @testlab.containers.select{ |n| n.id.to_sym == options[:name].to_sym }.first
      container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

      container.import(options[:input])
    end
  end

end
