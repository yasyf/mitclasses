namespace :recommend do
  desc "Recommend 5 classes for each of the provided users"
  task :sample, [:kerberoses] => [:environment, :log_to_stdout] do |_, args|
    args[:kerberoses].split.each do |kerberos|
      schedule = Schedule.for_student(kerberos)
      [Semester.current, Semester.next].each do |semester|
        suggestions = schedule.semester(semester).suggestions.take(5).map(&:number)
        Rails.logger.info "[#{kerberos}] [#{semester.to_s}] #{suggestions.join(', ')}"
      end
    end
    Schedule.clustering.destroy
  end
end
