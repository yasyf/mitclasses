module Api
  module V1
    class StudentsController < ApplicationController
      def recommendations
        suggestions = schedule.semester(semester).suggestions(cached: true, use_classifier: false, ignore_conflicts: true)
        render json: { recommendations: suggestions.drop(offset).take(count).as_json(shallow: true) }
      end

      private

      def semester
        params[:semester].present? ? Semester.parse(params[:semester]) : Semester.current
      end

      def offset
        params[:offset].try(:to_i) || 0
      end

      def count
        params[:count].try(:to_i) || 10
      end

      def schedule
        @schedule ||= Schedule.for_student(student)
      end

      def student
        @student ||= Student.where(kerberos: params[:id]).first!
      end
    end
  end
end
