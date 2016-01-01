module Concerns
  module StudentSubcontroller
    extend ActiveSupport::Concern

    included do
      before_action :student
    end

    private

    def student
      @student ||= Student.where(kerberos: params[:student_id]).first!
    end
  end
end
