Sipd::Engine.routes.draw do
  resources :dominios, path_names: { new: 'nuevo', edit: 'edita' }
end
