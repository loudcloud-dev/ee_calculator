class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: { safari: 16.4, firefox: 121, ie: false }

  # prompt change password after first time sign in
  def after_sign_in_path_for(resource)
    if !current_employee.nil? && current_employee.sign_in_count == 1
      edit_employee_registration_path
    else
      root_path
    end
  end
end
