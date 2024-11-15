;  CONVERSION_IEEE754_EN_DECIMAL
;
;    AUTEURS      : Tristan Larue, Rose-Anne Dubois, Alexandre Bouchard, Émile Simoneau
;    DATE         : 15/11/2024
;    EQUIPE       : Gr03-Equipe 02
;    DESCRIPTION  :
;
;        Ce programme prend une séquence de 32 bits en entrée (format IEEE 754),
;        valide la saisie, puis convertit cette séquence en un nombre décimal.
;        Le programme inclut la gestion des erreurs de format et affiche le résultat.

         BR      a_verfor


; a_verfor (VÉRIFICATION)
;
;        Fonction qui invite l?utilisateur à entrer une séquence de 32 bits et
;        initialise les registres pour vérifier que chaque caractère est bien un 0 ou un 1.
;
;    PARAMÈTRES
;        tableau              : Adresse mémoire où chaque caractère entré est stocké.
;
;    Retourne :
;        a_mess_1             : un code d'erreur si la séquence contient des caractères non valides
;        a_mess_2             : un code d'erreur si la séquence contient une longueur incorrecte.
;        b_expfor             : la poursuite du programme vers l'exposant.

tableau:         .BLOCK  64
a_mesdeb:        .ASCII  "VEUILLEZ ENTRER 32 BITS : \x00"
a_mess_1:        .ASCII  "Erreur : Caractère invalide.\x00"
a_mess_2:        .ASCII  "Erreur : Tableau de taille invalide\x00"

a_verfor: LDA     0,i             ;initialise les 2 registres a 0
          LDX     0,i
          STRO    a_mesdeb,d      ;affiche le message d'initialisation du programme
          BR      a_bcl_1 

    a_bcl_1: CPX     64,i         ;=== BOUCLE PRINCIPALE DE VERIFICATION ===
             BREQ    b_expst      ; finit la boucle quand le tableau atteint sa taille maximale 

             CHARI   tableau,x    ; Récupérer le prochain caractère
             LDA     tableau,x    ; Charger dans la mémoire
    a_if_1:  CPA     2560,i       ; Vérifier si "\n"
    a_thn_1: BREQ    a_err_2      ; affiche un message d'erreur si le caractère est \n

             ADDX    2,i          ; Ajouter 1 à la longueur
    a_eif_2: CPA     12288,i      ; Comparer avec l'équivalent en code ASCII de 0
    a_thn_2: BREQ    a_bcl_1      ; si l'entrée est égale à 0 et qu'il reste de la place dans le tableau, on recommence une itération

    a_eif_3: CPA     12544,i      ; Comparer avec l'équivalent en code ASCII de 1
    a_thn_3: BREQ    a_bcl_1      ; si l'entrée est égale à un et qu'il reste de la place dans le tableau, on recommence une itération
    a_els_3: BRNE    a_err_1      ; Erreur si autre que 0 ou 1 ou fin 
                                

a_err_1: STRO    a_mess_1,d       ; Utilisé pour afficher un message d'erreur lors d'entrée des caractères invalides
         STOP
a_err_2: STRO    a_mess_2,d       ; Utilisé pour afficher un message d'erreur lors d'entrée des caractères invalides
         STOP


; b_expst (EXPOSANT)
;
;    Description :
;        Fonction qui extrait et calcule la valeur de l'exposant selon le format IEEE 754.
;
;    Paramètres :
;        tableau             : Adresse mémoire contenant la séquence binaire de l'exposant.
;        b_expo              : Emplacement mémoire où la valeur finale de l'exposant sera stockée.
;
;    Retourne :
;        b_mesfin            : Un message avec la valeur calculée de l'exposant pour affichage.
;        c_mantst            : La poursuite du programme vers la mantisse.

b_expo:          .WORD   0
b_mesfin:        .ASCII  "\nLa valeur de l'exposant est: \x00"

b_expst: SUBSP   4,i         ; SP: 0 est le total, 2 représente l'index principal
         LDA     0,i         ; Initialise la mantisse à 0 pour commencer à la manipuler

         STA     0,s         ; s'assure que le pointeur de pile soit vide
         STA     2,s         ; stocke 0 à un emplacement supplémentaire dans la pile pour utilisation ultérieure

         LDX     18,i        ; charge l'index du premier bit de l'exposant
         STX     2,s         ; stocke cet index dans la variable locale
         
         BR      b_expend    ; branchement pour commencer la boucle

b_expad: LDA     1,i         ;=== AJUSTEMENT D'EXPOSANT ===
         LDX     16,i        ; charge la valeur de la valeur située a l'index de x à modifier
         SUBX    2,s         ; fait le travail sur la prochaine valeur
         ASRX                ; décale les valeurs contenues dans le registre x et mets le dernier bit en retenue
         BR      b_if_1      ; branchement pour vérifier la valeur du dernier bit 

         
    b_if_1: CPX     0,i           ; initialise une boucle pour vérifier la valeur du dernier bit de l'exposant
    b_thn_1:BREQ    b_expend      ; sors de la boucle si le dernier bit est égal à 0
            ASLA                  ; décale tous les bits vers la gauche pour regarder la valeur du dernier bit       
            SUBX    1,i           ; enlève 1 pour vérifier la valeur du dernier bit
    b_eoi_1:BR      b_if_1        ; retourner au debut de la boucle


b_expend:    ADDA    0,s          ;=== BOUCLE EXPONENTIELLE ===   
             STA     0,s          ; ajoute 0 au pointeur de pile

             LDX     2,s          ; charge 2 dans x pour préparer la vérification
    b_if_2:  CPX     2,i          ; compare le registre x avec 2
    b_thn_2: BREQ    c_mantst     ; envoie au commencement du calcul de la mantisse si tous les bits servants à l'exposant ont été pris en compte    
         
    b_eoi_2: SUBX    2,i          ; passe au prochain index du tableau
             STX     2,s          ; ajoute 2 au pointeur de pile

             LDA     tableau,x    ; charge la valeur actuelle située dans x du tableau dans le registre a
    b_if_3:  CPA     12544,i      ; compare cette valeur avec 1   
    b_thn_3: BREQ    b_expad      ; si la valeur est égale à un, branchement à l'ajustement d'exposant
             LDA     0,i          ; charger 0 dans a pour les prochains calculs
    b_eoi_3: BR      b_expend     ; branche au début de la boucle pour finir le calcul sur l'exposant


; c_mantst (MANTISSE)
;
;    Description :
;        Fonction qui calcule la valeur de la mantisse en fonction de l'exposant
;        et la convertit en format décimal pour l'affichage.
;
;    Paramètres :
;        b_expo               : Valeur calculée de l'exposant utilisée pour déterminer la position de départ.
;        tableau              : Adresse mémoire contenant la séquence binaire de la mantisse.
;
;    Retourne :
;        c_mesfin             : Message avec la valeur calculée de la mantisse pour affichage.
;        d_decst              : La poursuite du programme après le calcul de la mantisse.

c_mesfin:  .ASCII  "\nLa valeur de la mantisse est: \x00"

c_mantst:LDA     0,s              ; mets fin au calcul de la puissance et libère le registre A de la pile
         SUBA    127,i            ; soustraire 127 au registre A pour s'ajuster au biais IEEE 754
         STA     b_expo,d         ; place la valeur de A dans b_expo
         STRO    b_mesfin,d       ; affiche un message avec la valeur calculée de l'exposant
         DECO    b_expo,d         ; affiche la valeur calculée de l'exposant
         SUBSP   2,i              ; soustrait 2 à la pile, si la valeur est 4 c'est l'index du dessus, égale à 2 représente l'index principal et égal à 0 représente le total
         LDA     0,i              ; mets 0 dans A pour la suite des calculs sur la mantisse
         STA     0,s              ; s'assure que le pointeur de pile est vide pour corriger des problèmes involontaires

         LDA     b_expo,d         ; calcule la position de départ du pointeur pour les nombres entiers
         ASLA                     ; décale les bits vers la gauche et mets le dernier bit dans la retenue
         ADDA    16,i             ; ajoute 16 au registre A pour se déplacer au début de la mantisse
         STA     4,s              ; rentre 4 dans le pointeur de pile pour initialiser l'index du dessus
         ADDA    2,i              ; ajoute 2 pour ajuster l'index actuel du tableau de mantisse
         STA     2,s              ; l'index actuel doit etre de 2 position plus haute car le décalage d'index est avant le tableau
         LDA     0,i              ; mets 0 dans A pour la suite des calculs
         BR      c_mntbd          ; branchement au calcul principal de la mantisse

c_mntad: LDA     1,i              ;=== BOUCLE POUR MANTISSE ===, charge 1 dans A pour l'itération dans la boucle de la mantisse
         LDX     4,s              ; charge l'index de départ de la mantisse depuis la pile dans X
         SUBX    2,s              ; réduit X de l'offset stocké à 2 dans le pointeur de piles pour se positionner correctement
         ASRX                     ; décale les bits vers la droite pour capturer le prochain bit de la mantisse
         BR      c_bcl_1          ; branchement à la première vérification
         
    c_bcl_1: CPX     0,i          ; compare X avec 0 pour vérifier le dernier bit de la mantisse
    c_thn_1: BREQ    c_mntbd      ; branche si x est à 0 pour le calcul final de la mantisse
             ASLA                 ; décale les bits vers la gauche pour préparer le prochain bit
             SUBX    1,i          ; féduit X de 1 pour vérifier le bit suivant
    c_eob_1: BR      c_bcl_1      ; branchement au début de la boucle pour une autre itération

c_mntbd:     ADDA    0,s          ; ajoute la valeur totale de la mantisse dans A
             STA     0,s          ; stocke le total dans la pile
         
    c_bcl_2: LDX     2,s          ; charge l'index actuel pour vérifier la position dans la mantisse
    c_if_2:  CPX     18,i         ; compare avec 18 pour vérifier si on a fini le calcul de la mantisse
    c_thn_2: BREQ    c_mntef      ; si tous les bits ont été traités, branchement vers la fin du code de la mantisse
    c_els_2: BRLT    d_decst      ; envoie le contenu restant de la mantisse à la partie décimale du code si X est plus petit que 18 
         
             SUBX    2,i          ; décale l'index de X vers le prochain bit
             STX     2,s          ; met à jour l'index de position dans la pile

             LDA     tableau,x    ; charge la valeur de mantisse depuis `tableau` à l'index X dans A
    c_if_3:  CPA     12544,i      ; compare A avec 12544 pour vérifier si le bit est à 1
    c_thn_3: BREQ    c_mntad      ; si A est égal à 12544 (à un), branche à c_mntad pour traiter
             LDA     0,i          ; charge 0 dans A pour réinitialiser si le bit est à 0
    c_eob_2: BR      c_mntbd      ; retourne à c_mntbd pour continuer le calcul de la mantisse


c_mntef: LDX     2,s              ; charge la position de l'index final de la mantisse depuis la pile dans X
         SUBX    2,i              ; réduit X pour vérifier la fin des bits de mantisse
         STX     2,s              ; met à jour l'index dans la pile
         BR      c_mntad          ; retourne au calcul de la mantisse pour finir le processus         
     
    
; d_decst (DÉCIMALE)
;
;    Description :
;        Ce sous-programme calcule la représentation décimale d'un nombre IEEE 754 
;        à partir de la mantisse et prépare les données pour l'affichage final.
;
;    Paramètres :
;        d_entier            : Emplacement mémoire où la valeur entière intermédiaire sera stockée.
;        tableau             : Adresse mémoire contenant la séquence binaire pour la conversion.
;
;    Retourne :
;        e_outst             : Transition vers l'arrondi final des décimales.

d_entier:  .WORD   0         ; Emplacement pour la valeur entière intermédiaire calculée


d_decst: LDA     0,s         ; libère le registre A de la pile
         STA     d_entier,d  ; Stockage de la valeur entière intermédiaire dans la mémoire

         LDA     4,s         ; Initialisation de la valeur minimale pour la conversion
         STA     2,s         ; Stockage de la valeur minimale à 2,s

         LDA     10000,i     ; Valeur temporaire pour le calcul des décimales, divisée par 2 avant usage
         STA     4,s         ; Stockage en mémoire sur la pile

         LDA     0,i         ; Initialisation du total actuel des décimales à 0
         STA     0,s         ; Stockage en mémoire
         LDX     b_expo,d    ; Charge la valeur de l'exposant de la mémoire dans le registre X 
         BRLT    d_bcl_1    ; Si l'exposant est négatif, passe au traitement spécifique d_decnex 
         BR      d_bcl_2     ; Transition vers le bloc de calcul des décimales 

d_dndone:LDA     4,s         ; Charge la valeur actuelle pour le calcul final des décimales
         STA     0,s         ; Stocke cette valeur dans la pile pour la suite des calculs
         LDA     14,i        ; Charge 14 qui est une valeur fixe dans le registre A, utilisée pour ajuster l'index minimal
         ADDA    2,i         ; Ajoute 2 à A pour ajuster l'index vers la position suivante
         STA     2,s         ; Stocke la nouvelle valeur de l'index dans la pile
         BR      d_bcl_2     ; Retourne à la boucle principale de calcul des décimales 

    d_bcl_1: LDA     4,s         ; Charge la valeur actuelle pour les calculs de décimales
             ASRA                ; Divise la valeur par 2 en décalant à droite
             STA     4,s         ; Met à jour la valeur divisée dans la pile
    d_if_1:  CPX     -1,i        ; Compare X avec -1 pour vérifier si la fin des ajustements est atteinte
    d_thn_1: BREQ    d_dndone    ; Si la comparaison est vraie, passe à la fin de la gestion des décimales d_dndone
             ADDX    1,i         ; Incrémente X pour passer à l'index suivant
    d_eob_1: BR      d_bcl_1     ; Retourne au début de d_bcl_1 pour continuer la division 
         
d_dcad:      LDA     0,s         ; Chargement de la valeur actuelle des décimales
             ADDA    4,s         ; Addition de la valeur de 4,s à la valeur actuelle des décimales
             STA     0,s         ; Mise à jour de la valeur actuelle des décimales
             BR      d_bcl_2     ; Retour au bloc de calcul des décimales 

    d_bcl_2: LDX     2,s         ; Chargement de l'index de la mantisse pour la conversion 
    d_if_2:  CPX     62,i        ; Comparaison de l'index avec la limite de 62
    d_thn_2: BREQ    d_rndst     ; Transition vers l'arrondi final si la limite est atteinte

             ADDX    2,i         ; Incrémentation de l'index pour la prochaine décimale
             STX     2,s         ; Mise à jour de l'index en mémoire sur la pile

             LDA     4,s         ; Chargement de la valeur fantôme divisée pour ajustement
             ASRA                ; Décalage à droite (division par 2)
             STA     4,s         ; Mise à jour de la valeur divisée en mémoire



             LDA     tableau,x   ; Lecture de la mantisse depuis l'emplacement x
    d_if_3:  CPA     12544,i     ; Comparaison avec la valeur de seuil pour arrondi
    d_thn_3: BREQ    d_dcad      ; Si la condition est remplie, ajoute au total actuel des décimales
    d_eob_2: BR      d_bcl_2     ; Boucle continue jusqu'à l'atteinte de la limite 


d_rndst: LDA     0,s         ; Chargement du total des décimales
         ADDA    5,i         ; Ajustement du total pour l'arrondi final
         LDX     0,i         ; Réinitialisation de l'index pour l'arrondi
         BR      d_bcl_3     ; Passage au bloc d'arrondi

    d_bcl_3: SUBA    10,i        ; Soustraction de 10 pour l'arrondi
    d_if_4:  CPA     0,i         ; Comparaison avec zéro pour vérifier l'achèvement 
    d_els_4: BRLT    e_outst     ; Si le total est inférieur à zéro, fin du processus
             ADDX    1,i         ; Incrément de l'index pour le prochain ajustemen
    d_eob_3: BR      d_bcl_3     ; Boucle d'arrondi continue
    
    
; e_outst (OUTPUT)
;
;    Description :
;        Fonction qui gère l'affichage de la valeur convertie en décimal IEEE 754
;        à partir de la mantisse et de l'exposant, incluant la gestion des zéros et des signes.
;
;    Paramètres :
;        tableau             : Adresse mémoire contenant la séquence binaire convertie.
;        d_entier            : Emplacement mémoire de la partie entière.
;        e_decim             : Emplacement mémoire des décimales calculées.
;        b_expo              : Emplacement mémoire où la valeur finale de l'exposant sera stockée.
;
;    Retourne :
;        e_mloop             : Affiche la mantisse.
;        e_out1              : Vérifie et affiche les parties négatives.
;        e_pos0              : Vérifie la présence de zéros dans la séquence.
;        e_no0               : Passe à l'affichage standard si aucun zéro.
;        e_yes0              : Affiche un zéro s'il n'y a que des zéros.
;        e_neg               : Affiche un signe négatif pour les nombres négatifs.
;        e_out2              : Affiche la partie entière et le point décimal.
;        e_zero, e_zero2     : Affiche les zéros avant les décimales.
;        e_out3              : Affiche les décimales restantes.
;        e_outmes            : Affiche le message de conversion final.


e_outmes:  .ASCII  "\nLA CONVERSION IEEE 754 DES 32 BITS EST: \x00"   
e_decim:   .WORD   0         ; sert à l'emplacement mémoire des décimales calculées

e_outst: STX     e_decim,d   ; stock au registre X l'emplacement de mémoire des décimales calculés
         ADDSP   6,i         ; supprime de l'espace mémoire sur la pile temporaire
         LDX     18,i        ; commence au premier bit de la mantisse (9e bit partant de la gauche)
         STRO    c_mesfin,d  ; printf("La valeur de la mantisse est:")
         BR      e_bcl_1     ; passer à la fonction qui affiche les valeurs des bits de la mantisse

    e_bcl_1: LDA     tableau,x   ; charge la valeur du nombre convertit présent à un index
             CHARO   tableau,x   ; affiche le nombre convertit présent à l'index, soit 0 ou 1
             ADDX    2,i         ; passe à l'index suivant du tableau
    e_if_1:  CPX     64,i        ; comparer l'index à la taille du tableau
    e_thn_1: BREQ    e_out1      ; si fin tableau, passer à la fonction output de l'exposant
    e_eob_1: BR      e_bcl_1     ; recommence tant que tous les nombres de la matisse n'ont pas été passés
         

e_out1:      LDA     b_expo,d    ; charge l'emplacement mémoire où la valeur finale de l'exposant sera stockée.
             LDX     18,i
    e_if_2:  CPA     -127,i      ; comparer pour savoir si l'exposant est positif
    e_thn_2: BREQ    e_bcl_2      ; si = 0, exposant est positif 
             STRO    e_outmes,d  ; printf("LA CONVERSION IEEE 754 DES 32 BITS EST:")
             LDX     0,i         ; libère le registre X
             LDA     tableau,x   ; charge à X le premeir nombre convertit
    e_if_3:  CPA     12544,i     ; permet de déterminer la valeur du signe 
    e_thn_3: BREQ    e_negat     ; si égal, nombre négaitf
             BR      e_out2      ; sinon, nombre positif

    e_bcl_2: LDA     tableau,x   ; charge à X le premier nombre convertit
    e_if_4:  CPA     12544,i     ; Vérifie si la valeur est égale à 12544 pour déterminer la présence d'un zéro significatif
    e_thn_4: BREQ    e_no0       ; Si = 0, passe à la fonction pour l'affichage sans zéro initial
             ADDX    2,i         ; passe au bit suivant (index suivant)
    e_if_5:  CPX     64,i        ; permet de savoir si on a passé tous les bits de l'exposant
    e_thn_5: BREQ    e_yes0      ; si fin des bits d'exposants passe à la fonction qui affiche le nombre convertit en IEEE 754
    e_eob_2: BR      e_bcl_2      ; recommence tant que tous les bits de la matisse n'ont pas été passés
         

e_no0:   LDA     1,i         ; Initialise une valeur positive (1) pour l'exposant
         STA     b_expo,d    ; Stocke 1 dans b_expo pour indiquer un exposant positif
         BR      e_out1      ; Retourne à la fonction qui affiche les nombres convertit

e_yes0:  STRO    e_outmes,d  ; printf("LA CONVERSION IEEE 754 DES 32 BITS EST:")
         CHARO   '0',i       ; printf( "0")
         STOP
        

e_negat: CHARO   '-',i       ; printf("-")
         BR      e_out2      ; aller à la fonction qui affiche la conversion en IEEE 754

e_out2:      DECO    d_entier,d  ; affiche la partie entière
             CHARO   '.',i       ; printf(".")
             LDA     e_decim,d   ; charge la partie décimale
    e_if_6:  CPA     100,i       ; permet de savoir si le premier nombre de la partie décimale est  0
    e_thn_6: BRLT    e_zero      ; si <0, premier nombre de la partie décimale = 0
             BR      e_out3      ; sinon, premier nombre de la partie décimal est un autre chiffre que 0

e_zero:  CHARO   '0',i       ; printf("0")
         CPA     10,i        ; permet de savoir si le deuxième nombre de la partie décimale est 0
         BRLT    e_zero2     ; si <0, c'est un 0

e_zero2: CHARO   '0',i       ; printf("0")
         BR      e_out3      ; passe à la fonction qui affiche la partie décimale

e_out3:  DECO    e_decim,d   ; printf("valeur")
         STOP
         

.end


