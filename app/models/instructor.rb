class Instructor < ActiveRecord::Base
  has_many :classes, class_name: :MitClass

  validates :name, presence: true, uniqueness: true
end
