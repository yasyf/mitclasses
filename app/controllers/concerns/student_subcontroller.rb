module Concerns
  module StudentSubcontroller
    extend ActiveSupport::Concern

    included do
      before_action :student
    end

    private

    def schedule
      @schedule ||= Schedule.for_student(student)
    end

    def student
      @student ||= Student.where(kerberos: params[:student_id]).first!
    end
  end
end
