#!/bin/sh
# Convierte uso de sipd a msipd

echo "Cambiando directorios"
for i in `find . -name sipd -type d`; do 
  echo $i
  n=`echo $i | sed -e "s/sipd/msipd/g"`
  git mv $i $n
done

for i in `git ls-tree -r main --name-only`; do 
  echo $i | grep "db/migrate" > /dev/null 2>&1
  if (test "$?" = "0") then {
    echo "Excluyendo de conversión $i"
  } else {
    n=`echo $i | sed -e "s/\([^A-Za-z]\)\(sipd[^A-Za-z]\)/\1m\2/g"`
    if (test "$n" != "$i") then {
      echo "Cambiando archivo $i->$n"
      git mv $i $n
    } fi;
    grep "sip_grupo_id" $n > /dev/null
    if (test "$?" = "0") then {
      echo "Remplazando sip_grupo_id por grupo_id en $n";
      sed -i -e "s/sip_grupo_id/grupo_id/g" $n
    } fi;
    grep "actividad_m?sip_anexo" $n > /dev/null
    if (test "$?" = "0") then {
      echo "Remplazando actividad_sip_anexo por actividad_anexo en $n";
      sed -i -e "s/actividad_m?sip_anexo/actividad_anexo/g" $n
    } fi;
    grep "sip" $n > /dev/null
    if (test "$?" = "0") then {
      echo "Remplazando sipd como palabra en $n";
      sed -i -e "s/\([^A-Za-z]\)\(sipd[^A-Za-z]\)/\1m\2/g" $n
      sed -i -e "s/^\(sipd[^A-Za-z]\)/m\1/g" $n
      sed -i -e "s/\([^A-Za-z]\)\(sipd\)$/\1m\2/g" $n
    } fi;
    grep "Sipd" $n > /dev/null
    if (test "$?" = "0") then {
      echo "Remplazando Sipd como palabra en $n";
      sed -i -e "s/\([^A-Za-z]\)S\(ipd[^A-Za-z]\)/\1Ms\2/g" $n
      sed -i -e "s/S\(ipd[^A-Za-z]\)/Ms\1/g" $n
      sed -i -e "s/\([^A-Za-z]\)S\(ipd\)$/\1Ms\2/g" $n
    } fi;
  } fi;
done

cp ../msip/.simplecov .
if (test -f test/dummy/config/application.rb) then {
  cp ../msip/.simplecov .
} fi;

cp ../msip/bin/{regresion.sh,gc.sh,brakeman,bundler-audit,rubocop} bin/
cp ../msip/{.rubocop.yaml,Makefile} ./

