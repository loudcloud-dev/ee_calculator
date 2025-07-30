module ApplicationHelper
  def alert_class(type)
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-secondary"
    }[type.to_sym]
  end
end
