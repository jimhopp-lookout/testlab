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

  subject { @testlab = TestLab.new(:labfile => LABFILE); @testlab.containers.first }

  describe "class" do

    it "should be an instance of TestLab::Container" do
      subject.should be_an_instance_of TestLab::Container
    end

  end

  describe "methods" do

    describe "domains" do
      it "should return the domains for all defined containers" do
        subject.class.domains.should be_kind_of(Array)
        subject.class.domains.should_not be_empty
        subject.class.domains.should == ["default.zone"]
      end
    end

    describe "#status" do
      it "should return a hash of status information about the container" do
        subject.lxc.stub(:state) { :not_created }
        subject.status.should be_kind_of(Hash)
        subject.status.should_not be_empty
      end
    end

    describe "#lxc" do
      it "should return an instance of LXC::Container configured for this container" do
        subject.lxc.should be_kind_of(LXC::Container)
        subject.lxc.should_not be_nil
      end
    end

    describe "#create" do
      it "should create the container" do
        subject.lxc.config.stub(:save) { true }
        subject.stub(:detect_arch) { "amd64" }
        subject.lxc.stub(:create) { true }
        subject.create
      end
    end

    describe "#destroy" do
      it "should destroy the container" do
        subject.lxc.stub(:destroy) { true }
        subject.destroy
      end
    end

    describe "#up" do
      it "should up the container" do
        subject.lxc.stub(:start) { true }
        subject.lxc.stub(:wait) { true }
        subject.lxc.stub(:state) { :running }
        subject.up
      end
    end

    describe "#down" do
      it "should down the container" do
        subject.lxc.stub(:stop) { true }
        subject.lxc.stub(:wait) { true }
        subject.lxc.stub(:state) { :stopped }
        subject.down
      end
    end

  end

end
