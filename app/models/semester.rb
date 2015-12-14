class Semester < ActiveRecord::Base
  has_many :classes, class_name: 'MitClass'

  validates :year, presence: true, numericality: { greater_than: 2000, less_than: 3000 }
  validates :season, presence: true, uniqueness: { scope: :year }

  enum season: [:fall, :spring, :iap]

  def to_s
    year.to_s + case season.to_sym
    when :fall
      'FA'
    when :spring
      'SP'
    when :iap
      'IAP'
    end
  end

  def last
    if fall?
      self.class.where(season: self.class.seasons[:spring], year: year)
    elsif spring?
      self.class.where(season: self.class.seasons[:fall], year: year - 1)
    end.first_or_create!
  end

  def next
    if fall?
      self.class.where(season: self.class.seasons[:spring], year: year + 1)
    elsif spring?
      self.class.where(season: self.class.seasons[:fall], year: year)
    end.first_or_create!
  end

  def self.next(today = Date.today)
    last(today + 1.year)
  end

  def self.current(today = Date.today)
    if today.month <= 6
      where season: seasons[:spring], year: today.year
    else
      where season: seasons[:fall], year: today.year
    end.first_or_create!
  end

  def self.last(today = Date.today)
    if today.month <= 6
      where season: seasons[:fall], year: today.year - 1
    else
      where season: seasons[:spring], year: today.year
    end.first_or_create!
  end
end
