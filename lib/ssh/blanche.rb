module SSH
  class Blanche < Remote
    def initialize(lists, opts)
      @queue = Array.wrap(lists)
      @users = Set.new
      @searched = Set.new
      @opts = opts
      super
    end

    def search
      while list = @queue.pop
        next if @searched.include?(list)
        @searched.add list

        Rails.logger.info "fetching #{list}"

        lists, users = fetch(list)
        @queue += lists.reject { |l| @searched.include?(l) }
        @users += users.reject { |u| @users.include?(u) }.each { |u| yield u if block_given? }
      end
      destroy if @opts[:auto_destroy]
    end

    def results
      destroy
      @users
    end

    private

    def fetch(list)
      list_query = @ssh.exec!("blanche -l #{list}")
      user_query = @ssh.exec!("blanche -u #{list}")

      lists = if list_query.include?(':')
        []
      else
        list_query.split("\n").map { |l| l[5..-1] }
      end

      users = if user_query.include?(':')
        []
      else
        user_query.split("\n")
      end

      [lists, users]
    end
  end
end
