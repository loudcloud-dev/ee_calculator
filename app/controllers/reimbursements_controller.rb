class ReimbursementsController < InheritedResources::Base

  private

    def reimbursement_params
      params.require(:reimbursement).permit(:employee_id, :category, :activity_date, :invoice_reference_number, :invoice_amount, :reimbursable_amount, :reimbursed_amount, :participated_employee_ids, :supplier, :status)
    end

end
