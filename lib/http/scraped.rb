module HTTP
  class Scraped
    attr_reader :uri

    @insecure = false

    def initialize(*args, **kwargs)
      @agent = Mechanize.new
    end

    def self.domain(domain)
      @domain = domain
    end

    def self.ssl(ssl)
      @insecure = !ssl
    end

    def get(path, query = nil)
      @response = @agent.get(self.class.url(path), query)
      update_instance_variables
    end

    def search(selector)
      @response.search selector
    end

    def at(selector)
      @response.search selector
    end

    def click_link(&block)
      link = find_link &block
      if link.present?
        @response = link.click
        update_instance_variables
        true
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

    def links
      @response.links
    end

    private

    def find_link
      links.each do |link|
        return link if yield link
      end
      nil
    end

    def update_instance_variables
      @uri = @response.uri
      @form = @response.forms.last
      @response
    end

    def self.url(path)
      "#{@insecure ? 'http' : 'https'}://#{@domain}/#{path}"
    end
  end
end
