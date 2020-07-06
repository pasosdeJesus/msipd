# Motor rails para agregar dominio a sip
[![Build Status](https://semaphoreci.com/api/v1/vtamara/sipd/branches/master/badge.svg)](https://semaphoreci.com/vtamara/sipd) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/sipd/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/sipd) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/sipd/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/sipd) [![security](https://hakiri.io/github/pasosdeJesus/sipd/master.svg)](https://hakiri.io/github/pasosdeJesus/sipd/master) [![Dependencias](https://gemnasium.com/pasosdeJesus/sipd.svg)](https://gemnasium.com/pasosdeJesus/sipd) 

![Logo de sipd](https://raw.githubusercontent.com/pasosdeJesus/sipd/master/test/dummy/app/assets/images/logo.jpg)

Agrega dominio a sip

## Uso

Es posible indicar a que dominio pertenece un usuario, una fuente de prensa,
una etiqueta, un actor social, una persona.

Y sólo están disponibles cuando se ingresan por un dominio las de ese dominio.



## Instalación
Agregue esta líne al Gemfile de su aplicación/motor:

```ruby
gem 'sipd'
```

Y ejecute:
```bash
$ bundle
```

## Contribuciones

Se aprecian

## Rationale

Hemos pensado 2 formas de agregar dominio a sip, ambas con una tabla 
	sipd_dominio

1. Agregando referencia dominio_id practicamente a todas las tablas de sip
   (excepto las tablas unión). i.e Relaciones n a 1 de cada tabla a la 
   tabla dominio.  Digamos un usuario estaría máximo a en un dominio (excepto
   si es NULL por ejemplo para superadministrador o desarrollador).
2. Agregando una tabla unión por cada tabla de sip con sipd_dominio.
   Esto permitiría relaciones muchos a muchos. Por ejemplo un usuario podría
   estar en varios dominios.   Un actor social o persona podría asociarse a 
   varios dominios (digamos para disminuir repetición).


La opción 1 nos parece más similar a LDAP.
La opción 2 nos parece más expresiva (y compleja?) que LDAP.

Hemos pensando esta convención: Cuando dominio_id se deja en NULL en un 
registro es porque aplica a todo dominio (en el caso de usuario
util para superadministrador, desarrollador, en el caso de
etiqueta útil  para comunes a todos los dominios, en el
caso de persona y actor social tal vez personalidades públicas (no util?).

# Opcion 1. Relación muchos a uno con tabla dominio
   Ha sido dificil de implementar a nivel de modelos y controladores
   de forma que no se requieran cambios amplios a las aplicaciones y
   motores que usan sip.   Pues ha requerido parchar las clase
   basicas_controller y las clases de las tablas de sip, que técnicamente
   no resultó trivial.
 
   A nivel de permisos y vistas parece fácil con una técnica como la de grupos
   en cor1440_cinep.


# Opción 2. Relación muchos a muchos con tabla dominio
  Parece menos invasivo a nivel de base de datos pues no tendrían
  que modificarse las tablas de sip (para agregar dominio_id), sólo
  agregar tablas como sipd_dominio_usuario y así para cada tabla
  de sip.
  
  A nivel de modelos y controladores se sigue viendo la necesidad de parchar
  los de sip para contar con las funciones auxiliares y las facilidades
  para generar las vistas de las tablas de sip.

  A nivel de permisos y vistas parece que no incrementa la complejidad que ya
  debe agregarse on la Opción 1 para tener vistas diferentes por dominio
  (a un usuario en varios dominios se le presentarían los campos
   agregados de los diversos dominios a los que pertenece).
  De una manera similara a sivel2_mujeresindigenas que tiene cambios en
  la ficha caso dependiendo de la organización del usuario, con 
  administradores que pueden ver campos de todas las organizaiones.


## Licencia

Empleamos la licencia ISC, puede verla en español en <https://github.com/pasosdeJesus/sipd/blob/master/LICENCIA.md>.

Es practicamente equivalente a Dominio Público de acuerdo a la legislación colombiana, ver <https://github.com/pasosdeJesus/sip/wiki/Modificaciones-a-la-legislaci%C3%B3n-relacionada-con-dominio-p%C3%BAblico-en-Colombia>
