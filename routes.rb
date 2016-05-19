Rails.application.routes.draw do

  get 'zarinpal' => 'main#pay'
  match '/pay' => 'zarinpal#pay', via: :post
  match '/pay' => 'zarinpal#pay', via: :get
  get 'zarinpal/:id' => 'zarinpal#verify'
  
end
