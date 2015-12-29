class Student < ActiveRecord::Base
  ANONYMOUS_KERBEROS = 'anonymous'

  belongs_to :course

  has_many :schedules

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

  def schedule
    Schedule.for_student self
  end

  private

  def finger
    @finger ||= SSH::Finger.new(kerberos)
  end

  def populate
    self.graduation_year = Semester.current.year + (4 - finger.year) if finger.year.present?
    self.name = finger.name.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    self.course = Course.where(description: finger.department).first if finger.department.present?
  end
end
