class Textbook < ActiveRecord::Base
  CONNECTION = HTTP::Textbooks.new
  AMAZON = HTTP::Amazon.new

  belongs_to :mit_class

  def self.load!(mit_class)
    CONNECTION.textbooks(mit_class).each do |textbook|
      textbook = where(mit_class: mit_class, title: textbook['title']).first_or_create! textbook
      result = AMAZON.textbook(textbook)
      textbook.update!(asin: result['ASIN']) if result.present?
    end
  end
end
