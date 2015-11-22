class Evaluation < ActiveRecord::Base
  CONNECTION = HTTP::Evaluations.new

  belongs_to :mit_class

  after_create :populate!

  delegate :instructor, :semester, to: :mit_class

  private

  def populate!
    update_attributes! CONNECTION.evaluation(mit_class)
  end
end
