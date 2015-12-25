module Concerns
  module Features
    UNITS_PER_SEMESTER = 40

    extend ActiveSupport::Concern

    class_methods do
      def sorted_courses
        @sorted_courses ||= Course.sorted
      end
    end

    def semester_booleans
      Semester.seasons.keys.map { |s| (s == semester.season) ? 1 : 0 }
    end

    def classes_per_course(percent: true)
      self.class.sorted_courses.map do |course|
        count = (grouped_classes[course].try(:count) || 0).to_f
        percent ? (count / classes.count) : count
      end
    end

    def class_count
      classes.length
    end

    def predominant_major
      predominant = grouped_classes.keys.max_by { |c| grouped_classes[c].count }
      self.class.sorted_courses.map { |c| (c == predominant) ? 1 : 0 }
    end

    def average_class_number_per_course
      self.class.sorted_courses.map do |course|
        if classes = grouped_classes[course]
          classes.lazy.map(&:class_number).map { |cn| "0.#{cn}" }.map(&:to_f).sum / classes.count
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
        count / classes.length
      else
        count
      end
    end

    private

    def grouped_classes
      @grouped_classes ||= classes.group_by(&:course)
    end
  end
end
