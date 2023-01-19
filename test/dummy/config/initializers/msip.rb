require 'msipd/version'

Msip.setup do |config|
  config.ruta_anexos = ENV.fetch('SIP_RUTA_ANEXOS', 
                                 "#{Rails.root}/archivos/anexos")
  config.ruta_volcados = ENV.fetch('SIP_RUTA_VOLCADOS',
                                   "#{Rails.root}/archivos/bd")
  config.titulo = "msipd #{Msipd::VERSION}"
  config.descripcion = "Motor que extiende msip con dominios"
  config.codigofuente = "https://github.com/pasosdeJesus/msipd"
  config.urlcontribuyentes = "https://github.com/pasosdeJesus/msipd/graphs/contributors"
  config.urlcreditos = "https://github.com/pasosdeJesus/msipd/blob/master/CREDITOS.md"
  config.agradecimientoDios = "<p>
Agradecemos a Jesús/Dios por el poder que nos ha dado:
</p>
<blockquote>
  <p>
  Porque no nos ha dado Dios espíritu de cobardía
  sino de poder, de amor y de dominio propio.
  </p><p>
  2 Timoteo 1:7
  </p>
</blockquote>".html_safe

  config.longitud_nusuario = 10
end
