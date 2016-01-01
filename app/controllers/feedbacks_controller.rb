class FeedbacksController < ApplicationController
  include Concerns::StudentSubcontroller

  before_action :feedbacks

  def index
    @endpoints = { feedbacks: student_feedbacks_url(params[:student_id]) }
  end

  def create
    schedule.feedback! MitClass.find(create_params[:recommendation_id]), create_params[:positive]
    head :ok
  end

  def update
    feedback.update! update_params
    head :ok
  end

  def destroy
    feedback.destroy!
    head :ok
  end

  private

  def create_params
    params.require(:feedback).permit(:positive, :recommendation_id)
  end

  def update_params
    params.require(:feedback).permit(:positive)
  end

  def feedback
    @feedback ||= Feedback.find(params[:id])
  end

  def feedbacks
    @feedbacks ||= schedule.feedbacks.order(:created_at)
  end
end
