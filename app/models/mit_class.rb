class MitClass < ActiveRecord::Base
  REGEX = /((([A-Z]{2,3})|(([1][0-2,4-8]|[2][0-2,4]|[1-9])[AWFHLM]?))\.(([S]?[0-9]{2,4}[AJ]?)|(UA[TR])))/

  belongs_to :semester
  belongs_to :course
  belongs_to :instructor

  has_many :sections
  has_many :textbooks
  has_one :evaluation

  has_and_belongs_to_many :schedules

  before_create :set_course

  validates :semester, presence: true
  validates :number, presence: true, uniqueness: true

  def populate!(raw = nil)
    raw ||= raw_data
    update short_name: raw['shortLabel'], description: raw['description'], name: raw['label']
    update hass: raw['hass_attribute'], ci: raw['comm_req_attribute']
    %w(prereqs coreqs).each do |req|
      send "#{req}=", raw[req].split(', ').select { |r| r =~ REGEX } if raw[req].present?
    end
    self.units = raw['units'].split('-').map(&:to_i) if raw['units'].present?
    self.instructor = Instructor.where(name: raw['in-charge']).first_or_create! if raw['in-charge'].present?
    save!
    Textbook.load! self
  end

  def units
    super.map(&:to_i)
  end

  def total_units
    units.sum
  end

  def prereq_classes(semester = [Semester.current, Semester.last])
    self.class.where(semester: semester, number: prereqs)
  end

  def coreq_classes(semester = [Semester.current, Semester.last])
    self.class.where(semester: semester, number: coreqs)
  end

  def conflicts?(other_class)
    conflicts(other_class).present?
  end

  def conflicts(other_class)
    other_sections_by_size = other_class.sections.group_by(&:size)
    conflicts = []
    sections.group_by(&:size).each do |size, grouped_sections|
      other_sections_by_size.each do |other_size, other_grouped_sections|
        conflicts << [size, other_size] if grouped_sections.reject { |s| s.conflicts? other_grouped_sections }.empty?
      end
    end
    conflicts
  end

  private

  def set_course
    self.course = Course.where(number: number.split('.').first).first_or_create!
  end

  def raw_data
    HTTP::Coursews.new(semester, course).mit_class(number)
  end
end

