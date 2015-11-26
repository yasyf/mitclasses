module HTTP
  class AuthenticationError < StandardError; end
  class Authenticated < Scraped
    def initialize(username = nil, password = nil)
      @username = username || ENV['MIT_USERNAME']
      @password = password || ENV['MIT_PASSWORD']

      raise AuthenticationError, "missing username" unless @username.present?
      raise AuthenticationError, "missing password" unless @password.present?

      super()
      login
    end

    def self.ssl(ssl)
      raise AuthenticationError, 'ssl must always be enabled' unless ssl
    end

    private

    def login
      get '/'
      case @uri.host
      when 'wayf.mit.edu'
        handle_wayf
        handle_idp
      when 'idp.mit.edu'
        handle_idp
      end
    end

    def handle_wayf
      submit
    end

    def handle_idp
      form 1
      set 'j_username', @username
      set 'j_password', @password
      submit
      submit
    end
  end
end
