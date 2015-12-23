class Schedule < ActiveRecord::Base
  FEATURE_METHODS = %w(classes_per_course semester_booleans unit_count)

  has_and_belongs_to_many :mit_classes

  alias_method :classes, :mit_classes

  class ScheduleSemester
    include Concerns::Features

    attr_accessor :classes, :semester

    delegate :to_s, to: :semester

    def initialize(classes, semester)
      @classes = classes
      @semester = semester
    end

    def method_missing(method)
      @semester.send(method)
    end
  end

  def conflicts?
    conflicts.present?
  end

  def conflicts
    @conflicts ||= begin
      grouped_classes.each_with_object({}) do |(semester, semester_classes), hash|
        hash[semester] = semester_classes.combination(2).select { |a, b| a.conflicts? b }
      end
    end
  end

  def semesters
    grouped_classes.map { |s, c| ScheduleSemester.new c, s }
  end

  def features
    semesters.map do |semester|
      [semester.to_s, FEATURE_METHODS.map { |m| [m, semester.send(m)] }.to_h]
    end.to_h
  end

  def feature_vectors
    semesters.map do |semester|
      [semester.to_s, FEATURE_METHODS.flat_map { |m| semester.send(m) }]
    end.to_h
  end

  private

  def grouped_classes
    classes.includes(:semester, sections: :times).group_by(&:semester)
  end
end
