module Ssh
  class Blanche
    HOST = 'athena.dialup.mit.edu'

    def initialize(list)
      @queue = [list]
      @users = Set.new
      @searched = Set.new
      initialize_ssh
    end

    def search
      while list = @queue.pop
        next if @searched.include?(list)
        @searched.add list

        Rails.logger.info "fetching #{list}"

        lists, users = fetch(list)
        @queue += lists
        @users |= users
      end
    end

    def results
      destroy
      @users
    end

    private

    def destroy
      @ssh.close
    rescue IOError
    end

    def initialize_ssh
      @ssh = Net::SSH.start(HOST, ENV['MIT_USERNAME'], password: ENV['MIT_PASSWORD'])
    end

    def fetch(list)
      lists = @ssh.exec!("blanche -l #{list}").split("\n").map { |l| l[5..-1] }
      users = @ssh.exec!("blanche -u #{list}").split("\n")
      [lists, users]
    end
  end
end
