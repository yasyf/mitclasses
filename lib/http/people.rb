module HTTP
  class People
    include HTTParty
    base_uri 'https://m.mit.edu/apis/people'

    def person(kerberos)
      JSON.parse(self.class.get("/#{kerberos}").body)
    end
  end
end
