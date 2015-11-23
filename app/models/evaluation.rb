class Evaluation < ActiveRecord::Base
  CONNECTION = HTTP::Evaluations.new

  belongs_to :mit_class
  has_one :instructor, through: :mit_class
  has_one :semester, through: :mit_class

  after_create :populate!

  private

  def populate!
    update_attributes! CONNECTION.evaluation(mit_class)
  end
end
