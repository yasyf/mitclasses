class Instructor < ActiveRecord::Base
  include Concerns::SafeJson

  has_many :classes, class_name: 'MitClass'

  validates :name, presence: true, uniqueness: true

  def to_s
    name
  end

  def first_name
    name.split(', ').drop(1).join
  end

  def last_name
    name.split(', ').first
  end
end
