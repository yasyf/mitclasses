module SSH
  class Remote
    HOST = 'athena.dialup.mit.edu'

    def initialize(*args, **kwargs)
      initialize_ssh
    end

    def destroy
      @ssh.close
    rescue IOError
    end

    private

    def initialize_ssh
      @ssh = Net::SSH.start(HOST, ENV['MIT_USERNAME'], password: ENV['MIT_PASSWORD'])
    end
  end
end
