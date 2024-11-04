module ReimbursementServices
  class GetReimbursements < ApplicationService
    def initialize(params)
      @reimbursement = params
    end

    def perform
      process
    end

    private

    def process
      {
        filed_reimbursements: Reimbursement.filed_reimbursements(@reimbursement[:employee_id]),
        reimbursement_items: ReimbursementItem.reimbursement_items(
          employee_id: @reimbursement[:employee_id],
          start_date: start_date,
          end_date: end_date
        ),
        item_breakdown: ReimbursementItem.item_breakdown(
          employee_id: @reimbursement[:employee_id],
          start_date: start_date,
          end_date: end_date
        )
      }
    end

    def start_date
      Date.new(Date.today.year, @reimbursement.dig(:date, :month)&.to_i || Date.today.month, 6)
    end

    def end_date
      (start_date + 1.month) - 1.day
    end
  end
end