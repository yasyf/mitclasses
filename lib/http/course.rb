module HTTP
  class Course < Scraped
    BAD_DOMAINS = Set.new %w(stellar scripts scripts-cert).flat_map { |d| [d, "#{d}.mit.edu"] }

    ssl false
    domain 'course.mit.edu'

    def class_site(mit_class)
      get "a/#{mit_class.number}"
      potential_links(mit_class).first
    end

    private

    def potential_links(mit_class)
      links.lazy.
        map(&:uri).
        reject { |l| bad_domain?(l) }.
        reject { |l| check_head(l) }.
        select { |l| verify_link(l, mit_class) }
    end

    def check_head(l)
      response = HTTParty.head(l)
      bad_domain?(response.request.last_uri) || response.code != 200
    rescue HTTParty::Error
      true
    end

    def verify_link(l, mit_class)
      body = HTTParty.get(l).body
      parsed = Nokogiri::HTML(body)
      parsed.xpath("//meta[@http-equiv='refresh' or @http-equiv='REFRESH']").each do |meta|
        return false if bad_domain?(meta['content'].split('=').last)
      end
      body.include? mit_class.number
    rescue HTTParty::Error
      false
    end

    def bad_domain?(uri)
      uri = URI(uri) unless uri.is_a?(URI)
      BAD_DOMAINS.include?(uri.host)
    rescue URI::InvalidURIError
      true
    end
  end
end
