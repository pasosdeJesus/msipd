module Sipd
	class Ability  < ::Msip::Ability

    ROLDIR = 3
    ROLSUPERADMIN = 8
    ROLDESARROLLADOR = 9

    ROLES = [
      ["Administrador", ROLADMIN],  # 1
      ["", 0], # 2
      ["Directivo", ROLDIR], # 3
      ["", 0], # 4
      ["Operador", ROLOPERADOR], # 5
      ["", 0], #6
      ["", 0], #7
      ["Superadministrador", ROLSUPERADMIN], #8
      ["Desarrollador", ROLDESARROLLADOR] #9
    ]

    ROLES_CA = [
      "Administrar usuarios de su dominio. " +
      "Administrar datos de tablas básicas de su dominio. " +
      "Administrar actores sociales y personas de su dominio. ",
      "", #2
      "Los mismos del administrador en su dominio. ", #3
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
      Msip::Ability::BASICAS_PROPIAS + 
        Sipd::Ability::BASICAS_PROPIAS
    end

    # Retorna los dominios en los que está el usuario actual
    def dominio_ids(usuario)
      if usuario.rol == ROLSUPERADMIN ||
          usuario.rol == ROLDESARROLLADOR then
        Sipd::Dominio.all.pluck(:id)
      else
        usuario.dominio_ids
      end
    end

    # Se definen habilidades con cancancan
    # Util en motores y aplicaciones de prueba
    # En aplicaciones es mejor escribir completo el modelo de autorización
    # para facilitar su análisis y evitar cambios al actualizar motores
    # @usuario Usuario que hace petición
    def initialize_sipd(usuario = nil)
      # El primer argumento para can es la acción a la que se da permiso, 
      # el segundo es el recurso sobre el que puede realizar la acción, 
      # el tercero opcional es un diccionario de condiciones para filtrar 
      # más (e.g :publicado => true).
      #
      # El primer argumento puede ser :manage para indicar toda acción, 
      # o grupos de acciones como :read (incluye :show e :index), 
      # :create, :update y :destroy.
      #
      # Si como segundo argumento usa :all se aplica a todo recurso, 
      # o puede ser una clase.
      # 
      # Detalles en el wiki de cancan: 
      #   https://github.com/ryanb/cancan/wiki/Defining-Abilities

      can :read, Sipd::Dominio
      initialize_msip(usuario)
      # No se autorizan usuarios con fecha de deshabilitación
      if !usuario || usuario.fechadeshabilitacion
        return
      end
      if usuario && usuario.rol then
        case usuario.rol 
        when Ability::ROLADMIN, Ability::ROLDESARROLLADOR, Ability::ROLSUPERADMIN
          cannot manage, Msip::Respaldo7z
          if usuario.rol == Ability::ROLSUPERADMIN ||
              usuario.rol == Ability::ROLDESARROLLADOR
            can :manage, Sipd::Dominio
            can :manage, Msip::Respaldo7z
          end
        end
      end
    end # def initialize

  end
end
