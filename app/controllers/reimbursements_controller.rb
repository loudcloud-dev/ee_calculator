class ReimbursementsController < InheritedResources::Base

  before_action :participated_employees, only: [:create, :update]

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
