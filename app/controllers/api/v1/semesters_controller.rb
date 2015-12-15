module Api
  module V1
    class SemestersController < ApplicationController
      def index
        render json: { semesters: Semester.all.map(&:to_s) }
      end
    end
  end
end
