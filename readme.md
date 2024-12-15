# Pré-requis

Pour pouvoir compiler ce projet, il est nécessaire de posséder `flex`, `bison`.

# Compilation

Voici la commande permettant de compiler le projet 

```bash
make
```

Cette commande génerera l'exécutable nommé `algo`.

Pour supprimer tous les fichiers liées à la compilation vous pouvez utiliser 
la commande suivante

```bash
make clean
```

Pour compiler et lancer le compilateur en même temps vous pouvez utiliser la 
commande :

```bash
make run
```

une fois cette commande lancé, vous pourrez rentrer directement sur l'entrée 
standard du code ALgo.

# Utilisation

Un script `run.sh` a été placé à la racine du projet pour faciliter 
l'exécution de code à partir de fichier source. Voici la commande à rentrer 
pour utiliser le script : 

```bash
./run.sh filename.tex ...
```

Il est également possible de rentrer plusieurs fichiers en même temps. Le 
script lancera tous les fichiers rentrés un à un et lancera un test valgrind 
pour observer les fuites potentielles de mémoires. Par exemple pour 
exécuter tous les fichiers de test présents dans le dossier **test** il 
suffit de rentrer la commande suivante :

```bash
./run.sh test/*.tex
```

Ainsi il suffit de placer dans le dossier **test** des fichiers de code  
supplémentaires pour que ceux-ci soient exécuté.
