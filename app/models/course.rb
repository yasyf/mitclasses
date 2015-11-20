class Course < ActiveRecord::Base
  ALL = (1..24).to_a - [13, 19, 23] +
    ['CMS', 'CSB', 'ESD', 'HST', 'MAS', 'STS', 'CC', 'EC', 'ES', 'ROTC', 'SP', 'SWE', 'WGS']

  has_many :classes, class_name: "MitClass"

  validates :number, presence: true, uniqueness: true

  def to_s
    number
  end

  def load!(semester = Semester.current)
    HTTP::Coursews.new(semester, self).classes.each do |raw_class|
      next unless id = raw_class['id']
      semester.classes.where(number: id).first_or_create!.populate! raw_class
    end
  end

  def self.load_all!(semester = Semester.current)
    ALL.each { |c| where(number: c).first_or_create!.load!(semester) }
  end
end
