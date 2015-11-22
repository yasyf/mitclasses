module HTTP
  class AuthenticationError < StandardError; end
  class Authenticated
    def initialize(username = nil, password = nil)
      @username = username || ENV['MIT_USERNAME']
      @password = password || ENV['MIT_PASSWORD']

      raise AuthenticationError, "missing username" unless @username.present?
      raise AuthenticationError, "missing password" unless @password.present?

      @agent = Mechanize.new
      login
    end

    def self.domain(domain)
      @@domain = domain
    end

    def get(path)
      @response = @agent.get(url(path))
      update_instance_variables
    end

    def search(selector)
      @response.search selector
    end

    def click_link(&block)
      link = find_link &block
      if link.present?
        @response = link.click
        update_instance_variables
      end
    end

    def submit(button = nil)
      @response = @form.submit(button || @form.buttons.first)
      update_instance_variables
    end

    def form(n)
      @form = if n.is_a?(Mechanize::Form)
        n
      elsif n.is_a?(String)
        @response.form(n)
      elsif n.is_a?(Fixnum)
        @response.forms[n]
      end
    end

    def set(key, value)
      @form.send "#{key}=", value
    end

    private

    def find_link
      @response.links.each do |link|
        return link if yield link
      end
    end

    def update_instance_variables
      @uri = @response.uri
      @form = @response.forms.last
      @response
    end

    def url(path)
      "https://#{@@domain}/#{path}"
    end

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
