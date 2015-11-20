class MitClass < ActiveRecord::Base
  REGEX = /((([A-Z]{2,3})|(([1][0-2,4-8]|[2][0-2,4]|[1-9])[AWFHLM]?))\.(([S]?[0-9]{2,4}[AJ]?)|(UA[TR])))/

  belongs_to :semester
  belongs_to :course
  belongs_to :instructor

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

  private

  def set_course
    self.course = Course.where(number: number.split('.').first).first_or_create!
  end

  def raw_data
    HTTP::Coursews.new(semester, course).mit_class(number)
  end
end

