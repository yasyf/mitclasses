class Location < ActiveRecord::Base
  has_many :sections
  has_many :mit_classes, through: :sections

  validates :number, presence: true, uniqueness: true

  def to_url
    "http://whereis.mit.edu/?q=#{number}"
  end
end
