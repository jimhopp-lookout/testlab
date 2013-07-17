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

# LAB CREATE
#############
desc 'Create the lab components'
long_desc <<-EOF
Attempts to create the defined lab components.

The components are created in the following order:

Nodes -> Networks -> Containers
EOF
command :create do |create|
  create.action do |global_options,options,args|
    @testlab.create
  end
end

# LAB DESTROY
##############
desc 'Destroy the lab components'
long_desc <<-EOF
Attempts to destroy the defined lab components.

The components are destroyed in the following order:

Nodes -> Networks -> Containers
EOF
command :destroy do |destroy|
  destroy.action do |global_options,options,args|
    @testlab.destroy
  end
end

# LAB ONLINE
#############
desc 'On-line the lab components'
long_desc <<-EOF
Attempts to online the defined lab components.

The components are onlined in the following order:

Nodes -> Networks -> Containers
EOF
command :up do |up|
  up.action do |global_options,options,args|
    @testlab.up
  end
end

# LAB OFFLINE
##############
desc 'Off-line the lab components'
long_desc <<-EOF
Attempts to offline the defined lab components.

The components are offlined in the following order:

Containers -> Networks -> Nodes
EOF
command :down do |down|
  down.action do |global_options,options,args|
    @testlab.down
  end
end

# LAB PROVISION
################
desc 'Provision the lab components'
long_desc <<-EOF
Attempts to provision the defined lab components.

The components are provisioned in the following order:

Nodes -> Networks -> Containers
EOF
command :provision do |provision|
  provision.action do |global_options,options,args|
    @testlab.provision
  end
end

# LAB DEPROVISION
##################
desc 'De-provision the lab components'
long_desc <<-EOF
Attempts to deprovision the defined lab components.

The components are torndown in the following order:

Containers -> Networks -> Nodes
EOF
command :deprovision do |deprovision|
  deprovision.action do |global_options,options,args|
    @testlab.deprovision
  end
end

# LAB BUILD
############
desc 'Build the lab'
long_desc <<-EOF
Attempts to build the defined lab.  TestLab will attempt to create, online and provision the lab components.

The components are built in the following order:

Nodes -> Networks -> Containers

TestLab will then attempt to build the components, executing the following tasks for each:

Create -> Up -> Provision
EOF
command :build do |build|
  build.action do |global_options,options,args|
    @testlab.build
  end
end

# LAB DEMOLISH
###############
desc 'Demolish the lab'
long_desc <<-EOF
Attempts to demolish the defined lab.  TestLab will attempt to deprovision, offline and destroy the lab components.

The components are demolished in the following order:

Containers -> Networks -> Nodes

TestLab will then attempt to demolish the components, executing the following tasks for each:

Deprovision -> Down -> Destroy
EOF
command :demolish do |demolish|
  demolish.action do |global_options,options,args|
    @testlab.demolish
  end
end

# LAB STATUS
#############
desc 'Display the lab status'
command :status do |status|
  status.action do |global_options,options,args|
    @testlab.ui.stdout.puts("\nNODES:".green.bold)
    commands[:node].commands[:status].execute({}, {}, [])

    @testlab.ui.stdout.puts("\nNETWORKS:".green.bold)
    commands[:network].commands[:status].execute({}, {}, [])

    @testlab.ui.stdout.puts("\nCONTAINERS:".green.bold)
    commands[:container].commands[:status].execute({}, {}, [])
  end
end
