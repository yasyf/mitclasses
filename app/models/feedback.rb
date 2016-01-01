class Feedback < ActiveRecord::Base
  include Concerns::Cacheable
  include Concerns::ReactJson

  belongs_to :schedule
  belongs_to :mit_class

  validates :positive, inclusion: [true, false]
  validates :schedule, presence: true
  validates :mit_class, presence: true, uniqueness: { scope: [:schedule] }

  def feature_vector
    cached { self.class.build_feature_vector(schedule, mit_class, positive? ? 1 : 0) }
  end

  def self.num_features
    @num_features ||= first.feature_vector.size - 1
  end

  def self.build_feature_vector(schedule, mit_class, label = nil)
    schedule.feature_vector[0..-2] + mit_class.feature_vector[0..-2] + [label]
  end

  private

  def react_json
    { number: mit_class.number, name: mit_class.name, positive: positive? }
  end
end
