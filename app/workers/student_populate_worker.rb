class StudentPopulateWorker
  include Sidekiq::Worker

  def perform(id)
    Student.find(id).populate!
  end
end
