require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper' )

describe Workout do
  before(:each) do
    @valid_attributes = {
      :user_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Workout.create!(@valid_attributes)
  end
end
