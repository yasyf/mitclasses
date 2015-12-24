class Student < ActiveRecord::Base
  ANONYMOUS_KERBEROS = 'anonymous'

  has_many :schedules

  validates :kerberos, presence: true, uniqueness: true, format: { with: /\A[a-z]+\z/ }

  before_validation(on: :create) do
    self.kerberos.downcase! if attribute_present?('kerberos')
  end
end
