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

describe TestLab::Container do

  subject {
    @ui = ZTK::UI.new(:stdout => StringIO.new, :stderr => StringIO.new)
    @testlab = TestLab.new(:repo_dir => REPO_DIR, :labfile_path => LABFILE_PATH, :ui => @ui)
    @testlab.boot
    @testlab.containers.first
  }

  describe "class" do

    it "should be an instance of TestLab::Container" do
      subject.should be_an_instance_of TestLab::Container
    end

    describe "methods" do

      describe "domains" do
        it "should return the domains for all defined containers" do
          subject.class.domains.should be_kind_of(Array)
          subject.class.domains.should_not be_empty
          subject.class.domains.should == ["default.zone"]
        end
      end

    end

  end

  describe "methods" do

    describe "#status" do
      it "should return a hash of status information about the container" do
        subject.lxc.stub(:state) { :not_created }
        subject.lxc_clone.stub(:exists?) { false }
        subject.status.should be_kind_of(Hash)
        subject.status.should_not be_empty
      end
    end

    describe "#state" do
      it "should return the state of the container" do
        subject.lxc.stub(:state) { :not_created }
        subject.state.should == :not_created
      end
    end

    describe "#fqdn" do
      it "should return the FQDN for the container" do
        subject.fqdn.should == "server-dual-nic.default.zone"
      end
    end

    describe "#ip" do
      it "should return the IP address of the containers primary interface" do
        subject.ip.should == "192.168.0.254"
      end
    end

    describe "#cidr" do
      it "should return the CIDR of the containers primary interface" do
        subject.cidr.should == 16
      end
    end

    describe "#ptr" do
      it "should return a BIND PTR record for the containers primary interface" do
        subject.ptr.should be_kind_of(String)
        subject.ptr.should_not be_empty
        subject.ptr.should == "254.0"
      end
    end

    describe "#lxc" do
      it "should return an instance of LXC::Container configured for this container" do
        subject.lxc.should_not be_nil
        subject.lxc.should be_kind_of(LXC::Container)
      end
    end

    describe "#ssh" do
      it "should return an instance of ZTK::SSH configured for this container" do
        subject.ssh.should_not be_nil
        subject.ssh.should be_kind_of(ZTK::SSH)
      end
    end

    describe "#exists?" do
      it "should return false for a non-existant container" do
        subject.lxc.stub(:exists?) { false }
        subject.exists?.should == false
      end
    end

    describe "#detect_arch" do
      it "should return the appropriate disto dependent machine architecture for our lxc-template" do
        subject.node.stub(:arch) { "x86_64" }
        subject.detect_arch.should == "amd64"
      end
    end

    describe "#primary_interface" do
      it "should return the primary interface for a container" do
        subject.primary_interface.should_not be_nil
        subject.primary_interface.should be_kind_of(TestLab::Interface)

        @testlab.containers.last.primary_interface.should_not be_nil
        @testlab.containers.last.primary_interface.should be_kind_of(TestLab::Interface)
      end
    end

    describe "#generate_ip" do
      it "should generate a random RFC compliant private IP address" do
        subject.generate_ip.should_not be_nil
        subject.generate_ip.should be_kind_of(String)
      end
    end

    describe "#generate_mac" do
      it "should generate a random RFC compliant private MAC address" do
        subject.generate_mac.should_not be_nil
        subject.generate_mac.should be_kind_of(String)
      end
    end

    describe "#create" do
      it "should create the container" do
        subject.node.stub(:state) { :running }
        subject.lxc.config.stub(:save) { true }
        subject.stub(:detect_arch) { "amd64" }
        subject.lxc.stub(:create) { true }
        subject.lxc.stub(:state) { :not_created }
        subject.lxc_clone.stub(:exists?) { false }
        subject.node.ssh.stub(:exec)

        subject.create
      end
    end

    describe "#destroy" do
      it "should destroy the container" do
        subject.node.stub(:state) { :running }
        subject.lxc.stub(:exists?) { true }
        subject.lxc.stub(:state) { :stopped }
        subject.lxc.stub(:destroy) { true }
        subject.lxc_clone.stub(:exists?) { false }

        subject.destroy
      end
    end

    describe "#up" do
      it "should up the container" do
        subject.node.stub(:state) { :running }
        subject.lxc.stub(:exists?) { true }
        subject.lxc.stub(:start) { true }
        subject.lxc.stub(:wait) { true }
        subject.lxc.stub(:state) { :running }
        subject.lxc.stub(:attach)

        subject.lxc_clone.stub(:exists?) { false }

        subject.up
      end
    end

    describe "#down" do
      it "should down the container" do
        subject.node.stub(:state) { :running }
        subject.lxc.stub(:exists?) { true }
        subject.lxc.stub(:stop) { true }
        subject.lxc.stub(:wait) { true }
        subject.lxc.stub(:state) { :stopped }
        subject.down
      end
    end

    describe "#provision" do
      context "with no provisioner" do
        it "should provision the container" do
          subject.node.stub(:state) { :running }
          subject.lxc.stub(:exists?) { true }
          subject.lxc.stub(:state) { :stopped }
          subject.stub(:provisioners) { Array.new }

          subject.provision
        end
      end

      context "with the shell provisioner" do
        it "should provision the container" do
          subject and (subject = TestLab::Container.first('server-shell'))

          subject.node.stub(:state) { :running }
          subject.lxc.stub(:exists?) { true }
          subject.lxc.stub(:state) { :stopped }
          subject.stub(:provisioners) { Array.new }

          subject.provision
        end
      end
    end

    describe "#deprovision" do
      context "with no provisioner" do
        it "should deprovision the container" do
          subject.node.stub(:state) { :running }
          subject.lxc.stub(:exists?) { true }
          subject.lxc.stub(:state) { :stopped }
          subject.stub(:provisioners) { Array.new }

          subject.deprovision
        end
      end

      context "with the shell provisioner" do
        it "should deprovision the container" do
          subject and (subject = TestLab::Container.first('server-shell'))

          subject.node.stub(:state) { :running }
          subject.lxc.stub(:exists?) { true }
          subject.lxc.stub(:state) { :stopped }
          subject.stub(:provisioners) { Array.new }

          subject.deprovision
        end
      end

    end

  end

end
