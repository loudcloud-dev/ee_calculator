require 'rails_helper'

RSpec.describe ReimbursementServices::GetReimbursements do
  let(:employee) {
    Employee.create!(
      first_name: 'Juan',
      last_name: 'Dela Cruz',
      nickname: 'Juan'
    )
  }

  let(:category) { Category.create!(name: 'Eat Takes Two') }

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

  let(:params) do
    {
      employee_id: employee.id,
      date: { month: 10 }
    }
  end

  let(:service) { described_class.new(params) }

  before do
    reimbursement = Reimbursement.create!(reimbursement_params)
    ReimbursementItem.create!(employee: employee, reimbursement: reimbursement, shared_amount: 1000)
    allow(Reimbursement).to receive(:filed_reimbursements).and_return([:mocked_filed_reimbursement])
    allow(ReimbursementItem).to receive(:reimbursement_items).and_return([:mocked_reimbursement_item])
    allow(Reimbursement).to receive(:item_breakdown).and_return(
      {
        name: 'Eat Takes Two',
        activity_date: Date.today,
        participated_employee_ids: [ employee.id ],
        shared_amount: 1000
      }
    )
  end

  describe '#perform' do
    it 'returns a hash of filed reimbursements, reimbursement items, and item breakdown' do
      result = service.perform

      expect(result).to be_a(Hash)
      expect(result.keys).to contain_exactly(:filed_reimbursements, :reimbursement_items, :item_breakdown)
      expect(result[:filed_reimbursements]).to eq([:mocked_filed_reimbursement])
      expect(result[:reimbursement_items]).to eq([:mocked_reimbursement_item])
      expect(result[:item_breakdown]).to eq(
        {
          name: 'Eat Takes Two',
          activity_date: Date.today,
          participated_employee_ids: [ employee.id ],
          shared_amount: 1000
        }
      )
    end
  end
end
