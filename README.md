### GALATI Mathias 
### Étudiant à l'Université de Strasbourg en Biologie Structurale intégrative et Bio-Informatique
### Stage M2S4 2019 : CIRAD Montpellier

***************
### Préambule
Ce dépot GitHub permet de regrouper l'ensemble des démarches et protocoles adoptés dans le cadre d'un sujet de stage en métabarcoding et d'un autre sujet en métagénomique.

***************
### Sommaire :
1. Description rapide de l'ensemble des répertoires du GitHub ainsi que de l'architecture adoptée
2. Guide utilisateur des scripts correspondants aux workflows Métabarcoding
3. Guide utilisateur des scripts correspondants aux workflows Métagénomique
4. Ensemble des ressources utilisées
<!-- -->
Un fichier de biliographie sera édité et mis à disposition en fin de stage

**************
### 1. Architucture des répertoires :
- Biblio : Fichier qui contiendra la bilbiographie de l'ensemble du stage
- metabarcoding/           
    * Répertoire contenant les différents workflows de scripts permettant l'analyse des données 
- metabarcoding/16S/
    * Répertoire contenant les différents scripts pour données taxonomiques de type 16S :  
        * 0 = Sous-échantillonnage
        * 1 = Analyse fastQC / multiQC
        * 2 = Trim Galore et Cutadapt
        * 3.1 = Analyse avec l'approche dada2
        * 3.2 = Analyse avec l'approche deblur
        * 3.3 = Analyse avec l'approche vsearch
        
- metabarcoding/ITS/    
    * Répertoire contenant les différents scripts pour des données taxonomiques de type ITS :  
        * 0 = Sous-échantillonnage
        * 1 = Analyse fastQC / multiQC
        * 2 = Trim Galore et Cutadapt
        * 3.1 = Analyse avec l'approche dada2
        * 3.2 = Analyse avec l'approche deblur
        * 3.3 = Analyse avec l'approche vsearch  
- metagenomique/    
    * Répertoire contenant :  
        * Un fichier de texte de notes sur le début d'élaboration d'un workflow avec Snakemake sous conda 
- tuto
    * Répertoire contenant :  
        * Un fichier de texte de notes sur le début d'élaboration d'un workflow avec Snakemake sous conda 
        
*************** 
### 2. Métabarcoding    
Les données sont issues de séquencage Illumina MiSeq de régions taxonomiques 16S et ITS d'échantillons de pommes et de mangues.    
<!-- -->
Les scripts sub_*S.sh ont permis de sous-échantillonner les données afin de permettre des executions plus rapide des autres scripts sur les nœuds de calculs du cluster jusqu'à aboutir à des scripts finaux qui fonctionnent.    
<!-- -->
Pour commencer le workflow, les scripts 0_fastqc.sh permettent d'obtenir une première analyse de la composition en séquence des deux jeux de données.   
<!-- -->
Ensuite, les scripts 1_trim-galore_cutadapt.sh permettent de supprimer les primers et les adaptateurs de séquençage.
<!-- -->
Puis dans leurs répertoires respectifs, les scripts 2_S* permettent les analyses sur les jeux de données sous-échantillonnés et les scripts 2_q2_* permettent les analyses sur les vrais jeux de données raccourcis des primers et des adaptateurs.

### Avancement des scripts finaux
- [X] 16S
    - [X] dada2
    - [X] deblur
    - [X] vsearch
- [X] ITS
    - [X] dada2
    - [X] deblur
    - [X] vsearch

### Statistiques   
Issus des analyses bioinformatiques précédentes, les fichiers suivants sont nécéssaires pour les scripts de statistiques :    
* ASV-table.biom.tsv qui correspond à la table d'OTU/ASV)
* taxonomy.tsv qui correspond à l'assignation taxonomique
* metadata.tsv qui correspond à l'ensemble des métadonnées des expériences
<!-- -->
Dans le fichier des métadonnées, il faut créer une colonne SAMPLE en plus du nom de colonnes.
<!-- -->
Packages R utilisés :
- phyloseq
- DESeq2
- dada2
- ggplot2
- dplyr
- vegan
- magrittr
- decontam
- scales
- reshape2

