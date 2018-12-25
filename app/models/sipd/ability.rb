# encoding: UTF-8

# Extediendo basicas
require 'sipd/ext/basicas_controller'
require 'sipd/ext/actorsocial'
require 'sipd/ext/anexo'
require 'sipd/ext/etiqueta'
require 'sipd/ext/fuenteprensa'
require 'sipd/ext/grupo'
require 'sipd/ext/grupoper'
require 'sipd/ext/oficina'
require 'sipd/ext/perfilactorsocial'
require 'sipd/ext/persona'
require 'sipd/ext/sectoractor'

module Sipd
	class Ability  < Cor1440Gen::Ability

    ROLSUPERADMIN = 8
    ROLDESARROLLADOR = 9

    ROLES = [
      ["Administrador", ROLADMIN],  # 1
      ["", 0], # 2
      ["", 0], # 3
      ["", 0], # 4
      ["Operador", ROLOPERADOR], # 5
      ["", 0], #6
      ["", 0], #7
      ["Superadministrador", ROLSUPERADMIN], #8
      ["Desarrollador", ROLDESARROLLADOR] #9
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
      "", #7
      "Los mismos de los administradores en cualquier dominio. " +
      "Crear copias de respaldo cifradas. " +
      "Administrar usuarios de cualquier dominio. " +
      "Administrar datos de tablas basicas de cualquier dominio. " +
      "Administrar actores sociales y personas de cualquier dominio. ", #8
      "Los mismos del superadministrador" #9
    ]

    BASICAS_PROPIAS = []

    def tablasbasicas 
      Sip::Ability::BASICAS_PROPIAS + 
        Sipd::Ability::BASICAS_PROPIAS
    end

	end
end
