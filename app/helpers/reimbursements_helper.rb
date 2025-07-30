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

  # Returns black or white depending on which contrasts better with the background
  def text_color_for(hex_color)
    hex = hex_color.delete('#')
    r, g, b = hex[0..1].hex, hex[2..3].hex, hex[4..5].hex

    brightness = (r * 299 + g * 587 + b * 114) / 1000
    brightness > 150 ? '#000000' : '#ffffff'
  end

  def rgba_color(hex, alpha = 1.0)
    hex = hex.delete('#')
    r = hex[0..1].hex
    g = hex[2..3].hex
    b = hex[4..5].hex

    "rgba(#{r}, #{g}, #{b}, #{alpha})"
  end
end
