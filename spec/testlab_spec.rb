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

describe TestLab do

  subject {
    @ui = ZTK::UI.new(:stdout => StringIO.new, :stderr => StringIO.new)
    @testlab = TestLab.new(:labfile => LABFILE, :ui => @ui)
  }

  describe "class" do

    it "should be an instance of TestLab" do
      subject.should be_an_instance_of TestLab
    end

  end

  describe "methods" do

    describe "setup" do
      it "should setup the test lab" do
        subject.stub(:dead?) { false }
        subject.nodes.each do |node|
          node.stub(:setup) { true }
        end
        subject.containers.each do |container|
          container.stub(:setup) { true }
        end
        subject.networks.each do |network|
          network.stub(:setup) { true }
        end
        subject.setup
      end
    end

    describe "teardown" do
      it "should teardown the test lab" do
        subject.stub(:dead?) { false }
        subject.nodes.each do |node|
          node.stub(:teardown) { true }
        end
        subject.containers.each do |container|
          container.stub(:teardown) { true }
        end
        subject.networks.each do |network|
          network.stub(:teardown) { true }
        end
        subject.teardown
      end
    end

    describe "up" do
      it "should online the test lab" do
        subject.stub(:dead?) { false }
        subject.nodes.each do |node|
          node.stub(:up) { true }
        end
        subject.containers.each do |container|
          container.stub(:up) { true }
        end
        subject.networks.each do |network|
          network.stub(:up) { true }
        end
        subject.up
      end
    end

    describe "down" do
      it "should offline the test lab" do
        subject.stub(:dead?) { false }
        subject.nodes.each do |node|
          node.stub(:down) { true }
        end
        subject.containers.each do |container|
          container.stub(:down) { true }
        end
        subject.networks.each do |network|
          network.stub(:down) { true }
        end
        subject.down
      end
    end

  end


end
