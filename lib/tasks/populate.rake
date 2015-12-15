namespace :populate do
  desc "Loads all classes for the current semester"
  task load_current: [:environment, :log_to_stdout] do
    Course.load_all!
  end
end
