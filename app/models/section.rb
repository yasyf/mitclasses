class Section < ActiveRecord::Base
  REGEX = /([A-Z]{1,5})(?: EVE \()?[\s]?([0-9]{0,2})[:\.]?([0-9]{0,2})-?([0-9]{0,2})[:\.]?([0-9]{0,2}) ?([A-Z]{2})?\)?/
  BASE_TIME = Time.new 0, 1, 1

  class InvalidSection < ActiveRecord::ActiveRecordError; end;

  belongs_to :mit_class
  belongs_to :location
  has_and_belongs_to_many :times, class_name: 'MitTime'

  validates :number, presence: true, uniqueness: true

  enum size: [:lecture, :recitation, :lab]

  delegate :semester, :course, to: :mit_class

  def populate!(raw = nil)
    raw ||= raw_data

    case raw['type']
    when 'RecitationSession'
      recitation!
    when 'LectureSession'
      lecture!
    when 'LabSession'
      lab!
    else
      raise InvalidSection, raw['type']
    end

    time, place = raw['timeAndPlace'].split(' ')

    if !time.include?('*') && !time.upcase.include?('TBD') && (match = REGEX.match time).present?
      match[1].split('').each do |day|
        next unless day = MitTime.char_to_day(day)

        pm = match[6] == 'PM' || match[2].to_i <= 5

        start_hour = pm ? match[2].to_i + 12 : match[2]
        start = BASE_TIME.change hour: start_hour, min: match[3]

        end_hour = match[4].present? ? (pm ? match[4].to_i + 12 : match[4]) : start.hour + 1
        finish = BASE_TIME.change hour: end_hour, min: match[5]

        times << MitTime.where(day: day, start: start, finish: finish).first_or_create!
      end
    end

    self.location = Location.where(number: place).first_or_create!

    save!
  end

  def conflicts?(other_sections)
    conflicts_with_sections? Array.wrap(other_sections)
  end

  private

  def conflicts_with_sections?(other_sections)
    other_sections.reject { |os| conflicts_with_section? os }.empty?
  end

  def conflicts_with_section?(other_section)
    times.each do |time|
      return false unless time.conflicts?(other_section.times)
    end
    true
  end

  def raw_data
    HTTP::Coursews.new(semester, course).section(number)
  end
end
