module HTTP
  class Year < Scraped
    domain 'web.mit.edu'
    ssl false

    YEAR_REGEX = /year: (\d)\n/

    def year(kerberos)
      get '/bin/cgicso', options: :general, query: kerberos
      pre = at('//*[@id="main"]/table/tr[7]/td[3]/table[1]/tr/td/pre').first
      if match = YEAR_REGEX.match(pre)
        match[1].to_i
      end
    end
  end
end
