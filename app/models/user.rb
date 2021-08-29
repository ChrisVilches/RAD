class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  include Tabulatable

  has_many :participations
  has_many :companies, through: :participations

  has_many :project_participations
  has_many :projects, through: :project_participations

  has_and_belongs_to_many :connections

  def project_permissions(project)
    permissions = {}

    participation = project_participations.where(project: project).first

    %i[develop_permission execution_permission publish_permission].each do |key|
      permissions[key] = participation.nil? ? false : participation.send(key)
    end

    permissions
  end

  def participating_in_project?(project)
    project_participations.where(project: project).first.present?
  end

  def company_permissions(company)
    permissions = {}

    participation = participations.where(company: company).first

    %i[connection_permission project_permission super_permission].each do |key|
      permissions[key] = participation.nil? ? false : participation.send(key)
    end

    permissions
  end
end
