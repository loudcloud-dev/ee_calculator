ActiveAdmin.register ReimbursementItem do
  actions :all, except: [:new, :update, :destroy]
end