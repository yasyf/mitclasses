class Textbook < ActiveRecord::Base
  include Concerns::SafeJson

  belongs_to :mit_class

  def self.load!(mit_class)
    HTTP::Textbooks.new.textbooks(mit_class).each do |textbook|
      textbook = where(mit_class: mit_class, title: textbook['title']).first_or_create! textbook
      result = HTTP::Amazon.new.textbook(textbook)
      textbook.update!(asin: result['ASIN']) if result.present?
    end
  end
end
