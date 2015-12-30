module Api
  module V1
    class ClassesController < ApplicationController
      def index
        render json: { classes: semester.feature_vectors }
      end

      def feedback
        render json: { classes: Feedback.where(mit_class: semester.classes).map(&:feature_vector) }
      end

      def show
        render json: { 'class' => semester.mit_class(params[:id]) }
      end

      private

      def semester
        @semester ||= if params[:semester_id].present?
          Semester.parse(params[:semester_id])
        else
          Semester.current
        end
      end
    end
  end
end
