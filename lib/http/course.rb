module HTTP
  class Course < Scraped
    BAD_DOMAINS = %w(stellar scripts scripts-cert).map { |d| "#{d}.mit.edu" }

    ssl false
    domain 'course.mit.edu'

    def class_site(mit_class)
      get "a/#{mit_class.number}"
      click_link { |l| !BAD_DOMAINS.include?(l.uri.host) }
      uri
    end
  end
end
