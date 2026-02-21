FIGURE 25: MATRICE de CLAVIER

|  F1 | C800 | F7 | C900  |
| --- | --- | --- | --- |
|  F2 | C82A | F8 | C92A  |
|  F3 | C85A | F9 | C954  |
|  F4 | C87E | F10 | C97E  |
|  F5 | C8A8 | F11 | C9A8  |
|  F6 | C8D2 | F12 | C9D2  |

FIGURE 26: ADRESSES des TOUCHES de FONCTION

|  SET | CTR |  |   |   |   |   |   |   | A1 | 0200H  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  Name |  | GRP | Num | OFF |  |  | ON |  | BZ | 0100H  |
|  L | ° | ° | J | J | ° | U | ° |  | S8 | 0080H  |
|  I | ? × /× | ° | CR | 0 | P | @ | a |  | S7 | 0040H  |
|  F1 | F2 | F3 | F4 | F5 | F6 |  |  |  | S6 | 0020H  |
|  I | 2 | ° | $ | % | & | ? | 8 |  | S5 | 0010H  |
|  Q | W | E | R | T | Y | U | I |  | S4 | 0008H  |
|  A | S | D | F | G | H | J | K |  | S3 | 0004H  |
|  Z | X | C | V | B | N | M |  |  | S2 | 0002H  |
|  INS | DEL | → | ← | ↑ | ↓ | SPC |  |  | S1 | 0001H  |

7.6.2 Le secteur Mémoire du T6834.

Afin de mémoriser l'état d'un écran, l'alarme, la date et les caractères graphiques, le sous-processeur dispose de deux Kilo-octets de mémoire vive divisés en plusieurs sections décrites ci-dessous.

- 256 octets sont réservés au "buffer du clavier". Un buffer est un espace mémoire spécialement réservé au stockage de données. Dans ce cas précis, ce buffer emmagasine les caractères frappés au clavier et les ressort à allure constante dès que l'écran le permet. Le buffer est donc une sorte de barrage. On a donc 127 touches stockées en permanence dans cette zone de 256 octets s'étendant des adresses CC00h à CCFFh.

- 512 octets sont réservés au programme de lancement. Il est constitué d'une routine que vous définissez vous-même et lancé automatiquement après un OFF/ON (si vous l'avez programmé au moyen de la commande START$). Cette zone s'étend des adresses CE00h à CFFFh.

- 512 octets sont réservés aux caractères définis par l'utilisateur. Cette zone, s'étendant des adresses CA00h à CBFFh, est divisée en deux secteurs. En effet, on obtient les adresses des caractères correspondant aux codes ASCII 80h à 9Fh par la relation CA00h + (ASCII - 80h) * 8. Par contre, les adresses des caractères correspondant aux codes ASCII E0h à FFh sont données par la relation CB00h + (ASCII - E0h) * 8.

- 512 octets sont réservés aux touches de fonction définies par l'utilisateur. Cette zone s'étend des adresses C800h à C9FFh. Les adresses des douze touches de fonction sont décrites à la figure 26.

- 511 octets sont occupés par la mémoire écran. Cette zone, s'étendant des adresses E000h à E1FEh stocke tout ce qui se trouve sur l'écran LCD du CANON X-07.

D'autre part, nous vous donnons ci-dessous quelques informations générales sur cette MEV secondaire:

- C006h : le BIT 0 contient l'indication ONSTATE. Le bit 6 contient l'état SLEEP. De plus, le BIT 7 contient le mode ALARM simulé.

- C00Ch : cette adresse contient le mode de touches utilisé lors de la frappe au clavier. En effet, cette adresse peut contenir : 0 ---&gt; NORMAL
1 ---&gt; KANA
2 ---&gt; GRAPHIQUE
3 ---&gt; NUMERIQUE