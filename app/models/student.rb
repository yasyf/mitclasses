class Student < ActiveRecord::Base
  ANONYMOUS_KERBEROS = 'anonymous'

  has_many :schedules
  belongs_to :course

  validates :kerberos, presence: true, uniqueness: true, format: { with: /\A\w+\z/ }
  validates :graduation_year, numericality: { greater_than: 2000, less_than: 3000, allow_blank: true }

  before_create :populate

  before_validation(on: :create) do
    self.kerberos.downcase! if attribute_present?('kerberos')
  end

  def populate!
    populate
    save!
  end

  private

  def finger
    @finger ||= SSH::Finger.new(kerberos)
  end

  def populate
    self.graduation_year = Semester.current.year - (finger.year - 1) + 4 if finger.year.present?
    self.name = finger.name
    self.course = Course.where(description: finger.department).first if finger.department.present?
  end
end
