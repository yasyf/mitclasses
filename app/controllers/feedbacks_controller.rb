class FeedbacksController < ApplicationController
  include Concerns::StudentSubcontroller

  before_action :feedbacks

  def update
    feedback.update! feedback_params
    head :ok
  end

  def destroy
    feedback.destroy!
    head :ok
  end

  private

  def feedback_params
    params.require(:feedback).permit(:positive)
  end

  def feedback
    @feedback ||= Feedback.find(params[:id])
  end

  def feedbacks
    @feedbacks ||= Schedule.for_student(student).feedbacks.order(:created_at)
  end
end
