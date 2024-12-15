#!/bin/sh
if [ $# -lt 1 ]; then
    echo "Usage: $0 <files> ..."
    exit 1
fi

make

for arg in "$@"
do 
  ./algo < $arg > algo.asm
  ./bin/asipro algo.asm $arg.asipro
done

clear
echo "=============================="
echo "=========EXECUTIONS==========="
echo "=============================="
for arg in "$@"
do 
  echo "==== Exécution de $arg ====\n"
  ./bin/sipro $arg.asipro
  rm -f $arg.asipro
  echo "\n"
  sleep 0.3
done
echo "=============================="
echo "==========VALGRIND============"
echo "=============================="

for arg in "$@"
do 
  echo "\n==== VALGRIND de $arg ====\n"
  valgrind --leak-check=full ./algo < $arg > /dev/null
  sleep 0.3
done

make clean
