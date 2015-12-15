class Evaluation < ActiveRecord::Base
  include Concerns::SafeJson

  belongs_to :mit_class
  has_one :instructor, through: :mit_class
  has_one :semester, through: :mit_class

  validates :rating, presence: true
  validates :percent_response, presence: true,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :mit_class, presence: true, uniqueness: true

  def self.load!(mit_class)
    where(mit_class: mit_class).first_or_create.populate!
  end

  def populate!
    evaluation = HTTP::Evaluations.new.evaluation(mit_class)
    evaluation.present? ? update_attributes!(evaluation) : destroy!
  end
end
