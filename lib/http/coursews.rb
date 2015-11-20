module HTTP
  class Coursews
    include HTTParty
    base_uri 'coursews.mit.edu'

    def initialize(semester, course = nil)
      @options = { query: { term: semester, courses: course } }
    end

    def classes
      @classes ||= JSON.parse(self.class.get('/coursews', @options).body)['items']
    end

    def mit_class(number)
      classes.find { |c| c['id'] == number }
    end
  end
end
