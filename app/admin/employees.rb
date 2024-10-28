ActiveAdmin.register Employee do
  permit_params :first_name,
                :last_name,
                :nickname,
                :status

  remove_filter :reimbursements
  config.sort_order = 'id_asc'

  actions :all, except: [:destroy]
  
  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :nickname

      f.input :status, as: :select, collection: ['active', 'inactive'], include_blank: false

      f.actions
    end
  end
end
