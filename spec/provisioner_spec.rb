require "spec_helper"

describe TestLab::Provisioner do

  subject { TestLab::Provisioner.new }

  describe "class" do

    it "should be an instance of TestLab::Provisioner" do
      subject.should be_an_instance_of TestLab::Provisioner
    end

  end

end
