[![Gem Version](https://badge.fury.io/rb/testlab.png)](http://badge.fury.io/rb/testlab)
[![Dependency Status](https://gemnasium.com/zpatten/testlab.png)](https://gemnasium.com/zpatten/testlab)
[![Build Status](https://secure.travis-ci.org/zpatten/testlab.png)](http://travis-ci.org/zpatten/testlab)
[![Coverage Status](https://coveralls.io/repos/zpatten/testlab/badge.png?branch=master)](https://coveralls.io/r/zpatten/testlab)
[![Code Climate](https://codeclimate.com/github/zpatten/testlab.png)](https://codeclimate.com/github/zpatten/testlab)

# TestLab

What is TestLab?  TestLab lets you iterate virtual infrastructure quickly.  Using a `Labfile` you can define how you want your virtual infrastructure laid out.  You can define multiple network segments and containers (i.e. boxen).  TestLab will then setup and teardown this virtual infrastructure as you have dictated in the `Labfile`.

TestLab can be run directly on the command-line or can be interfaced with directly via code.  Unlike the trend with some popular open-source software recently, I want you to build off this API interface and hopefully create tools I would of never dreamed up.

# Using TestLab Programmatically

Accessing TestLab via code is meant to be fairly easy and straightforward.  To get an instance of TestLab you only need about four lines of code:

    log_file = File.join(Dir.pwd, "testlab.log")
    @logger = ZTK::Logger.new(log_file)
    @ui = ZTK::UI.new(:logger => @logger)
    @testlab = TestLab.new(:ui => @ui)

Calling `TestLab.new` without a `:labfile` option will, by default, attempt to read `Labfile` from the current directory.  This behaviour can be changed by passing the `:labfile` key with a path to your desired "Labfile" as the value to your `TestLab.new`.

There are several easy accessors available to grab the first container and execure the command `uptime` on it via and SSH connection:

    container = @testlab.containers.first
    container.ssh.exec(%(uptime))

We can also execute this command via `lxc-attach`:

    container.lxc.attach(%(-- uptime))

You can access all the nodes for example:

    @testlab.nodes

For more information see the TestLab Documentation, `testlab-repo`, command-line binary and it never hurts to look at the TestLab source itself.

# Using TestLab Interactively

The TestLab command-line program `tl` follows in the style of git (using the GLI RubyGem).

    $ tl help
    NAME
        tl - A framework for building lightweight virtual infrastructure using LXC

    SYNOPSIS
        tl [global options] command [command options] [arguments...]

    VERSION
        0.6.1

    GLOBAL OPTIONS
        --version -
        --help    - Show this message

    COMMANDS
        help      - Shows a list of commands or help for one command
        create    - Create the test lab
        destroy   - Destroy the test lab
        up        - Online the test lab
        down      - Offline the test lab
        setup     - Setup the test lab infrastructure
        teardown  - Teardown the test lab infrastructure
        status    - Display information on the status of the test lab
        node      - Manage nodes
        network   - Manage networks
        container - Manage containers

You stand up your lab with the following command:

    tl setup

You can down the entire lab:

    tl down

You can also destroy it (only works for VM backed providers; this would be a NO-OP on the Local provider for example):

    tl destroy

# Interacting with Containers

Most commands dealing will containers will take this argument:

    COMMAND OPTIONS
        -n, --name=container - Container ID or Name (default: none)

You can interact with containers via SSH:

    tl container ssh -n <container ID>

You can pass an optional alternate username and/or identity to use.  By default TestLab will attempt to SSH as the user defined in the `Labfile` for that container, otherwise the default user for the containers distro is used.

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
    tl container setup -n server-www-1
    tl container teardown -n server-www-1

You can recycle a container, effectively destroying then creating it again, provisioning it back to a "pristine" condition.

    tl container recycle -n server-www-1

# Ephemeral Container Cloning

As it stands attempting to iterate infrastructure while developing with Vagrant is a slow and painful process.  Enter LXC and it's ephemeral feature.  The idea here is you have a container that is provisioned to a "pristine" state acording to the `Labfile`.  You then clone this container and run actions against the container.  After running your actions against the container you want to maybe tweak your Chef cookbook and re-run it against the container.  As we all know running an ever changing cookbook in development against the same system over and over again causes drift and problems.  With the cloning you can instantly reinstate the container as it was when you first cloned it.

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

We can easily revert it back to a full container if we want to make changes to it:

    $ tl container up -n server-www-1

We can even recycle it while it is in a cloned state:

    $ tl container recycle -n server-www-1

# Network Routes

TestLab will add network routes for any networks defined in the `Labfile` with the route flag set to true.  This will allow you to directly interact with containers.  Here is an example of the routes added with the multi-network `Labfile`.

    $ tl network route show -n labnet
    [TL] TestLab v0.6.1 Loaded
    TestLab routes:
    10.10.0.0       192.168.33.239  255.255.0.0     UG        0 0          0 vboxnet0
    10.11.0.0       192.168.33.239  255.255.0.0     UG        0 0          0 vboxnet0

These routes can be manually manipulated as well:

    $ tl help network route
    NAME
        route - Manage routes

    SYNOPSIS
        tl [global options] network route [command options]  add
        tl [global options] network route [command options]  del
        tl [global options] network route [command options]  show

    COMMANDS
        add  - Add routes to lab networks
        del  - Delete routes to lab networks
        show - Show routes to lab networks

# Getting Help

TestLab uses the GLI RubyGem, which gives us a command line pattern similar to that of Git.  Therefore help is easy to get:

    tl help
    tl help node
    tl help container
    tl help network

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
