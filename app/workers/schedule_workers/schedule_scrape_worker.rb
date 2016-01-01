module ScheduleWorkers
  class ScheduleScrapeWorker
    include Sidekiq::Worker

    def perform(kerberos)
      Schedule.for_student(kerberos)
    end
  end
end
