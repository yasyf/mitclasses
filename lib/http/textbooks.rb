module HTTP
  class Textbooks < Scraped
    PROPERTIES = %w(author title publisher isbn retail)

    ssl false
    domain 'eduapps.mit.edu'

    def textbooks(mit_class)
      get 'textbook/books.html', Term: mit_class.semester, Subject: mit_class.number
      clean_textbooks extract_textbooks
    end

    private

    def clean_textbooks(textbooks)
      textbooks.each do |textbook|
        textbook["publisher"] = textbook["publisher"].split(') ').last
        textbook["isbn"] = textbook["isbn"].to_i
        textbook["retail"] = textbook["retail"][1..-1].to_f
      end
    end

    def extract_textbooks
      at('//table[@class="displayTable"][1]/tbody').search('tr').map do |row|
        columns = row.search('td')
        textbook = {}
        PROPERTIES.each_with_index do |prop, index|
          textbook[prop] = columns[index].text
        end
        textbook["isbn"].to_i > 0 ? textbook : nil
      end.compact
    end
  end
end
