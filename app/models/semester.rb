class Semester < ActiveRecord::Base
  include Concerns::SafeJson

  has_many :classes, class_name: 'MitClass'

  validates :year, presence: true, numericality: { greater_than: 2000, less_than: 3000 }
  validates :season, presence: true, uniqueness: { scope: :year }

  enum season: [:fall, :spring, :iap]

  def mit_class(number)
    class_scope(number).first!
  end

  def mit_class!(number)
    mit_class(number)
  rescue ActiveRecord::RecordNotFound
    class_scope(number).first_or_create!.populate!
  end

  def last
    if fall?
      self.class.where(season: self.class.seasons[:spring], year: year - 1)
    elsif spring?
      self.class.where(season: self.class.seasons[:fall], year: year)
    end.first_or_create!
  end

  def next
    if fall?
      self.class.where(season: self.class.seasons[:spring], year: year)
    elsif spring?
      self.class.where(season: self.class.seasons[:fall], year: year + 1)
    end.first_or_create!
  end

  def self.next(today = Date.today)
    last(today + 1.year)
  end

  def self.current(today = Date.today)
    if today.month <= 6
      where season: seasons[:spring], year: today.year
    else
      where season: seasons[:fall], year: today.year + 1
    end.first_or_create!
  end

  def self.last(today = Date.today)
    if today.month <= 6
      where season: seasons[:fall], year: today.year - 1
    else
      where season: seasons[:spring], year: today.year
    end.first_or_create!
  end

  def as_json(opts = {})
    super(opts).merge(id: to_s)
  end

  def to_s(stellar: false)
    prefix = case season.to_sym
    when :fall
      'FA'
    when :spring
      'SP'
    when :iap
      'IAP'
    end
    stellar ? (prefix.downcase + year.to_s.last(2)) : (year.to_s + prefix)
  end

  def self.parse(semester)
    season = case semester.last(2).upcase
    when 'FA'
      :fall
    when 'SP'
      :spring
    when 'IAP'
      :iap
    end
    where(season: seasons[season], year: semester.first(4).to_i).first!
  end

  private

  def class_scope(number)
    classes.where(number: number)
  end
end
