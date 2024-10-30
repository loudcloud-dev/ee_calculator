# app/services/reimbursement_services/create_reimbursement.rb
module ReimbursementServices
  class CreateReimbursement < ApplicationService
    def initialize(params)
      @reimbursement_params = params
    end

    def perform
      process
    end

    private

    def process
      # Create and save the reimbursement record
      @reimbursement = Reimbursement.new(@reimbursement_params)

			remaining_budgets = calculate_remaining_budgets(@reimbursement)
			distribute_budget(@reimbursement.invoice_amount, remaining_budgets)
      
      # if @reimbursement.save
      #   puts "Reimbursement saved with ID: #{@reimbursement.id}"
        
      #   # Call method to calculate and distribute the budget for reimbursement items
      #   calculate_remaining_budget(@reimbursement)
      # else
      #   puts "Failed to save Reimbursement: #{@reimbursement.errors.full_messages}"
      # end
    end

    def calculate_remaining_budgets(reimbursement)
      # Retrieve the invoice amount and participating employee IDs from params
      category = reimbursement.category_id
      invoice_amount = reimbursement.invoice_amount.to_f
      
      monthly_budget = 1000
      remaining_budgets = {}

      employees = Employee.where(id: @reimbursement_params[:participated_employee_ids])
      employees.each do |employee|
        total_shared_amount = ReimbursementItem.joins(:reimbursement)
                                               .where(employee_id: employee.id)
                                               .where(reimbursements: { category_id: category })
                                               .sum(:shared_amount)

        remaining_budget = monthly_budget - total_shared_amount
        remaining_budgets[employee.id] = remaining_budget if remaining_budget > 0
      end

      remaining_budgets
    end

    def distribute_budget(invoice_amount, remaining_budgets)
      num_employees = remaining_budgets.length
      return if num_employees.zero?

      initial_share = invoice_amount / num_employees
      reimbursement_items = []

      remaining_budgets.each do |employee_id, remaining_budget|
        shared_amount = [initial_share, remaining_budget].min
        reimbursement_items << { employee_id: employee_id, shared_amount: shared_amount }
      end

      # Adjust if total allocated exceeds invoice amount
      total_allocated = reimbursement_items.sum { |item| item[:shared_amount] }
      if total_allocated < invoice_amount
        excess_needed = invoice_amount - total_allocated

        # Distribute excess to employees with remaining budgets
        reimbursement_items.each do |item|
          employee_id = item[:employee_id]
          additional_share = [excess_needed, remaining_budgets[employee_id] - item[:shared_amount]].min

          item[:shared_amount] += additional_share
          excess_needed -= additional_share
          break if excess_needed <= 0
        end
      end

			puts "Invoice Amount: #{invoice_amount}"
			puts "Reimbursement Items: #{reimbursement_items}"
			puts "Reimbursable Amount: #{reimbursement_items.sum { |item| item[:shared_amount] }}"
			
			reimbursement_items.each do |item|
				puts "Employee ID: #{item[:employee_id]}, Shared Amount: #{item[:shared_amount]}"
			end

      # Save reimbursement items
      # reimbursement_items.each do |item|
      #   ReimbursementItem.create(
      #     reimbursement_id: @reimbursement.id,
      #     employee_id: item[:employee_id],
      #     shared_amount: item[:shared_amount]
      #   )
      # end

      # puts "Reimbursement Items created: #{reimbursement_items}"
    end
  end
end
