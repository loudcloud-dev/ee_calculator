class LeavesController < ApplicationController
  before_action :authenticate_employee!, only: [ :index, :new, :create, :edit, :update ]
  before_action :approvers, only: [ :new, :create, :edit, :update ]
  before_action :find_id, only: [ :edit, :update, :cancel ]

  # include LeavesHelper
  def index
    @leaves = current_employee.leaves.order("start_date asc")
  end

  def new
    @leave = Leave.new
  end

  def create
    @leave = current_employee.leaves.build(leave_params)
    if @leave.save
      redirect_to leaves_path, notice: "Leave request created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @leave.update(leave_params)
      redirect_to leaves_path, notice: "Leave request updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    if @leave.update(status: "cancelled")
      redirect_to leaves_path, notice: "Leave request cancelled!"
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def leave_params
    params.require(:leave).permit(:approver_id, :start_date, :end_date, :day_count, :leave_type, :reason)
  end

  def find_id
    @leave = Leave.find(params[:id])
  end

  def approvers
    @approvers = AdminUser.order(:email)
  end
end
