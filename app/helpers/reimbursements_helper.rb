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

  def format_amount(amount)
    number_to_currency(amount, unit: "₱")
  end

  def dynamic_greeting
    current_hour = Time.now.hour
    greeting = if current_hour < 12
                "Good Morning"
    elsif current_hour < 18
                "Good Afternoon"
    else
                "Good Evening"
    end
  end
end
