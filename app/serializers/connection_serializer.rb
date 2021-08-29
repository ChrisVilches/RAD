class ConnectionSerializer < ActiveModel::Serializer
  # The purpose is to remove 'pass' from all responses in controllers that include ActionController::Serialization.
  # Using JBuilder or render json: { } can still send the 'pass' value, so this solution is only to prevent
  # accidents.
  attributes :id, :name, :description, :color, :user, :host, :port, :db_type, :created_at, :updated_at
end

# TODO: A better way might be to get all attributes from the Connection model, then remove :pass
#       and then do 'attributes(*attributes_except_pass)' but I don't know which Connection method I should use yet.
