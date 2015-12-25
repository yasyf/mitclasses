module MitClassWorkers
  class TextbookWorker
    include Sidekiq::Worker

    def perform(id)
      Textbook.load! MitClass.find(id)
    end
  end
end
