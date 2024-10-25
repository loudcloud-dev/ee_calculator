json.extract! reimbursement, :id, :employee_id, :category, :activity_date, :invoice_reference_number, :invoice_amount, :reimbursable_amount, :reimbursed_amount, :participated_employee_ids, :supplier, :status, :created_at, :updated_at
json.url reimbursement_url(reimbursement, format: :json)
