;  CONVERSION_IEEE754_EN_DECIMAL
;
;    AUTEURS      : Tristan Larue, Rose-Anne Dubois, Alexandre Bouchard, �mile Simoneau
;    DATE         : 15/11/2024
;    EQUIPE       : Gr03-Equipe 02
;    DESCRIPTION  :
;
;        Ce programme prend une s�quence de 32 bits en entr�e (format IEEE 754),
;        valide la saisie, puis convertit cette s�quence en un nombre d�cimal.
;        Le programme inclut la gestion des erreurs de format et affiche le r�sultat.

         BR      a_verfor


; a_verfor (V�RIFICATION)
;
;        Fonction qui invite l?utilisateur � entrer une s�quence de 32 bits et
;        initialise les registres pour v�rifier que chaque caract�re est bien un 0 ou un 1.
;
;    PARAM�TRES
;        tableau              : Adresse m�moire o� chaque caract�re entr� est stock�.
;
;    Retourne :
;        a_mess_1             : un code d'erreur si la s�quence contient des caract�res non valides
;        a_mess_2             : un code d'erreur si la s�quence contient une longueur incorrecte.
;        b_expfor             : la poursuite du programme vers l'exposant.

tableau:         .BLOCK  64
a_mesdeb:        .ASCII  "VEUILLEZ ENTRER 32 BITS : \x00"
a_mess_1:        .ASCII  "Erreur : Caract�re invalide.\x00"
a_mess_2:        .ASCII  "Erreur : Tableau de taille invalide\x00"

a_verfor: LDA     0,i             ;initialise les 2 registres a 0
          LDX     0,i
          STRO    a_mesdeb,d      ;affiche le message d'initialisation du programme
          BR      a_bcl_1 

    a_bcl_1: CPX     64,i         ;=== BOUCLE PRINCIPALE DE VERIFICATION ===
             BREQ    b_expst      ; finit la boucle quand le tableau atteint sa taille maximale 

             CHARI   tableau,x    ; R�cup�rer le prochain caract�re
             LDA     tableau,x    ; Charger dans la m�moire
    a_if_1:  CPA     2560,i       ; V�rifier si "\n"
    a_thn_1: BREQ    a_err_2      ; affiche un message d'erreur si le caract�re est \n

             ADDX    2,i          ; Ajouter 1 � la longueur
    a_eif_2: CPA     12288,i      ; Comparer avec l'�quivalent en code ASCII de 0
    a_thn_2: BREQ    a_bcl_1      ; si l'entr�e est �gale � 0 et qu'il reste de la place dans le tableau, on recommence une it�ration

    a_eif_3: CPA     12544,i      ; Comparer avec l'�quivalent en code ASCII de 1
    a_thn_3: BREQ    a_bcl_1      ; si l'entr�e est �gale � un et qu'il reste de la place dans le tableau, on recommence une it�ration
    a_els_3: BRNE    a_err_1      ; Erreur si autre que 0 ou 1 ou fin 
                                

a_err_1: STRO    a_mess_1,d       ; Utilis� pour afficher un message d'erreur lors d'entr�e des caract�res invalides
         STOP
a_err_2: STRO    a_mess_2,d       ; Utilis� pour afficher un message d'erreur lors d'entr�e des caract�res invalides
         STOP


; b_expst (EXPOSANT)
;
;    Description :
;        Fonction qui extrait et calcule la valeur de l'exposant selon le format IEEE 754.
;
;    Param�tres :
;        tableau             : Adresse m�moire contenant la s�quence binaire de l'exposant.
;        b_expo              : Emplacement m�moire o� la valeur finale de l'exposant sera stock�e.
;
;    Retourne :
;        b_mesfin            : Un message avec la valeur calcul�e de l'exposant pour affichage.
;        c_mantst            : La poursuite du programme vers la mantisse.

b_expo:          .WORD   0
b_mesfin:        .ASCII  "\nLa valeur de l'exposant est: \x00"

b_expst: SUBSP   4,i         ; SP: 0 est le total, 2 repr�sente l'index principal
         LDA     0,i         ; Initialise la mantisse � 0 pour commencer � la manipuler

         STA     0,s         ; s'assure que le pointeur de pile soit vide
         STA     2,s         ; stocke 0 � un emplacement suppl�mentaire dans la pile pour utilisation ult�rieure

         LDX     18,i        ; charge l'index du premier bit de l'exposant
         STX     2,s         ; stocke cet index dans la variable locale
         
         BR      b_expend    ; branchement pour commencer la boucle

b_expad: LDA     1,i         ;=== AJUSTEMENT D'EXPOSANT ===
         LDX     16,i        ; charge la valeur de la valeur situ�e a l'index de x � modifier
         SUBX    2,s         ; fait le travail sur la prochaine valeur
         ASRX                ; d�cale les valeurs contenues dans le registre x et mets le dernier bit en retenue
         BR      b_if_1      ; branchement pour v�rifier la valeur du dernier bit 

         
    b_if_1: CPX     0,i           ; initialise une boucle pour v�rifier la valeur du dernier bit de l'exposant
    b_thn_1:BREQ    b_expend      ; sors de la boucle si le dernier bit est �gal � 0
            ASLA                  ; d�cale tous les bits vers la gauche pour regarder la valeur du dernier bit       
            SUBX    1,i           ; enl�ve 1 pour v�rifier la valeur du dernier bit
    b_eoi_1:BR      b_if_1        ; retourner au debut de la boucle


b_expend:    ADDA    0,s          ;=== BOUCLE EXPONENTIELLE ===   
             STA     0,s          ; ajoute 0 au pointeur de pile

             LDX     2,s          ; charge 2 dans x pour pr�parer la v�rification
    b_if_2:  CPX     2,i          ; compare le registre x avec 2
    b_thn_2: BREQ    c_mantst     ; envoie au commencement du calcul de la mantisse si tous les bits servants � l'exposant ont �t� pris en compte    
         
    b_eoi_2: SUBX    2,i          ; passe au prochain index du tableau
             STX     2,s          ; ajoute 2 au pointeur de pile

             LDA     tableau,x    ; charge la valeur actuelle situ�e dans x du tableau dans le registre a
    b_if_3:  CPA     12544,i      ; compare cette valeur avec 1   
    b_thn_3: BREQ    b_expad      ; si la valeur est �gale � un, branchement � l'ajustement d'exposant
             LDA     0,i          ; charger 0 dans a pour les prochains calculs
    b_eoi_3: BR      b_expend     ; branche au d�but de la boucle pour finir le calcul sur l'exposant


; c_mantst (MANTISSE)
;
;    Description :
;        Fonction qui calcule la valeur de la mantisse en fonction de l'exposant
;        et la convertit en format d�cimal pour l'affichage.
;
;    Param�tres :
;        b_expo               : Valeur calcul�e de l'exposant utilis�e pour d�terminer la position de d�part.
;        tableau              : Adresse m�moire contenant la s�quence binaire de la mantisse.
;
;    Retourne :
;        c_mesfin             : Message avec la valeur calcul�e de la mantisse pour affichage.
;        d_decst              : La poursuite du programme apr�s le calcul de la mantisse.

c_mesfin:  .ASCII  "\nLa valeur de la mantisse est: \x00"

c_mantst:LDA     0,s              ; mets fin au calcul de la puissance et lib�re le registre A de la pile
         SUBA    127,i            ; soustraire 127 au registre A pour s'ajuster au biais IEEE 754
         STA     b_expo,d         ; place la valeur de A dans b_expo
         STRO    b_mesfin,d       ; affiche un message avec la valeur calcul�e de l'exposant
         DECO    b_expo,d         ; affiche la valeur calcul�e de l'exposant
         SUBSP   2,i              ; soustrait 2 � la pile, si la valeur est 4 c'est l'index du dessus, �gale � 2 repr�sente l'index principal et �gal � 0 repr�sente le total
         LDA     0,i              ; mets 0 dans A pour la suite des calculs sur la mantisse
         STA     0,s              ; s'assure que le pointeur de pile est vide pour corriger des probl�mes involontaires

         LDA     b_expo,d         ; calcule la position de d�part du pointeur pour les nombres entiers
         ASLA                     ; d�cale les bits vers la gauche et mets le dernier bit dans la retenue
         ADDA    16,i             ; ajoute 16 au registre A pour se d�placer au d�but de la mantisse
         STA     4,s              ; rentre 4 dans le pointeur de pile pour initialiser l'index du dessus
         ADDA    2,i              ; ajoute 2 pour ajuster l'index actuel du tableau de mantisse
         STA     2,s              ; l'index actuel doit etre de 2 position plus haute car le d�calage d'index est avant le tableau
         LDA     0,i              ; mets 0 dans A pour la suite des calculs
         BR      c_mntbd          ; branchement au calcul principal de la mantisse

c_mntad: LDA     1,i              ;=== BOUCLE POUR MANTISSE ===, charge 1 dans A pour l'it�ration dans la boucle de la mantisse
         LDX     4,s              ; charge l'index de d�part de la mantisse depuis la pile dans X
         SUBX    2,s              ; r�duit X de l'offset stock� � 2 dans le pointeur de piles pour se positionner correctement
         ASRX                     ; d�cale les bits vers la droite pour capturer le prochain bit de la mantisse
         BR      c_bcl_1          ; branchement � la premi�re v�rification
         
    c_bcl_1: CPX     0,i          ; compare X avec 0 pour v�rifier le dernier bit de la mantisse
    c_thn_1: BREQ    c_mntbd      ; branche si x est � 0 pour le calcul final de la mantisse
             ASLA                 ; d�cale les bits vers la gauche pour pr�parer le prochain bit
             SUBX    1,i          ; f�duit X de 1 pour v�rifier le bit suivant
    c_eob_1: BR      c_bcl_1      ; branchement au d�but de la boucle pour une autre it�ration

c_mntbd:     ADDA    0,s          ; ajoute la valeur totale de la mantisse dans A
             STA     0,s          ; stocke le total dans la pile
         
    c_bcl_2: LDX     2,s          ; charge l'index actuel pour v�rifier la position dans la mantisse
    c_if_2:  CPX     18,i         ; compare avec 18 pour v�rifier si on a fini le calcul de la mantisse
    c_thn_2: BREQ    c_mntef      ; si tous les bits ont �t� trait�s, branchement vers la fin du code de la mantisse
    c_els_2: BRLT    d_decst      ; envoie le contenu restant de la mantisse � la partie d�cimale du code si X est plus petit que 18 
         
             SUBX    2,i          ; d�cale l'index de X vers le prochain bit
             STX     2,s          ; met � jour l'index de position dans la pile

             LDA     tableau,x    ; charge la valeur de mantisse depuis `tableau` � l'index X dans A
    c_if_3:  CPA     12544,i      ; compare A avec 12544 pour v�rifier si le bit est � 1
    c_thn_3: BREQ    c_mntad      ; si A est �gal � 12544 (� un), branche � c_mntad pour traiter
             LDA     0,i          ; charge 0 dans A pour r�initialiser si le bit est � 0
    c_eob_2: BR      c_mntbd      ; retourne � c_mntbd pour continuer le calcul de la mantisse


c_mntef: LDX     2,s              ; charge la position de l'index final de la mantisse depuis la pile dans X
         SUBX    2,i              ; r�duit X pour v�rifier la fin des bits de mantisse
         STX     2,s              ; met � jour l'index dans la pile
         BR      c_mntad          ; retourne au calcul de la mantisse pour finir le processus         
     
    
; d_decst (D�CIMALE)
;
;    Description :
;        Ce sous-programme calcule la repr�sentation d�cimale d'un nombre IEEE 754 
;        � partir de la mantisse et pr�pare les donn�es pour l'affichage final.
;
;    Param�tres :
;        d_entier            : Emplacement m�moire o� la valeur enti�re interm�diaire sera stock�e.
;        tableau             : Adresse m�moire contenant la s�quence binaire pour la conversion.
;
;    Retourne :
;        e_outst             : Transition vers l'arrondi final des d�cimales.

d_entier:  .WORD   0         ; Emplacement pour la valeur enti�re interm�diaire calcul�e


d_decst: LDA     0,s         ; lib�re le registre A de la pile
         STA     d_entier,d  ; Stockage de la valeur enti�re interm�diaire dans la m�moire

         LDA     4,s         ; Initialisation de la valeur minimale pour la conversion
         STA     2,s         ; Stockage de la valeur minimale � 2,s

         LDA     10000,i     ; Valeur temporaire pour le calcul des d�cimales, divis�e par 2 avant usage
         STA     4,s         ; Stockage en m�moire sur la pile

         LDA     0,i         ; Initialisation du total actuel des d�cimales � 0
         STA     0,s         ; Stockage en m�moire
         LDX     b_expo,d    ; Charge la valeur de l'exposant de la m�moire dans le registre X 
         BRLT    d_bcl_1    ; Si l'exposant est n�gatif, passe au traitement sp�cifique d_decnex 
         BR      d_bcl_2     ; Transition vers le bloc de calcul des d�cimales 

d_dndone:LDA     4,s         ; Charge la valeur actuelle pour le calcul final des d�cimales
         STA     0,s         ; Stocke cette valeur dans la pile pour la suite des calculs
         LDA     14,i        ; Charge 14 qui est une valeur fixe dans le registre A, utilis�e pour ajuster l'index minimal
         ADDA    2,i         ; Ajoute 2 � A pour ajuster l'index vers la position suivante
         STA     2,s         ; Stocke la nouvelle valeur de l'index dans la pile
         BR      d_bcl_2     ; Retourne � la boucle principale de calcul des d�cimales 

    d_bcl_1: LDA     4,s         ; Charge la valeur actuelle pour les calculs de d�cimales
             ASRA                ; Divise la valeur par 2 en d�calant � droite
             STA     4,s         ; Met � jour la valeur divis�e dans la pile
    d_if_1:  CPX     -1,i        ; Compare X avec -1 pour v�rifier si la fin des ajustements est atteinte
    d_thn_1: BREQ    d_dndone    ; Si la comparaison est vraie, passe � la fin de la gestion des d�cimales d_dndone
             ADDX    1,i         ; Incr�mente X pour passer � l'index suivant
    d_eob_1: BR      d_bcl_1     ; Retourne au d�but de d_bcl_1 pour continuer la division 
         
d_dcad:      LDA     0,s         ; Chargement de la valeur actuelle des d�cimales
             ADDA    4,s         ; Addition de la valeur de 4,s � la valeur actuelle des d�cimales
             STA     0,s         ; Mise � jour de la valeur actuelle des d�cimales
             BR      d_bcl_2     ; Retour au bloc de calcul des d�cimales 

    d_bcl_2: LDX     2,s         ; Chargement de l'index de la mantisse pour la conversion 
    d_if_2:  CPX     62,i        ; Comparaison de l'index avec la limite de 62
    d_thn_2: BREQ    d_rndst     ; Transition vers l'arrondi final si la limite est atteinte

             ADDX    2,i         ; Incr�mentation de l'index pour la prochaine d�cimale
             STX     2,s         ; Mise � jour de l'index en m�moire sur la pile

             LDA     4,s         ; Chargement de la valeur fant�me divis�e pour ajustement
             ASRA                ; D�calage � droite (division par 2)
             STA     4,s         ; Mise � jour de la valeur divis�e en m�moire



             LDA     tableau,x   ; Lecture de la mantisse depuis l'emplacement x
    d_if_3:  CPA     12544,i     ; Comparaison avec la valeur de seuil pour arrondi
    d_thn_3: BREQ    d_dcad      ; Si la condition est remplie, ajoute au total actuel des d�cimales
    d_eob_2: BR      d_bcl_2     ; Boucle continue jusqu'� l'atteinte de la limite 


d_rndst: LDA     0,s         ; Chargement du total des d�cimales
         ADDA    5,i         ; Ajustement du total pour l'arrondi final
         LDX     0,i         ; R�initialisation de l'index pour l'arrondi
         BR      d_bcl_3     ; Passage au bloc d'arrondi

    d_bcl_3: SUBA    10,i        ; Soustraction de 10 pour l'arrondi
    d_if_4:  CPA     0,i         ; Comparaison avec z�ro pour v�rifier l'ach�vement 
    d_els_4: BRLT    e_outst     ; Si le total est inf�rieur � z�ro, fin du processus
             ADDX    1,i         ; Incr�ment de l'index pour le prochain ajustemen
    d_eob_3: BR      d_bcl_3     ; Boucle d'arrondi continue
    
    
; e_outst (OUTPUT)
;
;    Description :
;        Fonction qui g�re l'affichage de la valeur convertie en d�cimal IEEE 754
;        � partir de la mantisse et de l'exposant, incluant la gestion des z�ros et des signes.
;
;    Param�tres :
;        tableau             : Adresse m�moire contenant la s�quence binaire convertie.
;        d_entier            : Emplacement m�moire de la partie enti�re.
;        e_decim             : Emplacement m�moire des d�cimales calcul�es.
;        b_expo              : Emplacement m�moire o� la valeur finale de l'exposant sera stock�e.
;
;    Retourne :
;        e_mloop             : Affiche la mantisse.
;        e_out1              : V�rifie et affiche les parties n�gatives.
;        e_pos0              : V�rifie la pr�sence de z�ros dans la s�quence.
;        e_no0               : Passe � l'affichage standard si aucun z�ro.
;        e_yes0              : Affiche un z�ro s'il n'y a que des z�ros.
;        e_neg               : Affiche un signe n�gatif pour les nombres n�gatifs.
;        e_out2              : Affiche la partie enti�re et le point d�cimal.
;        e_zero, e_zero2     : Affiche les z�ros avant les d�cimales.
;        e_out3              : Affiche les d�cimales restantes.
;        e_outmes            : Affiche le message de conversion final.


e_outmes:  .ASCII  "\nLA CONVERSION IEEE 754 DES 32 BITS EST: \x00"   
e_decim:   .WORD   0         ; sert � l'emplacement m�moire des d�cimales calcul�es

e_outst: STX     e_decim,d   ; stock au registre X l'emplacement de m�moire des d�cimales calcul�s
         ADDSP   6,i         ; supprime de l'espace m�moire sur la pile temporaire
         LDX     18,i        ; commence au premier bit de la mantisse (9e bit partant de la gauche)
         STRO    c_mesfin,d  ; printf("La valeur de la mantisse est:")
         BR      e_bcl_1     ; passer � la fonction qui affiche les valeurs des bits de la mantisse

    e_bcl_1: LDA     tableau,x   ; charge la valeur du nombre convertit pr�sent � un index
             CHARO   tableau,x   ; affiche le nombre convertit pr�sent � l'index, soit 0 ou 1
             ADDX    2,i         ; passe � l'index suivant du tableau
    e_if_1:  CPX     64,i        ; comparer l'index � la taille du tableau
    e_thn_1: BREQ    e_out1      ; si fin tableau, passer � la fonction output de l'exposant
    e_eob_1: BR      e_bcl_1     ; recommence tant que tous les nombres de la matisse n'ont pas �t� pass�s
         

e_out1:      LDA     b_expo,d    ; charge l'emplacement m�moire o� la valeur finale de l'exposant sera stock�e.
             LDX     18,i
    e_if_2:  CPA     -127,i      ; comparer pour savoir si l'exposant est positif
    e_thn_2: BREQ    e_bcl_2      ; si = 0, exposant est positif 
             STRO    e_outmes,d  ; printf("LA CONVERSION IEEE 754 DES 32 BITS EST:")
             LDX     0,i         ; lib�re le registre X
             LDA     tableau,x   ; charge � X le premeir nombre convertit
    e_if_3:  CPA     12544,i     ; permet de d�terminer la valeur du signe 
    e_thn_3: BREQ    e_negat     ; si �gal, nombre n�gaitf
             BR      e_out2      ; sinon, nombre positif

    e_bcl_2: LDA     tableau,x   ; charge � X le premier nombre convertit
    e_if_4:  CPA     12544,i     ; V�rifie si la valeur est �gale � 12544 pour d�terminer la pr�sence d'un z�ro significatif
    e_thn_4: BREQ    e_no0       ; Si = 0, passe � la fonction pour l'affichage sans z�ro initial
             ADDX    2,i         ; passe au bit suivant (index suivant)
    e_if_5:  CPX     64,i        ; permet de savoir si on a pass� tous les bits de l'exposant
    e_thn_5: BREQ    e_yes0      ; si fin des bits d'exposants passe � la fonction qui affiche le nombre convertit en IEEE 754
    e_eob_2: BR      e_bcl_2      ; recommence tant que tous les bits de la matisse n'ont pas �t� pass�s
         

e_no0:   LDA     1,i         ; Initialise une valeur positive (1) pour l'exposant
         STA     b_expo,d    ; Stocke 1 dans b_expo pour indiquer un exposant positif
         BR      e_out1      ; Retourne � la fonction qui affiche les nombres convertit

e_yes0:  STRO    e_outmes,d  ; printf("LA CONVERSION IEEE 754 DES 32 BITS EST:")
         CHARO   '0',i       ; printf( "0")
         STOP
        

e_negat: CHARO   '-',i       ; printf("-")
         BR      e_out2      ; aller � la fonction qui affiche la conversion en IEEE 754

e_out2:      DECO    d_entier,d  ; affiche la partie enti�re
             CHARO   '.',i       ; printf(".")
             LDA     e_decim,d   ; charge la partie d�cimale
    e_if_6:  CPA     100,i       ; permet de savoir si le premier nombre de la partie d�cimale est  0
    e_thn_6: BRLT    e_zero      ; si <0, premier nombre de la partie d�cimale = 0
             BR      e_out3      ; sinon, premier nombre de la partie d�cimal est un autre chiffre que 0

e_zero:  CHARO   '0',i       ; printf("0")
         CPA     10,i        ; permet de savoir si le deuxi�me nombre de la partie d�cimale est 0
         BRLT    e_zero2     ; si <0, c'est un 0

e_zero2: CHARO   '0',i       ; printf("0")
         BR      e_out3      ; passe � la fonction qui affiche la partie d�cimale

e_out3:  DECO    e_decim,d   ; printf("valeur")
         STOP
         

.end


