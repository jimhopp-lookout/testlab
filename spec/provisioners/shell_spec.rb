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
require "spec_helper"

describe TestLab::Provisioner::Shell do

  subject {
    @ui = ZTK::UI.new(:stdout => StringIO.new, :stderr => StringIO.new)
    @testlab = TestLab.new(:labfile => LABFILE, :ui => @ui)
    TestLab::Container.first('server-shell')
  }

  describe "class" do

    it "should be an instance of TestLab::Provisioner::Shell" do
      subject.instance_variable_get(:@provisioner).should be_an_instance_of TestLab::Provisioner::Shell
    end

  end

  describe "methods" do

    describe "setup" do
      it "should provision the container" do
        subject.node.ssh.stub(:file).and_yield(StringIO.new)
        subject.lxc.stub(:attach) { "" }
        subject.instance_variable_get(:@provisioner).setup(subject)
      end
    end

    describe "teardown" do
      it "should decomission the container" do
        subject.instance_variable_get(:@provisioner).teardown(subject)
      end
    end

  end

end
