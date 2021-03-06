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
    @testlab = TestLab.new(:repo_dir => REPO_DIR, :labfile_path => LABFILE_PATH, :ui => @ui)
    @testlab.boot
    TestLab::Container.first('server-shell')
  }

  describe "class" do

    it "should be an instance of TestLab::Provisioner::Shell" do
      subject.provisioners.last.new(subject.config, @ui).should be_an_instance_of TestLab::Provisioner::Shell
    end

  end

  describe "methods" do

    describe "provision" do
      context "bootstrap successful" do
        it "should provision the container" do
          subject.node.ssh.stub(:file).and_yield(StringIO.new)
          subject.stub(:fs_root) { "/var/lib/lxc/#{subject.id}/rootfs" }
          subject.ssh.stub(:bootstrap) { "" }
          subject.lxc.stub(:bootstrap) { "" }
          subject.lxc_clone.stub(:exists?) { false }

          p = TestLab::Provisioner::Shell.new(subject.config, @ui)
          p.on_container_provision(subject)
        end
      end

      context "bootstrap fails" do
        it "should raise an exception" do
          subject.node.ssh.stub(:file).and_yield(StringIO.new)
          subject.stub(:fs_root) { "/var/lib/lxc/#{subject.id}/rootfs" }
          subject.ssh.stub(:bootstrap) { "" }
          subject.lxc.stub(:bootstrap) { "" }
          subject.lxc_clone.stub(:exists?) { false }

          p = TestLab::Provisioner::Shell.new(Hash.new, @ui)
          lambda{ p.on_container_provision(subject) }.should raise_error TestLab::Provisioner::ShellError
        end
      end
    end

  end

end
