module HTTP
  class CourseRoad
    include HTTParty
    base_uri 'https://courseroad.mit.edu'

    CSRF_TOKEN_REGEX = /(\w{128})/
    CLASSES_KEY = 'classes'

    def initialize
      setup_session
    end

    def hash(hash)
      JSON.parse(ajax(hash).body)[CLASSES_KEY]
    end

    private

    def setup_session
      response = self.class.get("/#{rand(1000)}")
      @token = CSRF_TOKEN_REGEX.match(response.body)[1]
      @cookies = response.request.options[:headers]["Cookie"]
    end

    def ajax(hash)
      self.class.post('/ajax.php',
        body: { hash: hash, csrf: @token, getHash: 1 },
        headers: { 'Cookie' =>  @cookies }
      )
    end
  end
end
