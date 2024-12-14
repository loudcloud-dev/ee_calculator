class LeavesController < ApplicationController
  before_action :authenticate_employee!, only: [ :index, :new, :create ]
  def index
    @leaves = current_employee.leaves
  end

  def new
    @leave = Leave.new
    @approvers = AdminUser.order(:email)
  end

  def create
    @leave = current_employee.leaves.build(leave_params)
    if @leave.save
      redirect_to leaves_path, notice: "Leave request created successfully!"
    else
      render :new, alert: "Failed to create leave request."
    end
  end

  private

  def leave_params
    params.require(:leave).permit(:approver_id, :start_date, :end_date, :day_count, :leave_type, :reason)
  end
end
