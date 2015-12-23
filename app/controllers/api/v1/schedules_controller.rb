module Api
  module V1
    class SchedulesController < ApplicationController
      def show
        render json: { schedule: Schedule.parse(params[:id]).feature_vector }
      end

      def index
        render json: { schedules: Schedule.all.flat_map(&:feature_vectors) }
      end
    end
  end
end
