class Course < ActiveRecord::Base
  has_many :classes, class_name: 'MitClass'

  validates :number, presence: true, uniqueness: true

  def to_s
    number
  end

  def load!(semester = Semester.current)
    self.class.load! HTTP::Coursews.new(semester, self).classes, semester
  end

  def self.load_all!(semester = Semester.current)
    load! HTTP::Coursews.new(semester).classes, semester
  end

  def self.load!(raw_classes, semester)
    raw_classes.each do |raw_class|
      next unless id = raw_class[HTTP::Coursews::MIT_CLASS_KEY]
      semester.classes.where(number: id).first_or_create!.populate! raw_class
    end
    raw_classes.each do |raw_class|
      next unless id = raw_class['section-of']
      section_id = raw_class[HTTP::Coursews::SECTION_KEY]
      mit_class = semester.classes.where(number: id).first
      mit_class.sections.where(number: section_id).first_or_create!.populate! raw_class
    end
  end
end
