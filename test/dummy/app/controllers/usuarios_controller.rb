require 'sipd/concerns/controllers/usuarios_controller'

class UsuariosController < Msip::ModelosController
    include Sipd::Concerns::Controllers::UsuariosController
end
