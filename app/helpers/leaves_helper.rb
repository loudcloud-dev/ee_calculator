module LeavesHelper
  def get_status_badge(status)
    if status == "approved"
      "text-bg-success"
    elsif status == "rejected"
      "text-bg-danger"
    elsif status == "pending"
      "text-bg-warning"
    else
      "text-bg-secondary"
    end
  end
end
