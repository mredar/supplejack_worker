require 'spec_helper'

describe HarvestSchedulesController do

  let(:schedule) { mock_model(HarvestSchedule).as_null_object }

  before(:each) do
    controller.stub(:authenticate_user!) { true }
  end

  describe "GET 'index'" do
    it "should return all the harvest schedules" do
      HarvestSchedule.should_receive(:all) { [schedule] }
      get :index
      assigns(:harvest_schedules).should eq [schedule]
    end
  end

  describe "GET show" do
    before(:each) do
      HarvestSchedule.stub(:find).with("1") { schedule }
    end

    it "finds the harvest schedule" do
      HarvestSchedule.should_receive(:find).with("1") { schedule }
      get :show, id: 1
      assigns(:harvest_schedule).should eq schedule
    end
  end

  describe "POST 'create'" do
    before(:each) do
      HarvestSchedule.stub(:new) { schedule }
    end

    it "creates a new harvest schedule" do
      HarvestSchedule.should_receive(:create).with({"cron" => "* * * * *"}) { schedule }
      post :create, harvest_schedule: {cron: "* * * * *"}
      assigns(:harvest_schedule).should eq schedule
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      HarvestSchedule.stub(:find).with("1") { schedule }
    end

    it "finds the harvest schedule" do
      HarvestSchedule.should_receive(:find).with("1") { schedule }
      put :update, id: 1
      assigns(:harvest_schedule).should eq schedule
    end

    it "should update the attributes" do
      schedule.should_receive(:update_attributes).with({"cron" => "* * * * *"})
      put :update, id: 1, harvest_schedule: {cron: "* * * * *"}
    end
  end

  describe "GET 'destroy'" do
    before(:each) do
      HarvestSchedule.stub(:find).with("1") { schedule }
    end

    it "finds the harvest schedule" do
      HarvestSchedule.should_receive(:find).with("1") { schedule }
      delete :destroy, id: 1
      assigns(:harvest_schedule).should eq schedule
    end

    it "should destroy the schedule" do
      schedule.should_receive(:destroy)
      delete :destroy, id: 1
    end
  end

end