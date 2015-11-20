module HTTP
  class Coursews
    include HTTParty
    base_uri 'coursews.mit.edu'

    MIT_CLASS_KEY = 'id'
    SECTION_KEY = 'label'

    def initialize(semester, course = nil)
      @options = { query: { term: semester } }
      @options[:query][:courses] = course if course.present?
    end

    def classes
      @classes ||= JSON.parse(self.class.get('/coursews', @options).body)['items']
    end

    def mit_class(number)
      classes.find { |c| c[MIT_CLASS_KEY] == number }
    end

    def section(number)
      classes.find { |c| c[SECTION_KEY] == number }
    end
  end
end
