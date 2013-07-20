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
build_lab_commands(:container, TestLab::Container) do |c|

  # CONTAINER STATUS
  ###################
  c.desc 'Display containers status'
  c.long_desc <<-EOF
Displays the status of all containers or single/multiple containers if supplied via the ID parameter.
EOF
  c.command :status do |status|
    status.action do |global_options, options, args|
      containers = iterate_objects_by_name(options[:name], TestLab::Container).delete_if{ |container| container.node.dead? }

      if (containers.count == 0)
        @testlab.ui.stderr.puts("You either have no containers defined or dead nodes!".yellow)
      else
        ZTK::Report.new(:ui => @testlab.ui).list(containers, TestLab::Container::STATUS_KEYS) do |container|
          OpenStruct.new(container.status)
        end
      end
    end
  end

  # CONTAINER SSH
  ################
  c.desc 'Container SSH console'
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

  # CONTAINER SSH-CONFIG
  #######################
  c.desc 'Container SSH configuration'
  c.long_desc <<-EOF
Displays a containers SSH configuration.
EOF
  c.command :'ssh-config' do |ssh_config|

    ssh_config.action do |global_options, options, args|
      iterate_objects_by_name(options[:name], TestLab::Container) do |container|
        puts(container.ssh_config)
      end
    end
  end

  # CONTAINER CONSOLE
  ####################
  c.desc 'Container console'
  c.command :console do |console|

    console.action do |global_options, options, args|
      help_now!('a name is required') if options[:name].nil?

      container = @testlab.containers.select{ |n| n.id.to_sym == options[:name].to_sym }.first
      container.nil? and raise TestLab::TestLabError, "We could not find the container you supplied!"

      container.console
    end
  end

  # CONTAINER CLONE
  ##################
  c.desc 'Clone containers'
  c.long_desc <<-EOF
An ephemeral copy of the container is started.

NOTE: There is a small delay incured during the first clone operation.
EOF
  c.command :clone do |clone|
    clone.action do |global_options, options, args|
      iterate_objects_by_name(options[:name], TestLab::Container) do |container|
        container.clone
      end
    end
  end

  # CONTAINER COPY
  #################
  c.desc 'Copy containers'
  c.long_desc <<-EOF
Creates a copy of a container.

NOTE: This will result in the source container being stopped before the copy operation commences.
EOF
  c.command :copy do |copy|

    copy.desc %(The container ID we wish to copy the original container to.)
    copy.arg_name %(container)
    copy.flag [:t, :to]

    copy.action do |global_options, options, args|
      iterate_objects_by_name(options[:name], TestLab::Container) do |container|
        container.copy(options[:to])
      end
    end
  end

  # CONTAINER EXPORT
  ###################
  c.desc 'Export containers'
  c.command :export do |export|

    export.desc 'Specify the level of bzip2 compression to use (1-9)'
    export.default_value 9
    export.arg_name 'level'
    export.flag [:c, :compression]

    export.desc 'Specify the shipping container file to export to.'
    export.arg_name 'filename'
    export.flag [:output]

    export.action do |global_options, options, args|
      iterate_objects_by_name(options[:name], TestLab::Container) do |container|
        container.export(options[:compression], options[:output])
      end
    end
  end

  # CONTAINER IMPORT
  ###################
  c.desc 'Import containers'
  c.command :import do |import|

    import.desc 'Specify the shipping container file to import from.'
    import.arg_name 'filename'
    import.flag [:input]

    import.action do |global_options, options, args|
      if (options[:name].nil? || options[:input].nil?)
        help_now!('a name is required') if options[:name].nil?
        help_now!('a filename is required') if options[:input].nil?
      else
        iterate_objects_by_name(options[:name], TestLab::Container) do |container|
          container.import(options[:input])
        end
      end
    end
  end

end
