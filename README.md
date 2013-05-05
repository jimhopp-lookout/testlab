[![Gem Version](https://badge.fury.io/rb/testlab.png)](http://badge.fury.io/rb/testlab)
[![Dependency Status](https://gemnasium.com/zpatten/testlab.png)](https://gemnasium.com/zpatten/testlab)
[![Build Status](https://secure.travis-ci.org/zpatten/testlab.png)](http://travis-ci.org/zpatten/testlab)
[![Coverage Status](https://coveralls.io/repos/zpatten/testlab/badge.png?branch=master)](https://coveralls.io/r/zpatten/testlab)
[![Code Climate](https://codeclimate.com/github/zpatten/testlab.png)](https://codeclimate.com/github/zpatten/testlab)

# TestLab

What is TestLab?  TestLab lets you iterate virtual infrastructure quickly.  Using a `Labfile` you can define how you want your virtual infrastructure laid out.  You can define multiple network segments and containers (i.e. boxen).  TestLab will then setup and teardown this virtual infrastructure as you have dictated in the `Labfile`.

TestLab can be run directly on the command-line or can be interfaced with directly via code.  Unlike the trend with some popular open-source software recently, I want you to build off this API interface and hopefully create tools I would of never dreamed up.

Accessing TestLab via code is meant to be fairly easy and straightforward.  To get an instance of TestLab you only need about four lines of code:

    log_file = File.join(Dir.pwd, "testlab.log")
    @logger = ZTK::Logger.new(log_file)
    @ui = ZTK::UI.new(:logger => @logger)
    @testlab = TestLab.new(:ui => @ui)

Calling `TestLab.new` without a `:labfile` option will, by default, attempt to read `Labfile` from the current directory.  This behaviour can be changed by passing the `:labfile` key with a path to your desired "Labfile" as the value to your `TestLab.new`.

For more information see the TestLab Documentation, `testlab-repo`, command-line binary and it never hurts to look at the TestLab source itself.

# REQUIREMENTS

* Latest VirtualBox Package
* Latest Vagrant Package (non-gem version)
* Ubuntu 13.04 Recommended; 12.10 Minimum

* Ubuntu 13.04 Server 64-bit (Raring) Base Box - https://github.com/zpatten/raring64
* Ubuntu 12.10 Server 64-bit (Quantal) Base Box - https://github.com/zpatten/quantal64

# EXAMPLE USE

* See the `testlab-repo` - https://github.com/zpatten/testlab-repo

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
