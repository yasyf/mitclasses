class Feedback < ActiveRecord::Base
  include Concerns::Cacheable

  belongs_to :schedule
  belongs_to :mit_class

  validates :positive, inclusion: [true, false]
  validates :schedule, presence: true
  validates :mit_class, presence: true, uniqueness: { scope: [:schedule] }

  def feature_vector
    cached { schedule_feature_vector[0..-2] + class_feature_vector[0..-2] + [positive? ? 1 : 0] }
  end

  def self.num_features
    @num_features ||= first.feature_vector.size - 1
  end

  def self.build_feature_vector(schedule, mit_class, label = nil)
    schedule.feature_vector[0..-2] + mit_class.feature_vector[0..-2] + [label]
  end

  private

  def schedule_feature_vector
    Schedule.where(id: schedule_id).includes(mit_classes: Schedule::FEATURE_INLCUDES).first.feature_vector
  end

  def class_feature_vector
    mit_class.feature_vector
  end
end
