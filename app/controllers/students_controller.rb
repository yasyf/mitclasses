class StudentsController < ApplicationController
  before_action :student

  def show
    @endpoints = {
      schedules: student_schedule_index_url(params[:id]),
      feedbacks: student_feedbacks_url(params[:id])
    }
  end

  private

  def student
    @student ||= Student.where(kerberos: params[:id]).first!
  end
end
