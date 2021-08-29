# TODO: Authorize user
class ViewNotificationChannel < ApplicationCable::Channel
  def subscribed
    view = View.find params[:id].to_i
    stream_for view

    logger.debug "[Cable] User subscribed to view ID #{view.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    logger.debug '[Cable] User disconnected'
  end
end
