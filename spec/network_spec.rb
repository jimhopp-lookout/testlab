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

describe TestLab::Network do

  subject { @testlab = TestLab.new(:labfile => LABFILE); @testlab.networks.first }

  describe "class" do

    it "should be an instance of TestLab::Network" do
      subject.should be_an_instance_of TestLab::Network
    end

  end

  describe "methods" do

    describe "ips" do
      it "should return the ips for all defined containers" do
        subject.class.ips.should be_kind_of(Array)
        subject.class.ips.should_not be_empty
      end
    end

    describe "#ptr" do
      it "should return a BIND PTR record for the networks bridge interface" do
        subject.ptr.should be_kind_of(String)
        subject.ptr.should_not be_empty
        subject.ptr.should == "254.255"
      end
    end

    describe "#arpa" do
      it "should return the ARPA network calculated from the cidr address" do
        subject.arpa.should be_kind_of(String)
        subject.arpa.should_not be_empty
        subject.arpa.should == "168.192.in-addr.arpa"
      end
    end

  end

end
