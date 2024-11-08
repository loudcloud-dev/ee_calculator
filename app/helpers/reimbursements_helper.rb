module ReimbursementsHelper
  def set_status_badge(status)
    case status
    when "pending"
      "secondary"
    when "reimbursed"
      "success"
    else
      "danger"
    end
  end

  def start_date(date)
    if date.day < 6
      (date.beginning_of_month - 1.month).change(day: 6)
    else
      date.beginning_of_month.change(day: 6)
    end
  end
end
