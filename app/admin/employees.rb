ActiveAdmin.register Employee do
  permit_params :first_name, :last_name, :nickname, :status

  filter :first_name
  filter :last_name
  filter :nickname
  filter :status
  filter :created_at
  filter :updated_at

  actions :all, except: [:destroy]

  config.sort_order = 'id_asc'
  
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
