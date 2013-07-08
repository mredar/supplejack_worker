require 'spec_helper'

describe LinkCheckJob do
  let(:link_check_job) { FactoryGirl.build(:link_check_job, url: "http://google.co.nz") }
  
  describe "validations" do
    it "should validates the presence of url" do
      link_check_job.url = nil
      link_check_job.should_not be_valid
    end

    it "should validates the presence of record_id" do
      link_check_job.record_id = nil
      link_check_job.should_not be_valid
    end
  end

  describe "after:create" do
    after { link_check_job.save }
    
    it "should call enqueue" do
      link_check_job.should_receive(:enqueue)
    end
  end

  describe "#enqueue" do
    it "enqueues a job" do
      LinkCheckWorker.should_receive(:perform_async).with(link_check_job.id)
      link_check_job.send(:enqueue)
    end
  end
end