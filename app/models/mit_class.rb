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
  validates :number, presence: true, uniqueness: { scope: [:semester] }

  def populate!(raw = nil)
    raw ||= raw_data
    update short_name: raw['shortLabel'], description: raw['description'], name: raw['label']
    update hass: raw['hass_attribute'], ci: raw['comm_req_attribute']
    %w(prereqs coreqs).each do |req|
      parsed = self.class.parse_class_group(raw[req])
      send "#{req}=", parsed.simplify.to_h if parsed.present?
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

  %w(prereqs coreqs).each do |req|
    define_method req do
      Groups::Operation.load(self[req]) if self[req].present?
    end
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

  def self.parse_class_group(str)
    return nil unless str.present?
    or_groups = str.split(/,|; /).map do |s|
      classes = s.split('or').map do |c|
        translated = translate_class_string(c)
        Groups::Or.new(translated) if translated.present?
      end.compact
      if classes.size == 1
        classes.first
      elsif classes.size > 0
        Groups::Or.new(classes)
      end
    end.compact
    if or_groups.size == 1
      or_groups.first
    elsif or_groups.size > 0
      Groups::And.new(or_groups)
    end
  end

  def self.translate_class_string(class_string)
    case class_string
    when REGEX
      [$1]
    when 'GIR:PHY1'
      ['8.01', '8.012']
    when 'GIR:PHY2'
      ['8.02', '8.022']
    when 'GIR:CAL1'
      ['18.01', '18.01A']
    when 'GIR:CAL2'
      ['18.02', '18.02A']
    when 'GIR:BIOL'
      ['7.012', '7.015', '7.016']
    when 'GIR:CHEM'
      ['3.091', '5.111', '5.112']
    else
      []
    end
  end

  def set_course
    self.course = Course.where(number: number.split('.').first).first_or_create!
  end

  def raw_data
    HTTP::Coursews.new(semester, course).mit_class(number)
  end
end

