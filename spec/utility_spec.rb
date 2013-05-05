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

describe TestLab::Utility do

  subject { TestLab::Utility }

  describe "class" do

    it "should be TestLab::Utility" do
      subject.should be TestLab::Utility
    end

  end

  describe "methods" do

    describe "#cidr_octets" do
      context "with CIDR 0" do
        it "should return the correct number of octets based on our CIDR" do
          address = "192.168.0.254/0"
          subject.cidr_octets(address).should be_kind_of(Array)
          subject.cidr_octets(address).should_not be_empty
          subject.cidr_octets(address).should == ["192", "168", "0", "254"]
        end
      end

      context "with CIDR 8" do
        it "should return the correct number of octets based on our CIDR" do
          address = "192.168.0.254/8"
          subject.cidr_octets(address).should be_kind_of(Array)
          subject.cidr_octets(address).should_not be_empty
          subject.cidr_octets(address).should == ["168", "0", "254"]
        end
      end

      context "with CIDR 16" do
        it "should return the correct number of octets based on our CIDR" do
          address = "192.168.0.254/16"
          subject.cidr_octets(address).should be_kind_of(Array)
          subject.cidr_octets(address).should_not be_empty
          subject.cidr_octets(address).should == ["0", "254"]
        end
      end

      context "with CIDR 24" do
        it "should return the correct number of octets based on our CIDR" do
          address = "192.168.0.254/24"
          subject.cidr_octets(address).should be_kind_of(Array)
          subject.cidr_octets(address).should_not be_empty
          subject.cidr_octets(address).should == ["254"]
        end
      end
    end

    describe "#arpa_octets" do
      context "with CIDR 0" do
        it "should return the correct number of octets based on our CIDR" do
          address = "192.168.0.254/0"
          subject.arpa_octets(address).should be_kind_of(Array)
          subject.arpa_octets(address).should be_empty
          subject.arpa_octets(address).should == []
        end
      end

      context "with CIDR 8" do
        it "should return the correct number of octets based on our CIDR" do
          address = "192.168.0.254/8"
          subject.arpa_octets(address).should be_kind_of(Array)
          subject.arpa_octets(address).should_not be_empty
          subject.arpa_octets(address).should == ["192"]
        end
      end

      context "with CIDR 16" do
        it "should return the correct number of octets based on our CIDR" do
          address = "192.168.0.254/16"
          subject.arpa_octets(address).should be_kind_of(Array)
          subject.arpa_octets(address).should_not be_empty
          subject.arpa_octets(address).should == ["168", "192"]
        end
      end

      context "with CIDR 24" do
        it "should return the correct number of octets based on our CIDR" do
          address = "192.168.0.254/24"
          subject.arpa_octets(address).should be_kind_of(Array)
          subject.arpa_octets(address).should_not be_empty
          subject.arpa_octets(address).should == ["0", "168", "192"]
        end
      end
    end

  end

end
