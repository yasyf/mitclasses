class Semester < ActiveRecord::Base
  has_many :classes, class_name: :MitClass

  validates :year, presence: true, numericality: { greater_than: 2000, less_than: 3000 }
  validates :season, presence: true, uniqueness: { scope: :year }

  enum season: [:fall, :spring]

  def to_s
    year.to_s + case season.to_sym
    when :fall
      'FA'
    when :spring
      'SP'
    end
  end

  def self.next(today = Date.today)
    last(today + 1.year)
  end

  def self.current(today = Date.today)
    case today.month
    when 1..3
      where season: seasons[:spring], year: today.year
    when 4..11
      where season: seasons[:fall], year: today.year + 1
    when 12
      where season: seasons[:spring], year: today.year + 1
    end.first_or_create!
  end

  def self.last(today = Date.today)
    case today.month
    when 1..3
      where season: seasons[:fall], year: today.year
    when 4..11
      where season: seasons[:spring], year: today.year
    when 12
      where season: seasons[:fall], year: today.year + 1
    end.first_or_create!
  end
end
