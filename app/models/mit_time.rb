class MitTime < ActiveRecord::Base
  has_and_belongs_to_many :sections
  has_many :mit_classes, through: :sections

  validates :start, presence: true
  validates :finish, presence: true
  validates :day, presence: true, uniqueness: { scope: [:start, :finish] }

  enum day: [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

  def self.char_to_day(char)
    %w(M T W R F S X).index(char)
  end

  # true if all t ∈ other_times contained in self
  def conflicts?(other_times)
    other_times.reject { |ot| contains? ot }.empty?
  end

  def contains?(other_time)
    (other_time.finish > start && other_time.finish < finish) ||
     (other_time.start > start && other_time.start < finish)
  end
end
