class MitTime < ActiveRecord::Base
  include Concerns::SafeJson

  has_and_belongs_to_many :sections
  has_many :mit_classes, through: :sections

  validates :start, presence: true
  validates :finish, presence: true
  validates :day, presence: true, uniqueness: { scope: [:start, :finish] }

  enum day: [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

  def as_json(opts = {})
    json = super(opts)
    %w(start finish).each do |a|
      json[a] = json[a].localtime.strftime('%I:%M %p') if json[a].present?
    end
    json
  end

  def self.char_to_day(char)
    %w(M T W R F S X).index(char)
  end

  # true if any t ∈ other_times contained in self
  def conflicts?(other_times)
    other_times.any? { |ot| contains? ot }
  end

  def contains?(other_time)
    return false unless other_time.day == day
    (other_time.finish >= start && other_time.finish <= finish) ||
     (other_time.start >= start && other_time.start <= finish)
  end
end
