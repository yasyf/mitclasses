class ScheduleController < ApplicationController
  include Concerns::StudentSubcontroller

  before_action :schedule

  def index
    @endpoints = {
      recommendations: recommendations_api_v1_student_url(params[:student_id]),
      feedbacks: student_feedbacks_url(params[:student_id])
    }
  end
end
