class ConnectionPolicy < ApplicationPolicy

  def index?
    true
  end

  def create?
    # TODO object passed is the connection. User must be able to add connections
    # to the project in the connection.
    true
  end

end
