user = row
project_permissions = user.project_permissions(@project)
super_user = user.company_permissions(current_company)[:super_permission]
participating = user.participating_in_project?(@project)
user_type = 'not_participating'
user_type = super_user ? 'super' : 'normal' if participating
json.id user.id
json.email user.email
json.user_type user_type
json.execution_permission project_permissions[:execution_permission]
json.develop_permission project_permissions[:develop_permission]
json.publish_permission project_permissions[:publish_permission]
