require "spec_helper"

describe TestLab do

  subject { TestLab.new(LABFILE) }

  describe "class" do

    it "should be an instance of TestLab" do
      subject.should be_an_instance_of TestLab
    end

  end


end
