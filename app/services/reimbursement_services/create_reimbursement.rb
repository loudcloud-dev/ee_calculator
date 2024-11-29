module ReimbursementServices
  class CreateReimbursement < ApplicationService
    def initialize(params)
      @reimbursement = Reimbursement.new(params)
    end

    def perform
      return validate unless validate[:success]

      process
    end

    private

    def validate
      employee_budgets = calculate_employee_budget(@reimbursement)
      
      return { success: false, errors: ["Selected employees have no balance left to reimburse."] } if employees_balance(employee_budgets)
      return { success: false, errors: @reimbursement.errors.full_messages } unless @reimbursement.save

      { success: true }
    end

    def process
      employee_budgets = calculate_employee_budget(@reimbursement)
      distributions = distribute_expenses(@reimbursement.invoice_amount.to_f, employee_budgets)

      reimbursable_amount = (distributions.sum { |item| item[:shared_amount] }).round(2)
      @reimbursement.update(reimbursable_amount: reimbursable_amount)

      create_reimbursement_items(distributions)

      { success: true, reimbursement: @reimbursement }
    end

    def employees_balance(employee_budgets)
      employee_budgets.values.all? { |balance| balance == 0 }
    end

    # Find the participating employees to calculate and save their remaining budget for the current month (from the 6th of the current month to the 5th of the next month)
    def calculate_employee_budget(reimbursement)
      category_id = reimbursement.category_id
      employee_ids = reimbursement.participated_employee_ids

      employee_budgets = {}
      monthly_budget = ENV["MONTHLY_BUDGET"].to_i

      order_by_clause = employee_ids.each_with_index.map { |id, index| "WHEN #{id} THEN #{index}" }.join(" ")
      employees = Employee.where(id: employee_ids)
                          .order(Arel.sql(ActiveRecord::Base.sanitize_sql_array("CASE id #{order_by_clause} END")))

      employees.each do |employee|
        used_budget = ReimbursementItem.used_budget_sum(
          employee_id: employee.id,
          category_id: category_id,
          activity_date: reimbursement.activity_date
        )

        employee_budget = monthly_budget - used_budget
        employee_budgets[employee.id] = employee_budget > 0 ? employee_budget : 0
      end

      employee_budgets
    end

    def distribute_expenses(invoice_amount, employee_budgets)
      distributions = allocate_initial_amount(invoice_amount, employee_budgets)
      allocate_excess_amount(invoice_amount, employee_budgets, distributions)
    end

    # Check if employee can shoulder the initial shared amount or just their remaining budget.
    def allocate_initial_amount(invoice_amount, employee_budgets)
      initial_share = invoice_amount / employee_budgets.length
      distributions = []

      employee_budgets.each do |employee_id, employee_budget|
        shared_amount = [ initial_share, employee_budget ].min
        distributions << { employee_id: employee_id, shared_amount: shared_amount }
      end

      distributions
    end

    # Check if there's an excess amount. Distribute the excess amount to those employees that still have available budget.
    def allocate_excess_amount(invoice_amount, employee_budgets, distributions)
      total_allocated = distributions.sum { |item| item[:shared_amount] }
      excess_amount = invoice_amount - total_allocated

      if total_allocated < invoice_amount
        eligible_employees = distributions.select do |item|
          remaining_budget = employee_budgets[item[:employee_id]] - item[:shared_amount]
          remaining_budget > 0
        end

        excess_share = excess_amount / eligible_employees.length

        eligible_employees.each do |item|
          employee_id = item[:employee_id]
          remaining_budget = employee_budgets[employee_id] - item[:shared_amount]

          additional_share = [ excess_share, remaining_budget ].min

          item[:shared_amount] += additional_share
          excess_amount -= additional_share
          break if excess_amount <= 0
        end
      end

      distributions
    end

    def create_reimbursement_items(distributions)
      distributions.each do |item|
        ReimbursementItem.create!(
          reimbursement_id: @reimbursement.id,
          employee_id: item[:employee_id],
          shared_amount: item[:shared_amount].round(2)
        )
      end
    end
  end
end
