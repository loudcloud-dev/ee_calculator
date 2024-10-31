class ReimbursementsController < InheritedResources::Base
  before_action :participated_employees, only: [:create, :update]

  def index
    @employee = Employee.where(status: 'active').order(:nickname).pluck(:nickname, :id)
    
    if params[:employee_id].present?
      # Query for filed reimbursements
      @filed_reimbursements = Reimbursement.select('reimbursements.*, categories.name')
                                           .joins(:category)
                                           .where(employee_id: params[:employee_id])
                                           .where.not(status: 'cancelled')

      # Query for reimbursement items
      @reimbursement_items = ReimbursementItem.select('reimbursements.category_id, SUM(reimbursement_items.shared_amount) AS total_shared_amount')
                                              .joins(:reimbursement)
                                              .where.not(reimbursements: { status: 'cancelled' })
                                              .where(employee_id: params[:employee_id])
                                              .where('reimbursements.activity_date >= ?', Date.today.at_beginning_of_month + 5.days)
                                              .where('reimbursements.activity_date <= ?', Date.today.at_beginning_of_month.next_month + 4.days)
                                              .group('reimbursements.category_id')

      @item_breakdown = Reimbursement.select('categories.name, reimbursements.activity_date, reimbursements.participated_employee_ids, reimbursement_items.shared_amount')
                                         .joins(:reimbursement_items)
                                         .joins(:category)
                                         .where(reimbursement_items: { employee_id: params[:employee_id] })
                                         .where('reimbursements.activity_date >= ?', Date.today.at_beginning_of_month + 5.days)
                                         .where('reimbursements.activity_date <= ?', Date.today.at_beginning_of_month.next_month + 4.days)
                                         .where.not(status: 'cancelled')
                                         .order('reimbursements.activity_date ASC')
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
