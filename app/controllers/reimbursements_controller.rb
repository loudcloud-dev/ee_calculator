class ReimbursementsController < InheritedResources::Base
  before_action :participated_employees, only: [:create, :update]

  def index
    @employee = Employee.where(status: 'active').order(:nickname).pluck(:nickname, :id)
    
    if params[:employee_id].present?
      start_date = Date.new(Date.today.year, params[:date][:month].to_i, 5)
      end_date_month = params[:date][:month].to_i == 12 ? 1 : params[:date][:month].to_i + 1
      end_date_year = params[:date][:month].to_i == 12 ? Date.today.year + 1 : Date.today.year
      end_date = Date.new(end_date_year, end_date_month, 4)

      @filed_reimbursements = Reimbursement.select('reimbursements.*, categories.name')
                                           .joins(:category)
                                           .where(employee_id: params[:employee_id])
                                           .where.not(status: 'cancelled')
                                           .order('reimbursements.activity_date DESC')

      @reimbursement_items = ReimbursementItem.select('reimbursements.category_id, SUM(reimbursement_items.shared_amount) AS total_shared_amount')
                                              .joins(:reimbursement)
                                              .where.not(reimbursements: { status: 'cancelled' })
                                              .where(employee_id: params[:employee_id])
                                              .where('reimbursements.activity_date >= ?', start_date)
                                              .where('reimbursements.activity_date <= ?', end_date)
                                              .group('reimbursements.category_id')

      @item_breakdown = Reimbursement.select('categories.name, reimbursements.activity_date, reimbursements.participated_employee_ids, reimbursement_items.shared_amount')
                                     .joins(:reimbursement_items)
                                     .joins(:category)
                                     .where(reimbursement_items: { employee_id: params[:employee_id] })
                                     .where('reimbursements.activity_date >= ?', start_date)
                                     .where('reimbursements.activity_date <= ?', end_date)
                                     .where.not(status: 'cancelled')
                                     .order('reimbursements.activity_date DESC')
    end
  end

  def new
    @reimbursement = Reimbursement.new
    @category = Category.where(status: 'active').order(:name).pluck(:name, :id)
    @employee = Employee.where(status: 'active').order(:nickname).pluck(:nickname, :id)
  end

  def create
    # TO DO
    # Unit tests for create action
    ReimbursementServices::CreateReimbursement.call(reimbursement_params)
  end
  
  private

  def reimbursement_params
    params.require(:reimbursement).permit(:employee_id, :category_id, :activity_date, :invoice_reference_number, :invoice_amount, :reimbursable_amount, :reimbursed_amount, :supplier, :status, participated_employee_ids: [])
  end

  def participated_employees
    params[:reimbursement][:participated_employee_ids].reject!(&:blank?) if params[:reimbursement][:participated_employee_ids]
  end
end
