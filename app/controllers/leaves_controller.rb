class LeavesController < ApplicationController
  before_action :authenticate_employee!, only: [ :index, :new, :create, :edit, :update ]
  before_action :approvers, only: [ :new, :create, :edit, :update ]
  before_action :find_id, only: [ :edit, :update, :cancel ]
  before_action :leave_counts, only: [ :index, :new, :create, :edit, :update ]

  # include LeavesHelper
  def index
    @leaves = @all_leaves

    @months = [ *1..12 ].map { |m| [ Date::MONTHNAMES[m], m ] }
    @years = @all_leaves.pluck(:start_date, :end_date).flatten.map { |d| d.year }.uniq

    # filtered leaves
    @leaves = @leaves.where(leave_type: params[:leave_type].downcase) if params[:leave_type].present?
    @leaves = @leaves.where(status: params[:status].downcase) if params[:status].present?
    @leaves = @leaves.where("extract(month from start_date) = ? or extract(month from end_date) = ?", params[:month], params[:month]) if params[:month].present?
    @leaves = @leaves.where("extract(year from start_date) = ? or extract(year from end_date) = ?", params[:year], params[:year]) if params[:year].present?
  end

  def new
    @leave = Leave.new
  end

  def create
    @leave = current_employee.leaves.build(leave_params)
    if @leave.save
      flash[:success] = @leave.leave_type.capitalize + " leave request filed successfully."
      redirect_to leaves_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if @leave.leave_type == "sick"
      @remaining_sl += @leave.day_count
    elsif @leave.leave_type == "vacation"
      @remaining_vl += @leave.day_count
    end
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

  def leave_counts
    @all_leaves = current_employee.leaves.order("start_date asc")

    @pending_sl = @all_leaves.sick_leaves.pending_leaves.sum(:day_count)
    @pending_vl = @all_leaves.vacation_leaves.pending_leaves.sum(:day_count)
    @approved_sl = @all_leaves.sick_leaves.approved_leaves.sum(:day_count)
    @approved_vl = @all_leaves.vacation_leaves.approved_leaves.sum(:day_count)
    @remaining_sl = 15 - @approved_sl - @pending_sl
    @remaining_vl = 15 - @approved_vl - @pending_vl
  end
end
