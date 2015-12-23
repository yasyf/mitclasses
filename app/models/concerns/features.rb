module Concerns
  module Features
    UNITS_PER_SEMESTER = 40

    extend ActiveSupport::Concern

    def semester_booleans
      Semester.seasons.keys.map { |s| (s == semester.season) ? 1 : 0 }
    end

    def classes_per_course(percent: true)
      grouped_classes = classes.group_by(&:course)
      Course.sorted.map do |course|
        count = (grouped_classes[course].try(:count) || 0).to_f
        percent ? (count / classes.count) : count
      end
    end

    def class_count
      classes.length
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
  end
end
