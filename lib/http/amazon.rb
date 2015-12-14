module HTTP
  class Amazon
    def initialize(associate_tag = nil)
      @request = Vacuum.new
      @request.associate_tag = associate_tag || ENV['ASSOCIATE_TAG']
      @stoplight = Stoplight(self.class) { @request.item_search query: @query }
                    .with_fallback { |e| Rails.logger.warn e; nil }
                    .with_threshold(1)
                    .with_timeout(1)
    end

    def textbook(textbook)
      query = make_request Title: textbook.title, Author: textbook.author, SearchIndex: 'Books'
      results = query.parse['ItemSearchResponse']['Items']['Item'] if query.present?
      result = results.is_a?(Array) ? results.first : results
    end

    private

    def make_request(query)
      @query = query
      @stoplight.run
    end
  end
end
