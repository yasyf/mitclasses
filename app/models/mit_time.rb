class MitTime < ActiveRecord::Base
  has_many :sections
  has_many :mit_classes, through: :sections

  validates :start, presence: true
  validates :finish, presence: true
  validates :day, presence: true, uniqueness: { scope: [:start, :finish] }

  enum day: [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

  def self.char_to_day(char)
    %w(M T W R F S X).index(char)
  end
end
