require 'sipd/version'

Sip.setup do |config|
  config.ruta_anexos = ENV.fetch('SIP_RUTA_ANEXOS', 
                                 "#{Rails.root}/archivos/anexos")
  config.ruta_volcados = ENV.fetch('SIP_RUTA_VOLCADOS',
                                   "#{Rails.root}/archivos/bd")
  config.titulo = "sipd #{Sipd::VERSION}"
  config.descripcion = "Motor que extiende sip con dominios"
  config.codigofuente = "https://github.com/pasosdeJesus/sipd"
  config.urlcontribuyentes = "https://github.com/pasosdeJesus/sipd/graphs/contributors"
  config.urlcreditos = "https://github.com/pasosdeJesus/sipd/blob/master/CREDITOS.md"
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
