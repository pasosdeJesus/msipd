# encoding: UTF-8

conexion = ActiveRecord::Base.connection();

# De motores
Sip::carga_semillas_sql(conexion, 'sip', :datos)
motor = ['sipd', '../..']
motor.each do |m|
    Sip::carga_semillas_sql(conexion, m, :cambios)
    Sip::carga_semillas_sql(conexion, m, :datos)
end


# Usuario para primer ingreso sip, sip
conexion.execute("INSERT INTO usuario 
	(nusuario, email, encrypted_password, password, dominio_id,
  fechacreacion, created_at, updated_at, rol) 
	VALUES ('sipd', 'heb412@localhost', 
  '$2a$10$tiVS67LKV97VUZ83a3rrkOA.zpBV4HDLvq7L2IfkP2vr6itef4N8O', '',
	NULL, '2018-11-28', '2018-11-28', '2018-11-28', 8);")

