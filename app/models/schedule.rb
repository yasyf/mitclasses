class Schedule < ActiveRecord::Base
  FEATURE_METHODS = {
    classes_per_course: [],
    semester_booleans: [],
    class_count: [{ mode: :deviation }],
    unit_count: [{ mode: :deviation }, { mode: :average }, { mode: :total }],
    predominant_major: [],
    average_class_number_per_course: []
  }

  FEATURE_INLCUDES = [:semester, { sections: :times }, :course]

  has_and_belongs_to_many :mit_classes
  belongs_to :student

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

    def suggestions
      @schedule.class.clustering.suggestions self
    end

    def feature_vector
      FEATURE_METHODS.flat_map do |m, params|
        if params.present?
          params.flat_map { |p| send(m, p) }
        else
          send(m)
        end
      end + [id]
    end

    def conflicts
      @conflicts ||= classes.combination(2).select { |a, b| a.conflicts? b }
    end

    def conflicts?(mit_class)
      classes.any? { |c| mit_class.conflicts? c }
    end

    def id
      prefix = self.schedule.student.try(:kerberos) || Student::ANONYMOUS_KERBEROS
      "#{prefix}.#{@schedule.id}.#{semester.to_s}"
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

  def feature_vectors
    semesters.map(&:feature_vector)
  end

  def self.parse(identifier)
    _, id, semester = identifier.split('.')
    Schedule.find(id).semester Semester.parse(semester)
  end

  def self.for_student(kerberos)
    student = Student.where(kerberos: kerberos).first_or_create!
    where(student: student).first || from_course_road(student)
  end

  def self.from_course_road(student)
    student_year = SSH::Finger.new(student.kerberos).year
    return nil unless student_year.present?
    offset = student_year - 1

    classes = HTTP::CourseRoad.new.hash(student.kerberos).map do |c|
      next if c['classterm'] == 0 || c['year'].to_i == 0

      year = Semester.current.year - offset + (c['classterm'] / 4)
      season = [:summer, :fall, :iap, :spring][c['classterm'] % 4]

      semester = Semester.where(year: year, season: Semester.seasons[season]).first_or_create!
      semester.mit_class!(c['subject_id'])
    end.compact

    classes.present? ? self.create!(mit_classes: classes, student: student) : nil
  end

  private

  def self.clustering
    @clustering ||= ML::Clustering::Schedule.new all.includes(:student, mit_classes: FEATURE_INLCUDES)
  end

  def semester_hash
    @semester_hash ||= grouped_classes.map { |s, c| [s, ScheduleSemester.new(c, s, self)] }.to_h
  end

  def grouped_classes
    @grouped_classes ||= classes.includes(FEATURE_INLCUDES).group_by(&:semester)
  end
end
