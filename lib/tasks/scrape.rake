namespace :scrape do
  desc "Scrapes CourseRoad for all known students"
  task :courseroad, [:lists] => [:environment, :log_to_stdout] do |_, args|
    blanche = SSH::Blanche.new args[:lists].split, auto_destroy: true
    blanche.search do |kerberos|
      Rails.logger.info "Scraping CourseRoad for #{kerberos}"
      ScheduleWorkers::ScheduleScrapeWorker.perform_async kerberos
    end
  end
end
