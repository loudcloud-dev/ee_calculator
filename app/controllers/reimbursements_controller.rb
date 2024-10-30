class ReimbursementsController < InheritedResources::Base

	before_action :participated_employees, only: [:create, :update]

	def new
		@reimbursement = Reimbursement.new
		@category = Category.where(status: 'active').order(:name).pluck(:name, :id)
		@employee = Employee.where(status: 'active').order(:nickname).pluck(:nickname, :id)
	end

	# def create
	# 	# Retrieve the invoice amount and participating employee IDs from params
	# 	category = params[:reimbursement][:category_id]
	# 	invoice_amount = params[:reimbursement][:invoice_amount].to_f
	# 	employees = Employee.where(id: params[:reimbursement][:participated_employee_ids]) # Fetching the participating employees
	
	# 	# Define the maximum monthly budget
	# 	max_monthly_budget = 1000
	
	# 	# Step 1: Calculate each employee's remaining budget
	# 	remaining_budgets = {}
	# 	employees.each do |employee|
	# 		# total_shared_amount = ReimbursementItem.where(employee_id: employee.id).sum(:shared_amount)
	# 		total_shared_amount = ReimbursementItem.joins(:reimbursement)
	# 																					 .where(employee_id: employee.id)
	# 																					 .where(reimbursements: { category_id: category })
	# 																					 .sum(:shared_amount)

	# 		remaining_budget = max_monthly_budget - total_shared_amount
	# 		remaining_budgets[employee.id] = remaining_budget if remaining_budget > 0
	# 	end

	# 	puts "Remaining budgets: #{remaining_budgets}"

	# 	# ------------------------------------------------------------------------------------------------------------------------------------------------
	
	# 	# Step 2: Calculate initial share for each employee
	# 	num_employees = remaining_budgets.length
	# 	if num_employees > 0
	# 		initial_share = invoice_amount / num_employees
	
	# 		# Step 3: Distribute shares, taking into account remaining budgets
	# 		reimbursement_items = []
	
	# 		remaining_budgets.each do |employee_id, remaining_budget|
	# 			shared_amount = [initial_share, remaining_budget].min
	# 			reimbursement_items << { employee_id: employee_id, shared_amount: shared_amount }
	# 		end

	# 		puts "Reimbursement Items #{reimbursement_items}"
	
	# 		# Step 4: Adjust if total allocated exceeds invoice amount
	# 		total_allocated = reimbursement_items.sum { |item| item[:shared_amount] }

	# 		puts "Total Allocated #{total_allocated}"
	
	# 		if total_allocated < invoice_amount
	# 			# Calculate how much needs to be allocated to meet the invoice amount
	# 			excess_needed = invoice_amount - total_allocated
	
	# 			# Distribute excess to employees with remaining budgets
	# 			reimbursement_items.each do |item|
	# 				employee_id = item[:employee_id]
	# 				additional_share = [excess_needed, remaining_budgets[employee_id] - item[:shared_amount]].min
	
	# 				item[:shared_amount] += additional_share
	# 				excess_needed -= additional_share
	# 				break if excess_needed <= 0
	# 			end
	# 		end

	# 		puts "Invoice Amount: #{invoice_amount}"
	# 		puts "Reimbursement Items: #{reimbursement_items}"
	# 		puts "Reimbursable Amount: #{reimbursement_items.sum { |item| item[:shared_amount] }}"
			
	# 		# reimbursement_items.each do |item|
	# 		# 	puts "Employee ID: #{item[:employee_id]}, Shared Amount: #{item[:shared_amount]}"
	# 		# end
	# 	end
	# end

	def create
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
