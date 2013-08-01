[![Gem Version](https://badge.fury.io/rb/testlab.png)](http://badge.fury.io/rb/testlab)
[![Dependency Status](https://gemnasium.com/zpatten/testlab.png)](https://gemnasium.com/zpatten/testlab)
[![Build Status](https://secure.travis-ci.org/lookout/testlab.png)](http://travis-ci.org/lookout/testlab)
[![Coverage Status](https://coveralls.io/repos/zpatten/testlab/badge.png?branch=master)](https://coveralls.io/r/zpatten/testlab)
[![Code Climate](https://codeclimate.com/github/zpatten/testlab.png)](https://codeclimate.com/github/zpatten/testlab)

# A Quick Note on Versioning

I attempt to keep TestLab in line with Semantic Versioning when incrementing version numbers.  I am human so I may screw this up on, hopefully rare, occasion.  Semantic Versioning is delicious and everyone should be following this schema, especially when it comes to Ruby Gems which have a habit of pushing your projects into "dependency hell".

* http://semver.org/

# TestLab

A toolkit for building virtual computer labs.

What is TestLab?  TestLab lets you iterate virtual infrastructure quickly.  Using a `Labfile` you can define how you want your virtual infrastructure laid out.  You can define multiple network segments and containers (i.e. boxen).  TestLab will then build and demolish this virtual infrastructure as you have dictated in the `Labfile`.

TestLab can also import and export containers, making it easy to share them.  TestLab supports the latest LXC versions, allowing for ephemeral cloning operations, furthering your ability to iterate quickly.  TestLab can be used for many other applications, including infrastructure unit and integration testing, allowing for vastly more complex configurations and more effective resource sharing than traditional VM solutions.

TestLab can be run via the command-line or can be interfaced with directly via Ruby code.

# Using TestLab Interactively

    $ tl
    NAME
        tl - TestLab - A toolkit for building virtual computer labs

        TestLab is based around the abstraction of three main components: nodes, networks and containers. Nodes represent a system
        (bare-metal or virtualized) that hosts containers. Networks repesent a Linux bridge on a node. Containers simply represent a
        Linux Container (LXC) running on its parent node which is typically connected to a network on the node.

        In addition to the core component abstractions, TestLab shares a series of core tasks that are universal across all of the
        components. These are create and destroy, up and down, provision and deprovision. Several other core tasks, such as build,
        demolish, recycle and bounce encapsulate the previously mentioned tasks and simply act as convenience tasks.

        You can execute almost all of the tasks against the entire lab, or individual lab components.

        When building a lab from scratch, you will typically run 'tl build'. To breakdown your lab, destroying all the components, you
        will typically run 'tl demolish'. If you want to re-build the lab you can run 'tl recycle' which will run the demolish task
        followed by the build task against all the lab components. If you want to power-cycle the entire lab you can run 'tl bounce'
        which will run the down task followed by the up task against all the lab components. Again these tasks can be run against the
        lab as a whole or individual components.

        You can view the status of the entire lab using 'tl status', or view the status of individual components using 'tl node status',
        'tl network status' or 'tl container status'.

        You can easily get help for any of the component tasks using the syntax 'tl help <component>'. This can be extended to the
        following syntax 'tl help <task>' or 'tl help <component> <task>' for more in-depth help.

    SYNOPSIS
        tl [global options] command [command options] [arguments...]

    VERSION
        1.1.0

    GLOBAL OPTIONS
        -l, --labfile=path/to/file     - Path to Labfile: ${REPO}/Labfile (default: none)
        -r, --repo=path/to/directory   - Path to Repository directory: ${PWD} (default: /home/zpatten/code/chef-repo)
        -c, --config=path/to/directory - Path to Configuration directory: ${REPO}/.testlab-$(hostname -s) (default: none)
        --version                      - Display the program version
        -v, --[no-]verbose             - Show verbose output
        -q, --[no-]quiet               - Quiet mode
        --help                         - Show this message

    COMMANDS
        help        - Shows a list of commands or help for one command
        container   - Manage lab containers
        network     - Manage lab networks
        node        - Manage lab nodes
        build       - Build the lab (create->up->provision)
        demolish    - Demolish the lab (deprovision->down->destroy)
        bounce      - Bounce the lab (down->up)
        recycle     - Recycle the lab (demolish->build)
        create      - Create the lab components
        destroy     - Destroy the lab components
        up          - On-line the lab components
        down        - Off-line the lab components
        provision   - Provision the lab components
        deprovision - De-provision the lab components
        status      - Display the lab status

## Getting Help

TestLab uses the GLI RubyGem, which gives us a command line pattern similar to that of Git.  Therefore help is easy to get:

    tl help
    tl help node
    tl help container
    tl help network

## Container Help

Here is a sample of the help output for the container tasks:

    $ tl help container
    NAME
        container - Manage lab containers

    SYNOPSIS
        tl [global options] container [command options]  bounce
        tl [global options] container [command options]  build
        tl [global options] container [command options]  console
        tl [global options] container [command options] [-t container|--to container] copy
        tl [global options] container [command options]  create
        tl [global options] container [command options]  demolish
        tl [global options] container [command options]  deprovision
        tl [global options] container [command options]  destroy
        tl [global options] container [command options]  down
        tl [global options] container [command options]  ephemeral
        tl [global options] container [command options] [--output filename] [-c level|--compression level] export
        tl [global options] container [command options] [--input filename] import
        tl [global options] container [command options]  persistent
        tl [global options] container [command options]  provision
        tl [global options] container [command options]  recycle
        tl [global options] container [command options] [-i filename|--identity filename] [-u username|--user username] ssh
        tl [global options] container [command options]  ssh-config
        tl [global options] container [command options]  status
        tl [global options] container [command options]  up

    COMMAND OPTIONS
        -n, --name=container[,container,...] - Optional container ID or comma separated list of container IDs (default: none)

    COMMANDS
        build       - Build containers (create->up->provision)
        demolish    - Demolish containers (deprovision->down->destroy)
        recycle     - Recycle containers (demolish->build)
        bounce      - Bounce containers (down->up)
        create      - Initialize containers
        destroy     - Terminate containers
        up          - On-line containers
        down        - Off-line containers
        provision   - Provision containers
        deprovision - De-provision containers
        status      - Display containers status
        ssh         - Container SSH console
        ssh-config  - Container SSH configuration
        console     - Container console
        ephemeral   - Enable ephemeral mode for containers
        persistent  - Enable persistent mode for containers
        copy        - Copy containers
        export      - Export containers
        import      - Import containers

## Interacting with Containers

Almost all commands dealing will containers will take this argument:

    COMMAND OPTIONS
        -n, --name=container[,container,...] - Optional container ID or comma separated list of container IDs (default: none)

You can interact with containers via SSH:

    tl container ssh -n <name>

For example:

    tl container ssh -n server-www-1

Would connect to the container defined as 'server-www-1' in our Labfile.

You can pass an optional username and/or identity to use.  By default TestLab will attempt to SSH as the user defined in the `Labfile` for that container, otherwise the default user for the containers distro is used.

    $ tl help container ssh
    NAME
        ssh - Open an SSH console to a container

    SYNOPSIS
        tl [global options] container ssh [command options]

    COMMAND OPTIONS
        -u, --user=username - Specify an SSH Username to use (default: none)
        -i, --identity=key  - Specify an SSH Identity Key to use (default: none)

You can individually create or destroy, online or offline and provision or deprovision containers:

    tl container create -n server-www-1
    tl container destroy -n server-www-1

    tl container up -n server-www-1
    tl container down -n server-www-1

    tl container provision -n server-www-1
    tl container deprovision -n server-www-1

You can recycle a container, destroying then creating it again, provisioning it back to a "pristine" condition based on the `Labfile`:

    tl container recycle -n server-www-1

You can bounce a container, offlining then onlining it again:

    tl container bounce -n server-www-1

## Ephemeral Container Cloning

As it stands attempting to iterate infrastructure with Vagrant is a slow and painful process.  Enter LXC and ephemeral cloning.  The idea here is that you have a container that is provisioned to a "pristine" state according to the `Labfile`.  You then clone this container and run actions against the container.  After running your actions against the container you want to maybe tweak your Chef cookbook, for example, and re-run it against the container.  Running an ever changing cookbook in development against the same system over and over again causes drift and problems.  With the cloning you can instantly reinstate the container as it was when you first cloned it.

In order to use the ephemeral cloning in LXC, we first need to put our container or containers into an ephemeral mode.  This allows TestLab to do certain operations on the backend to prepare the container for ephemeral cloning.  Then when you are finished, you can easily return the container to a persistent mode.

For example, to put the container into the ephemeral mode:

    $ tl container ephemeral -n chef-client
    [TL] TestLab v1.1.0 Loaded
    [TL] container chef-client ephemeral                         # Completed in 17.3453 seconds!
    [TL] TestLab v1.1.0 Finished (17.8546 seconds)

Now with our container in the ephemeral mode, we can run all of the normal container tasks against it with one simple caveat.  When you offline the container and bring it back online, it will be reverted to the original state it was in before you put it into the ephemeral mode.  The short of all this is, you can do what you will to the container, but the moment you bounce it (offline then online it) it reverts.  This, as you can imagine, is extremely useful for developing applications and infrastructure as code.

You can quickly revert that chef node back to it's previous state in the event the cookbook you are developing has wrecked the node.  For web developers, imagine having a mysql server running in an ephemeral container; you can quickly roll back all database operations just by bouncing the container.

This is effectively transactions for infrastructure.

To put the container back into the default, persistent mode:

    $ tl container persistent -n chef-client
    [TL] TestLab v1.1.0 Loaded
    [TL] container chef-client persistent                        # Completed in 17.3692 seconds!
    [TL] TestLab v1.1.0 Finished (17.8692 seconds)


## Network Routes

TestLab will add network routes for any networks defined in the `Labfile` witch have the `TestLab::Provisioner::Route` provisioner class specified for them.  This will allow you to directly interact with containers over the network.  Here is an example of the routes added with the multi-network `Labfile`.

    $ tl network route show
    [TL] TestLab v1.1.0 Loaded
    TestLab routes:
    172.16.0.0      192.168.33.2    255.255.255.0   UG        0 0          0 vboxnet0
    [TL] TestLab v1.1.0 Finished (0.5063 seconds)

These routes can be manually manipulated as well (regardless of if you have specified the `TestLab::Provisioner::Route` provisioner class for the networks via the `Labfile`):

    $ tl help network route
    NAME
        route - Manage routes

    SYNOPSIS
        tl [global options] network route  add
        tl [global options] network route  del
        tl [global options] network route  show

    COMMANDS
        add  - Add routes to lab networks
        del  - Delete routes to lab networks
        show - Show routes to lab networks

# Using TestLab Programmatically

Accessing TestLab via code is meant to be fairly easy and straightforward.  To get an instance of TestLab you only need about four lines of code:

    log_file = File.join(Dir.pwd, "testlab.log")
    @logger = ZTK::Logger.new(log_file)
    @ui = ZTK::UI.new(:logger => @logger)
    @testlab = TestLab.new(:ui => @ui)

Calling `TestLab.new` without a `:labfile` option will, by default, attempt to read `Labfile` from the current directory.  This behavior can be changed by passing the `:labfile` key with a path to your desired "Labfile" as the value to your `TestLab.new`.

There are several easy accessors available to grab the first container and execute the command `uptime` on it via and SSH connection:

    container = @testlab.containers.first
    container.exec(%(uptime))

We can also execute this command via `lxc-attach`:

    container.lxc.attach(%(-- uptime))

You can access all the nodes for example:

    @testlab.nodes

For more information see the TestLab Documentation, `testlab-repo`, command-line binary and it never hurts to look at the TestLab source itself.

# REQUIREMENTS

* Latest VirtualBox Package
* Latest Vagrant Package (non-gem version)
* Ubuntu 13.04 Base Box Recommended

* Ubuntu 13.04 Server 64-bit (Raring) Base Box - https://github.com/zpatten/raring64

# EXAMPLE USE

* See the `testlab-repo` - https://github.com/lookout/testlab-repo

# RUBIES TESTED AGAINST

* Ruby 1.8.7 (REE)
* Ruby 1.8.7 (MBARI)
* Ruby 1.9.2
* Ruby 1.9.3
* Ruby 2.0.0

# RESOURCES

IRC:

* #jovelabs on irc.freenode.net

Documentation:

* http://lookout.github.io/testlab/

Source:

* https://github.com/lookout/testlab

Issues:

* https://github.com/lookout/testlab/issues

# LICENSE

TestLab - A framework for building lightweight virtual laboratories using LXC

* Author: Zachary Patten <zachary AT jovelabs DOT com> [![endorse](http://api.coderwall.com/zpatten/endorsecount.png)](http://coderwall.com/zpatten)
* Copyright: Copyright (c) Zachary Patten
* License: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
