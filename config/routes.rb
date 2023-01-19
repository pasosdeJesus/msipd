Msipd::Engine.routes.draw do

 
  resources :dominios, path_names: { new: 'nuevo', edit: 'edita' }
  
  namespace :admin do
    ab=::Ability.new
    ab.tablasbasicas.each do |t|
      if (t[0] == "Msipd") 
        c = t[1].pluralize
        resources c.to_sym, 
          path_names: { new: 'nueva', edit: 'edita' }
      end
    end
  end

end
