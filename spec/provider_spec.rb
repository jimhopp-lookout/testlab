require "spec_helper"

describe TestLab::Provider do

  subject { TestLab::Provider.new }

  describe "class" do

    it "should be an instance of TestLab::Provider" do
      subject.should be_an_instance_of TestLab::Provider
    end

  end

end
