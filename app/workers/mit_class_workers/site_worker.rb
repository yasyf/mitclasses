module MitClassWorkers
  class SiteWorker
    include Sidekiq::Worker

    def perform(id)
      MitClass.find(id).send(:set_site!)
    end
  end
end
