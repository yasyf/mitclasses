module MitClassWorkers
  class EvaluationWorker
    include Sidekiq::Worker

    def perform(id)
      Evaluation.load! MitClass.find(id)
    end
  end
end
