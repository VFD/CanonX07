96
# LES PRINCIPALES ROUTINES DE LA ROM DU X-07

Nous savons tous que ce neuvième chapitre est attendu avec une grande émotion. Effectivement, près de 89 adresses importantes vont vous être dévoilées !!

Ces adresses sont divisées en six grandes familles :

- Les routines d'entrées/sorties
- Les routines de conversion
- Les routines arithmétiques
- Les routines mathématiques
- Les routines systèmes
- Les routines secondaires

Tous ces sous-programmes peuvent être appelés directement par le CANON X-07 dans ses programmes écrits en langage machine. Le format des routines exposées sera de la forme suivante :

**Adresse Hexadécimale**
- Entrée : registres à charger avec un paramètre.
- Action : effet de la routine.
- Sortie : information de retour (état d'un registre ...).
- Modifiés : information de modification (registre dont le contenu diffère avant et après l'appel).

Après cette brève introduction, entrons vite dans le vif du sujet sinon vous allez défaillir !!

## 9.1 Les ROUTINES D'ENTREE / SORTIE

### 9.1.1 Le BUZZER

**C2DF**
- E : IY contient la tonalité, H la durée et L est égal à 0.
- A : fonction BEEP du BASIC (mêmes valeurs pour les paramètres).
- S : rien.
- M : les registres AF, BC, DE, HL, IY, EI.

**C331**
- E : IY contient la tonalité, HL la durée et C le drapeau de marche (Si C=FF, on déclenche le haut parleur / Si C=00, on arrête).
- A : actionne le haut-parleur.
- S : rien.
- M : les registres AF, BC, DE, HL, EI.

### 9.1.2 Le CLAVIER

**C8C5**
- E : rien.
- A : obtention de l'entrée clavier et affichage du curseur.
- S : caractère frappé dans le registre A. Le drapeau C est égal à 1 s'il y a interruption.
- M : le registre AF.

**C90A**
- E : rien.
- A : saisie d'un octet au clavier (Simili INKEY$).
- S : caractère frappé dans le registre A. Le drapeau Z est égal à 1 s'il n'y a pas d'introduction.
- M : le registre AF.

### 9.1.3 L'ECRAN LCD

**C1BE**
- E : A contient le caractère à afficher.
- A : écriture du contenu de A à l'écran et dans la mémoire image. La position du curseur est incrémentée. Les codes de contrôle sont admis.
- S : rien.
- M : aucun registre.

**C231**
- E : H contient la coordonnée X du curseur, L contient la coordonnée Y du curseur, C contient le caractère à afficher.
- A : le contenu de C est écrit à l'écran à la position définie par le LOCATE en cours. Le curseur reste immobile.
- S : rien.
- M : les registres AF, BC, DE.

**CE9E**
- E : rien.
- A : efface l'écran (équivalent de la fonction CLS).
- S : rien.
- M : le registre AF.

97