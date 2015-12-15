module Api
  module V1
    class ClassesController < ApplicationController
      def show
        render json: semester.mit_class(params[:id])
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
