require "snippet"

class HarvestWorker
  include Sidekiq::Worker

  def perform(harvest_job_id)
    job = HarvestJob.find(harvest_job_id)
    job.start!

    begin
      parser = job.parser
      parser.load_file
      records = parser.loader.parser_class.records(limit: job.limit.to_i > 0 ? job.limit : nil)
      records.each do |record|
        self.process_record(record, job)
        return if self.stop_harvest?(job)
      end
    rescue StandardError => e
      job.harvest_job_errors.create(exception_class: e.class, message: e.message, backtrace: e.backtrace[0..5])
    end

    job.finish!
  end

  def process_record(record, job)
    begin
      self.post_to_api(record)
    rescue StandardError => e
      job.harvest_job_errors.build(exception_class: e.class, message: e.message, backtrace: e.backtrace[0..5])
    end
    job.records_harvested += 1
    job.save
  end

  def post_to_api(record)
    attributes = record.attributes

    measure = Benchmark.measure do
      RestClient.post "#{ENV["API_HOST"]}/harvester/records.json", {record: attributes}.to_json, :content_type => :json, :accept => :json
    end

    puts "POST (#{measure.real.round(4)}): #{attributes[:identifier].try(:first)}" unless Rails.env.test?
  end

  def stop_harvest?(job)
    job.reload

    if stop = job.stopped? || job.harvest_job_errors.count > 5
      job.finish!
    end

    stop
  end
end
