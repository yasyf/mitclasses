class Feedback < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :mit_class

  validates :positive, inclusion: [true, false]
  validates :schedule, presence: true
  validates :mit_class, presence: true, uniqueness: { scope: [:schedule] }

  def feature_vector
    schedule.feature_vector[0..-2] + mit_class.feature_vector[0..-2] + [positive? ? 1 : 0]
  end
end
