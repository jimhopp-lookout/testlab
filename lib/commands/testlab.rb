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
desc 'Create the test lab'
command :create do |create|
  create.action do |global_options,options,args|
    @testlab.create
  end
end

# LAB DESTROY
##############
desc 'Destroy the test lab'
command :destroy do |destroy|
  destroy.action do |global_options,options,args|
    @testlab.destroy
  end
end

# LAB ONLINE
#############
desc 'Online the test lab'
command :up do |up|
  up.action do |global_options,options,args|
    @testlab.up
  end
end

# LAB OFFLINE
##############
desc 'Offline the test lab'
command :down do |down|
  down.action do |global_options,options,args|
    @testlab.down
  end
end

# LAB SETUP
############
desc 'Setup the test lab infrastructure'
command :setup do |setup|
  setup.action do |global_options,options,args|
    @testlab.setup
  end
end

# LAB TEARDOWN
###############
desc 'Teardown the test lab infrastructure'
command :teardown do |teardown|
  teardown.action do |global_options,options,args|
    @testlab.teardown
  end
end

# LAB BUILD
############
desc 'Build the test lab infrastructure'
long_desc <<-EOF
Attempts to build the defined test lab.  TestLab will attempt to create, online and provision the lab components.

The components are built in the following order:

Nodes -> Networks -> Containers

TestLab will then attempt to build the components, executing the following tasks for each:

Create -> Up -> Setup
EOF
command :build do |build|
  build.action do |global_options,options,args|
    @testlab.build
  end
end

# LAB DEMOLISH
###############
desc 'Demolish the test lab infrastructure'
long_desc <<-EOF
Attempts to demolish the defined test lab.  TestLab will attempt to deprovision, offline and destroy the lab components.

The components are demolished in the following order:

Containers -> Networks -> Nodes

TestLab will then attempt to demolish the components, executing the following tasks for each:

Teardown -> Down -> Destroy
EOF
command :demolish do |demolish|
  demolish.action do |global_options,options,args|
    @testlab.demolish
  end
end

# LAB STATUS
#############
desc 'Display information on the status of the test lab'
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
