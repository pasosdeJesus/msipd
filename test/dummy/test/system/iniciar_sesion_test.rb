require "application_system_test_case"

class IniciarSesionTest < ApplicationSystemTestCase

  test "iniciar sesión" do
    skip
    Msip::CapybaraHelper.iniciar_sesion(self, root_path, 'msipd', 'msipd')
  end

end
