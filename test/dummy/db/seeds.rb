conexion = ActiveRecord::Base.connection();

conexion.execute("INSERT INTO public.sipd_dominio (id, dominio, mandato, 
  created_at, updated_at) VALUES (1, 'www.pasosdeJesus.org', 
  'Tecnología con misión', '2018-11-27', '2018-11-27');")

# De motores
Msip::carga_semillas_sql(conexion, 'msip', :datos)
motor = ['sipd', '../..']
motor.each do |m|
    Msip::carga_semillas_sql(conexion, m, :cambios)
    Msip::carga_semillas_sql(conexion, m, :datos)
end


# Usuario para primer ingreso msip, msip
conexion.execute("INSERT INTO public.usuario 
	(nusuario, email, encrypted_password, password, 
  fechacreacion, created_at, updated_at, rol) 
	VALUES ('sipd', 'heb412@localhost', 
  '$2a$10$tiVS67LKV97VUZ83a3rrkOA.zpBV4HDLvq7L2IfkP2vr6itef4N8O', '',
	'2018-11-28', '2018-11-28', '2018-11-28', 8);")

