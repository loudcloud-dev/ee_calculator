module ApplicationHelper
  def alert_class(type)
    {
      success: "alert-success",
      error: "alert-danger"
    }[type.to_sym]
  end
end
