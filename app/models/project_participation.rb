class ProjectParticipation < ApplicationRecord
  belongs_to :user
  belongs_to :project

  before_validation :ensure_super_user_has_all_permissions

  # TODO: Write some validation that ensures that project and user belong to the company.

  private

  def ensure_super_user_has_all_permissions
    cp = user.participations.where(company: project.company).first
    return unless cp.present? && cp.super_permission
    self.execution_permission = true
    self.develop_permission = true
    self.publish_permission = true
  end
end
