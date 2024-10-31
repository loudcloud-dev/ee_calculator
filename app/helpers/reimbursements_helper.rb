module ReimbursementsHelper
  def set_status_badge(status)
    case status
    when 'pending'
      'secondary'
    when 'reimbursed'
      'success'
    else
      'danger'
    end
  end
end
