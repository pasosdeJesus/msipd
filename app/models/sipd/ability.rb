# encoding: UTF-8

module Sipd
	class Ability  < Sip::Ability

    ROLSUPERADMIN = 8

    ROLES = [
      ["Administrador", ROLADMIN],  # 1
      ["", 0], # 2
      ["", 0], # 3
      ["", 0], # 4
      ["Operador", ROLOPERADOR], # 5
      ["", 0], #6
      ["Desarrollador", ROLOPERADOR] #7
      ["Superadministrador", ROLSUPERADMIN] #8
    ]

    ROLES_CA = [
        "Administrar usuarios de su dominio. " +
        "Administrar datos de tablas básicas de su dominio. ",
        "Administrar actores sociales y personas de su dominio. ",
      "", #2
      "", #3
      "", #4
      "", #5
      "", #6
      "Los mismos de superadministrador", #7
      "Crear copias de respaldo cifradas. " +
      " Administrar usuarios de cualquier dominio. " +
      " Administrar datos de tablas basicas de cualquier dominio. " +
      " Administrar actores sociales y personas de cualquier dominio. " #8
    ]

    BASICAS_PROPIAS = []

    def tablasbasicas 
      Sip::Ability::BASICAS_PROPIAS + 
        Sipd::Ability::BASICAS_PROPIAS
    end

	end
end
