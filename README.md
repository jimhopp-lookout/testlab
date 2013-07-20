[![Gem Version](https://badge.fury.io/rb/testlab.png)](http://badge.fury.io/rb/testlab)
[![Dependency Status](https://gemnasium.com/zpatten/testlab.png)](https://gemnasium.com/zpatten/testlab)
[![Build Status](https://secure.travis-ci.org/zpatten/testlab.png)](http://travis-ci.org/zpatten/testlab)
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

You can individually online, offline, create or destroy containers:

    tl container down -n server-www-1
    tl container up -n server-www-1
    tl container provision -n server-www-1
    tl container deprovision -n server-www-1

You can recycle a container, effectively destroying then creating it again, provisioning it back to a "pristine" condition.

    tl container recycle -n server-www-1

## Ephemeral Container Cloning

As it stands attempting to iterate infrastructure with Vagrant is a slow and painful process.  Enter LXC and ephemeral cloning.  The idea here is that you have a container that is provisioned to a "pristine" state according to the `Labfile`.  You then clone this container and run actions against the container.  After running your actions against the container you want to maybe tweak your Chef cookbook, for example, and re-run it against the container.  Running an ever changing cookbook in development against the same system over and over again causes drift and problems.  With the cloning you can instantly reinstate the container as it was when you first cloned it.

Here we are cloning the container for the first time.  It takes a bit longer than normal because TestLab is actually shutting down the container so it can be retained as the "pristine" copy of it, and starting up a ephemeral container in its place.  Subsequent calls to clone are very fast.

    $ tl container clone -n server-www-1
    [TL] TestLab v0.6.1 Loaded
    [TL] container server-www-1 clone                            # Completed in 13.0116 seconds!
    $ tl container clone -n server-www-1
    [TL] TestLab v0.6.1 Loaded
    [TL] container server-www-1 clone                            # Completed in 0.9169 seconds!
    $ tl container clone -n server-www-1
    [TL] TestLab v0.6.1 Loaded
    [TL] container server-www-1 clone                            # Completed in 1.0794 seconds!
    $ tl container clone -n server-www-1
    [TL] TestLab v0.6.1 Loaded
    [TL] container server-www-1 clone                            # Completed in 1.0281 seconds!

The idea in the above example is that you run the initial clone command to put your container into an ephemeral clone state.  You would then modify the container in some fashion, test, etc.  When you where done with that iteration you would run the clone command again, losing all the changes you did to the container, replacing it with a new clean cloned copy of your original container.  RRP (Rinse, Repeat, Profit)

We can also see the containers status reflects that it is a clone currently:

    $ tl container status -n server-www-1
    [TL] TestLab v0.6.1 Loaded
    +----------------------------------------------+
    |       NODE_ID: vagrant                       |
    |            ID: server-www-1                  |
    |         CLONE: true                          |
    |          FQDN: server-www-1.default.zone     |
    |         STATE: running                       |
    |        DISTRO: ubuntu                        |
    |       RELEASE: precise                       |
    |    INTERFACES: labnet:eth0:10.10.0.21/16     |
    |  PROVISIONERS: Resolv/AptCacherNG/Apt/Shell  |
    +----------------------------------------------+

We can easily revert it back to a full container if we want to make "permanent" changes to it:

    $ tl container up -n server-www-1

We can even recycle it while it is in a cloned state:

    $ tl container recycle -n server-www-1

We can run provision against a clone as well (note: running `build`, calls `up`, which would revert us back to a non-cloned container and we would not want this to happen):

    $ tl container provision -n server-www-1

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

* See the `testlab-repo` - https://github.com/zpatten/testlab-repo

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

* http://zpatten.github.io/testlab/

Source:

* https://github.com/zpatten/testlab

Issues:

* https://github.com/zpatten/testlab/issues

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
