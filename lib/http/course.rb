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
        reject { |l| BAD_DOMAINS.include?(l.host) }.
        reject { |l| check_head(l) }.
        select { |l| verify_link(l, mit_class) }
    end

    def check_head(l)
      response = HTTParty.head(l)
      BAD_DOMAINS.include?(response.request.last_uri.host) || response.code != 200
    end

    def verify_link(l, mit_class)
      body = HTTParty.get(l).body
      parsed = Nokogiri::HTML(body)
      parsed.xpath("//meta[@http-equiv='refresh' or @http-equiv='REFRESH']").each do |meta|
        return false if BAD_DOMAINS.include?(URI(meta['content'].split('=').last).host)
      end
      body.include? mit_class.number
    end
  end
end
