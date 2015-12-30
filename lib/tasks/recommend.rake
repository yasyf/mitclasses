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
    Schedule.learning.destroy
  end

  desc "Train classifier on the provided user"
  task :train, [:kerberos] => [:environment, :log_to_stdout] do |_, args|
    schedule = Schedule.for_student(args[:kerberos])
    suggestions = schedule.semester(Semester.current).suggestions
    while suggestion = suggestions.next
      puts "#{suggestion.number} #{suggestion.name}"
      puts suggestion.description
      print '> '
      if (response = STDIN.gets.chomp.upcase).present?
        schedule.feedback! suggestion, response == 'Y'
      end
    end
  end
end
