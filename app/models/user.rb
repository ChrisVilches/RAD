class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :participations
  has_many :companies, through: :participations

  has_many :project_participations
  has_many :projects, through: :project_participations

  def project_permissions(project)
    participation = self.project_participations.find{|pp| pp.user == self}
    {
      develop_permission: participation.develop_permission,
      execution_permission: participation.execution_permission,
      publish_permission: participation.publish_permission
    }
  end

  def company_permissions(company)
    participation = self.participations.find{|pp| pp.user == self}
    {
      connection_permission: participation.connection_permission,
      project_permission: participation.project_permission,
      super_permission: participation.super_permission
    }
  end
end
