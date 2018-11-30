# Sipd
Agrega dominio a sip

## Usage
Tras instalarlo, se crea nueva tabla dominio con uno por omisión con id 1 
y se agrega dominio_id a todas las tablas de sip (excepto las de geografía)
con valor inicial 1.

La referencia dominio_id si es NULL indica que se aplica a todos los dominios.


## Installation
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

## Licencia

Domino público de acuerdo a legislación colombiana.
