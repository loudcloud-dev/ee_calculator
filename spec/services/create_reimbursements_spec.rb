require 'rails_helper'

RSpec.describe ReimbursementServices::CreateReimbursement do
  let(:employee) {
    Employee.create!(
      first_name: 'Juan',
      last_name: 'Dela Cruz',
      nickname: 'Juan'
    )
  }

  let(:category) {
    Category.create!(
      name: 'Category Sample',
      icon: 'category-icon-sample'
    )
  }

  let(:reimbursement_params) do
    image_path = Rails.root.join('app', 'assets', 'images', 'loudcloud_logo.png')

    {
      employee_id: employee.id,
      category_id: category.id,
      activity_date: Date.today,
      invoice_reference_number: 'INV-12345-2024',
      invoice_amount: 1000.0,
      image: image_path,
      supplier: 'Barkery Shop',
      participated_employee_ids: [ employee.id ]
    }
  end

  let(:service) { described_class.new(reimbursement_params) }

  before do
    allow(ENV).to receive(:[]).with('MONTHLY_BUDGET').and_return('1000')
  end

  describe '#perform' do
    context 'when reimbursement params are provided' do
      it 'creates reimbursement records and calculates employee budgets' do
        reimbursement = Reimbursement.create!(reimbursement_params)
        ReimbursementItem.create!(employee: employee, reimbursement: reimbursement, shared_amount: 200)

        # service = ReimbursementServices::CreateReimbursement.new(reimbursement_params)
        service.perform

        employee_budget = service.send(:calculate_employee_budget, service.instance_variable_get(:@reimbursement))

        expect(employee_budget[employee.id]).to eq(800)
      end
    end

    context 'when saving the reimbursement fails' do
      it 'returns an error' do
        invalid_params = reimbursement_params[:activity_date] = nil

        # service = ReimbursementServices::CreateReimbursement.new(reimbursement_params)
        result = service.perform

        expect(result[:success]).to be false
        expect(result[:errors]).to include("Activity date can't be blank")
      end
    end
  end

  describe '#allocate_initial_amount' do
    let(:employee2) {
      Employee.create!(
        first_name: 'John',
        last_name: 'Doe',
        nickname: 'John'
      )
    }

    before do
      reimbursement_params[:participated_employee_ids] << employee2.id
    end

    it 'correctly allocates initial amounts based on budgets' do
      service = ReimbursementServices::CreateReimbursement.new(reimbursement_params)
      employee_budgets = service.send(:calculate_employee_budget, service.instance_variable_get(:@reimbursement))

      distributions = service.send(:allocate_initial_amount, reimbursement_params[:invoice_amount], employee_budgets)

      expect(distributions.length).to eq(2)
      expect(distributions.map { |item| item[:shared_amount] }).to all(be <= 1000)
    end

    it 'incorrectly allocates initial amounts based on budgets' do
      reimbursement_params[:invoice_amount] = 2500 # Set the amount that exceeds the budget

      service = ReimbursementServices::CreateReimbursement.new(reimbursement_params)
      employee_budgets = service.send(:calculate_employee_budget, service.instance_variable_get(:@reimbursement))

      distributions = service.send(:allocate_initial_amount, reimbursement_params[:invoice_amount], employee_budgets)

      expect(distributions.length).to eq(2)
      expect(distributions.map { |item| item[:shared_amount].to_f }).to all(be >= 1000)
    end
  end

  describe '#allocate_excess_amount' do
    let(:employee2) {
      Employee.create!(
        first_name: 'John',
        last_name: 'Doe',
        nickname: 'John'
      )
    }

    before do
      reimbursement_params[:participated_employee_ids] << employee2.id
    end

    it 'allocates excess amount based on the remaining budget' do
      reimbursement_params[:invoice_amount] = 1800

      # Set a transaction/item to the 2nd employee
      # First employee: 1000
      # Second employee: 800
      reimbursement = Reimbursement.create!(reimbursement_params)
      ReimbursementItem.create!(employee: employee2, reimbursement: reimbursement, shared_amount: 200)

      service = ReimbursementServices::CreateReimbursement.new(reimbursement_params)
      employee_budgets = service.send(:calculate_employee_budget, service.instance_variable_get(:@reimbursement))

      initial_distributions = service.send(:allocate_initial_amount, reimbursement_params[:invoice_amount], employee_budgets)

      final_distributions = service.send(:allocate_excess_amount, reimbursement_params[:invoice_amount], employee_budgets, initial_distributions)

      total_allocated = final_distributions.sum { |distribution| distribution[:shared_amount].to_f }
      expect(total_allocated).to eq(1800)

      first_employee = final_distributions.find { |item| item[:employee_id] == employee.id }
      second_employee = final_distributions.find { |item| item[:employee_id] == employee2.id }

      expect(first_employee[:shared_amount]).to be == 1000
      expect(second_employee[:shared_amount]).to eq(800)
    end
  end
end
