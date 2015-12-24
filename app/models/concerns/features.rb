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

    def predominant_major
      grouped_classes = classes.group_by(&:course)
      grouped_classes.keys.max_by { |c| grouped_classes[c].count }.number.to_i
    end

    def average_class_number_per_course
      grouped_classes = classes.group_by(&:course)
      Course.sorted.map do |course|
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
  end
end
