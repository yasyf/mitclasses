class Schedule < ActiveRecord::Base
  include Concerns::Cacheable
  include Concerns::Features
  include Concerns::FeatureVectors

  FEATURE_METHODS = {
    classes_per_course: [],
    season_count: [],
    year_count: [],
    class_count: [{ mode: :deviation }],
    unit_count: [{ mode: :deviation }, { mode: :average }, { mode: :total }],
    predominant_major: [],
    average_class_number_per_course: []
  }

  FEATURE_INLCUDES = [:semester, { sections: :times }, :course]

  MAX_NUM_SUGGESTIONS = 50

  @@mutex = Mutex.new

  belongs_to :student

  has_many :feedbacks
  has_and_belongs_to_many :mit_classes

  alias_method :classes, :mit_classes

  class ScheduleSemester
    include Concerns::Features
    include Concerns::Cacheable

    FEATURE_METHODS = parent::FEATURE_METHODS

    attr_reader :classes, :semester, :schedule

    delegate :to_s, to: :semester
    delegate :student, to: :schedule

    def initialize(classes, semester, schedule)
      @classes = classes
      @semester = semester
      @schedule = schedule
    end

    def suggestions(**kwargs)
      if kwargs[:cached]
        kwargs.except!(:cached)
        key_cached kwargs, expires_in: 1.hour do
          @schedule.class.learning.suggestions(self, **kwargs).take(MAX_NUM_SUGGESTIONS)
        end
      else
        @schedule.class.learning.suggestions self, **kwargs
      end
    end

    def augmented_feature_vector
      @schedule.feature_vector[0..-2] + feature_vector
    end

    def conflicts
      @conflicts ||= classes.combination(2).select { |a, b| a.conflicts? b }
    end

    def conflicts?(mit_class)
      classes.any? { |c| mit_class.conflicts? c }
    end

    def cache_key
      "#{@schedule.cache_key}/#{id}"
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

  def feedback!(mit_class, positive)
    feedbacks.where(mit_class: mit_class).first_or_create.update!(positive: positive)
  end

  def self.num_features
    @num_features ||= first.feature_vectors.first.size - 1
  end

  def self.parse(identifier)
    _, id, semester = identifier.split('.')
    Schedule.find(id).semester Semester.parse(semester)
  end

  def self.for_student(student)
    student = Student.where(kerberos: student).first_or_create! if student.is_a?(String)
    where(student: student).first || from_course_road(student)
  end

  def self.from_course_road(student)
    return nil unless student.graduation_year.present?

    classes = HTTP::CourseRoad.new.hash(student.kerberos).map do |c|
      next if c['year'].to_i == 0

      year = student.graduation_year - 4 + (c['classterm'] / 4)
      season = [:summer, :fall, :iap, :spring][c['classterm'] % 4]

      semester = Semester.where(year: year, season: Semester.seasons[season]).first_or_create!
      semester.mit_class!(c['subject_id'])
    end.compact

    classes.present? ? self.create!(mit_classes: classes, student: student) : nil
  end

  def feature_vector
    cached { super }
  end

  private

  def generate_feature_vectors
    semesters.map(&:augmented_feature_vector)
  end

  def self.learning
    @@mutex.synchronize do
      @learning ||= ML::Schedule.new @@mutex, all.includes(:student)
    end
  end

  def semester_hash
    @semester_hash ||= classes_by_semester.map { |s, c| [s, ScheduleSemester.new(c, s, self)] }.to_h
  end

  def classes_by_semester
    @classes_by_semester ||= classes.includes(FEATURE_INLCUDES).group_by(&:semester)
  end
end
