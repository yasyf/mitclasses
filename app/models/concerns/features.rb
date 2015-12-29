module Concerns
  module Features
    CLASSES_PER_SEMESTER = 4.0
    UNITS_PER_SEMESTER = 48.0

    extend ActiveSupport::Concern

    class_methods do
      def sorted_courses
        @sorted_courses ||= Course.sorted
      end
    end

    def feature_vector
      @feature_vector ||= begin
        self.class::FEATURE_METHODS.flat_map do |m, params|
          if params.present?
            params.flat_map { |p| send(m, p) }
          else
            send(m)
          end
        end + [id]
      end
    end

    def features
      @features ||= begin
        self.class::FEATURE_METHODS.map do |m, params|
          if params.present?
            [m, params.map { |p| [p.to_query, send(m, p)] }.to_h]
          else
            [m, send(m)]
          end
        end.to_h
      end
    end

    def season_count(percent: true)
      grouped = classes.group_by { |c| c.semester.season }
      Semester.seasons.slice(:fall, :spring).keys.sort.map do |season|
        count = (grouped[season].try(:count) || 0).to_f
        percent ? (count / classes_count) : count
     end
    end

    def year_count(percent: true)
      grouped = classes.group_by { |c| c.semester.year }
      graduation_year = student.try(:graduation_year) || (grouped.keys.sort.first + 4)
      (0..3).map do |i|
        count = (grouped[graduation_year - i].try(:count) || 0).to_f
        percent ? (count / classes_count) : count
      end.reverse
    end

    def classes_per_course(percent: true)
      self.class.sorted_courses.map do |course|
        count = (classes_by_course[course].try(:count) || 0).to_f
        percent ? (count / classes_count) : count
      end
    end

    def class_count(mode: :deviation)
      count = classes_count.to_f
      case mode
      when :deviation
        (CLASSES_PER_SEMESTER - count).abs / count
      else
        count
      end
    end

    def predominant_major
      predominant = classes_by_course.keys.max_by { |c| classes_by_course[c].count }
      self.class.sorted_courses.map { |c| (c == predominant) ? 1 : 0 }
    end

    def average_class_number_per_course
      self.class.sorted_courses.map do |course|
        if classes = classes_by_course[course]
          classes.lazy.map(&:class_number).map do |cn|
            if match = /\d+/.match(cn)
              "0.#{match[0]}"
            else
              0
            end
          end.map(&:to_f).sum / classes_count
        else
          0.0
        end
      end
    end

    def unit_count(mode: :deviation)
      count = classes.map(&:total_units).map(&:to_f).sum
      case mode
      when :deviation
        (UNITS_PER_SEMESTER - count).abs / count
      when :average
        count / classes_count
      else
        count
      end
    end

    private

    def classes_count
      @classes_count ||= classes.count.to_f
    end

    def classes_by_course
      @classes_by_course ||= classes.group_by(&:course)
    end
  end
end
