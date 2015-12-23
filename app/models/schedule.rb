class Schedule < ActiveRecord::Base
  FEATURE_METHODS = %w(classes_per_course semester_booleans unit_count)

  has_and_belongs_to_many :mit_classes

  alias_method :classes, :mit_classes

  class ScheduleSemester
    include Concerns::Features

    attr_reader :classes, :semester, :schedule

    delegate :to_s, to: :semester

    def initialize(classes, semester, schedule)
      @classes = classes
      @semester = semester
      @schedule = schedule
    end

    def method_missing(method)
      @semester.send(method)
    end

    def features
      [semester.to_s, FEATURE_METHODS.map { |m| [m, send(m)] }.to_h]
    end

    def feature_vector
      FEATURE_METHODS.flat_map { |m| send(m) } + [id]
    end

    def conflicts
      @conflicts ||= classes.combination(2).select { |a, b| a.conflicts? b }
    end

    def conflicts?(mit_class)
      classes.any? { |c| mit_class.conflicts? c }
    end

    def id
      "#{self.class.parent.name}.#{@schedule.id}.#{semester.to_s}"
    end
  end

  def conflicts?
    conflicts.values.any? { |c| c.present? }
  end

  def conflicts
    @conflicts ||= semesters.map { |s| [s.semester, s.conflicts] }.to_h
  end

  def semesters
    semester_hash.values
  end

  def semester(semester)
    semester_hash[semester]
  end

  def features
    semesters.map { |s| [s.to_s, s.features] }.to_h
  end

  def feature_vectors
    semesters.map(&:feature_vector)
  end

  def self.parse(identifier)
    _, id, semester = identifier.split('.')
    Schedule.find(id).semester Semester.parse(semester)
  end

  def self.from_course_road(kerberos)
    offset = HTTP::Year.new.year(kerberos) - 1

    classes = HTTP::CourseRoad.new.hash(kerberos).map do |c|
      next if c['classterm'] == 0 || c['year'].to_i == 0

      year = Semester.current.year - offset + (c['classterm'] / 4)
      season = [:summer, :fall, :iap, :spring][c['classterm'] % 4]

      semester = Semester.where(year: year, season: Semester.seasons[season]).first_or_create!
      semester.mit_class!(c['subject_id'])
    end.compact

    self.create! mit_classes: classes
  end

  private

  def semester_hash
    @semester_hash ||= grouped_classes.map { |s, c| [s, ScheduleSemester.new(c, s, self)] }.to_h
  end

  def grouped_classes
    @grouped_classes ||= classes.includes(:semester, sections: :times).group_by(&:semester)
  end
end
