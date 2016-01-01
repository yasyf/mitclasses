class MitClass < ActiveRecord::Base
  include Concerns::SafeJson
  include Concerns::Features

  FEATURE_METHODS = {
    average_course_number: [],
    average_class_number: [],
    method_feature: [{ method_name: 'name', string: true }]
  }

  REGEX = /((([A-Z]{2,3})|(([1][0-2,4-8]|[2][0-2,4]|[1-9])[AWFHLM]?))\.(([S]?[0-9]{2,4}[AJ]?)|(UA[TR])))/

  belongs_to :semester
  belongs_to :course
  belongs_to :instructor

  has_many :feedbacks, dependent: :destroy
  has_many :sections, dependent: :destroy
  has_many :textbooks, dependent: :destroy
  has_one :evaluation, dependent: :destroy

  has_and_belongs_to_many :schedules

  before_create :set_course

  validates :semester, presence: true
  validates :number, presence: true, uniqueness: { scope: [:semester] }

  def populate!(raw = nil, force_update: false)
    raw ||= raw_data
    force_update |= !offered

    if raw.blank?
      Rails.logger.warn("No data found for #{number}!")
      self.offered = false
    else
      update short_name: raw['shortLabel'], description: raw['description'], name: raw['label']
      update hass: raw['hass_attribute'], ci: raw['comm_req_attribute']
      update equivalents: raw['equivalent_subjects'].flat_map { |s| self.class.translate_class_string(s) }.compact
      %w(prereqs coreqs).each do |req|
        parsed = self.class.parse_class_group(raw[req])
        send "#{req}=", parsed.simplify.to_h if parsed.present?
      end

      self.units = raw['units'].split('-').map(&:to_i)
      self.units = nil if self.units.sum <= 0

      self.instructor = Instructor.where(name: raw['in-charge']).first_or_create!
      self.offered = true
    end

    self.units = [4, 4, 4] unless self[:units].present?

    save!

    MitClassWorkers::SiteWorker.perform_async(self.id) if force_update || !site.present?
    MitClassWorkers::EvaluationWorker.perform_async(self.id) if force_update || !evaluation.present?
    MitClassWorkers::TextbookWorker.perform_async(self.id) if force_update || !textbooks.present?

    self
  end

  def units
    super.map(&:to_i)
  end

  def total_units
    units.sum
  end

  def class_number
    number.split('.').last
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

  def site_uri
    URI(site) if site.present?
  end

  def stellar_uri
    path = "#{course}/#{semester.to_s(stellar: true)}/#{number}"
    URI("https://stellar.mit.edu/S/course/#{path}/")
  end

  def lmod_uri
    uuid = "/course/#{course}/#{semester.to_s(stellar: true)}/#{number}"
    URI("https://learning-modules.mit.edu/class/index.html?uuid=#{uuid}")
  end

  def as_json(options = {})
    return super options.reverse_merge(only: [:number, :name, :description, :id]) if options[:shallow]
    json = super options.reverse_merge(
      methods: [:instructor, :course, :semester, :sections, :textbooks, :evaluation]
    )
    json.merge(
      total_units: total_units,
      stellar: stellar_uri.to_s,
      learning_modules: lmod_uri.to_s,
      prereq_string: prereqs.to_s,
      coreq_string: coreqs.to_s,
    )
  end

  private

  def set_site!
    update! site: HTTP::Course.new.class_site(self)
  end

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

  def self.num_features
    @num_features ||= [super, Feedback.num_features]
  end

  def set_course
    self.course = Course.where(number: number.split('.').first).first_or_create!
  end

  # for #features and #feature_vectors
  def classes
    [self]
  end

  def raw_data
    HTTP::Coursews.new(semester, course).mit_class(number)
  end
end

