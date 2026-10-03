#lang eopl
;Autores: Carlos Humberto Gutierrez Mejia 2059817-3743
;         Juan Eduardo Calderon Jaramillo 2611001-3743

; Taller 1 — Polinomios dispersos.
; Parte 3: representación con datatypes.
;
; Gramática:
; <polinomio>   ::= <variable> <terminos>          poli(var, terms)
; <variable>    ::= <symbol>                       nombre-var(s)
; <terminos>    ::= '()                            sin-terminos()
;               ::= <termino> <terminos>           mas-terminos(term, resto)
; <termino>     ::= <coeficiente> <exponente>      termino(coef, expo)
; <coeficiente> ::= <int>                          coef-ent(n)
;               ::= <int> "/" <int>                coef-rac(num, den)
; <exponente>   ::= <int>                          expo-nat(k)
;
; Interfaz del TAD. Cada función va comentada con su nombre, su contrato
; (entrada -> salida) y su propósito, y ninguna recorre la lista de términos
; más de una vez ni la ordena al final.
;   polinomio-cero    : symbol -> polinomio
;   insertar-termino  : polinomio x coeficiente x exponente -> polinomio
;   coeficiente-de    : polinomio x exponente -> coeficiente
;   eliminar-termino  : polinomio x exponente -> polinomio
;   sumar             : polinomio x polinomio -> polinomio

; Nota sobre los nombres de los tipos: define-datatype no admite que el
; tipo se llame igual que una de sus variantes. Por eso el tipo de
; <termino> se llama termino-tad y la variante conserva el nombre termino.

(provide polinomio-cero insertar-termino coeficiente-de eliminar-termino sumar)
(provide polinomio->lista)
(provide poli nombre-var sin-terminos mas-terminos termino
         coef-ent coef-rac expo-nat)
(provide polinomio? variable? terminos? termino-tad? coeficiente? exponente?)
(provide poli? nombre-var? sin-terminos? mas-terminos? termino?
         coef-ent? coef-rac? expo-nat?)


; Definición de los datatypes (de las hojas hacia la raíz)
(define-datatype exponente exponente?
  (expo-nat (k integer?)))

(define-datatype coeficiente coeficiente?
  (coef-ent (n integer?))
  (coef-rac (num integer?) (den integer?)))

(define-datatype termino-tad termino-tad?
  (termino (coef coeficiente?) (expo exponente?)))

(define-datatype terminos terminos?
  (sin-terminos)
  (mas-terminos (term termino-tad?) (resto terminos?)))

(define-datatype variable variable?
  (nombre-var (s symbol?)))

(define-datatype polinomio polinomio?
  (poli (var variable?) (terms terminos?)))


;  Predicados de variante (define-datatype solo genera el predicado
;   del tipo, así que los de cada variante se escriben con cases)



; poli? : any -> boolean
; Propósito: indica si un valor es un polinomio construido con poli.
(define poli?
  (lambda (x)
    (and (polinomio? x)
         (cases polinomio x
           (poli (var terms) #t)))))

; nombre-var? : any -> boolean
; Propósito: indica si un valor fue construido con nombre-var.
(define nombre-var?
  (lambda (x)
    (and (variable? x)
         (cases variable x
           (nombre-var (s) #t)))))

; sin-terminos? : any -> boolean
; Propósito: indica si un valor fue construido con sin-terminos.
(define sin-terminos?
  (lambda (x)
    (and (terminos? x)
         (cases terminos x
           (sin-terminos () #t)
           (mas-terminos (term resto) #f)))))

; mas-terminos? : any -> boolean
; Propósito: indica si un valor fue construido con mas-terminos.
(define mas-terminos?
  (lambda (x)
    (and (terminos? x)
         (cases terminos x
           (sin-terminos () #f)
           (mas-terminos (term resto) #t)))))

; termino? : any -> boolean
; Propósito: indica si un valor fue construido con termino.
(define termino?
  (lambda (x)
    (and (termino-tad? x)
         (cases termino-tad x
           (termino (coef expo) #t)))))

; coef-ent? : any -> boolean
; Propósito: indica si un valor fue construido con coef-ent.
(define coef-ent?
  (lambda (x)
    (and (coeficiente? x)
         (cases coeficiente x
           (coef-ent (n) #t)
           (coef-rac (num den) #f)))))

; coef-rac? : any -> boolean
; Propósito: indica si un valor fue construido con coef-rac.
(define coef-rac?
  (lambda (x)
    (and (coeficiente? x)
         (cases coeficiente x
           (coef-ent (n) #f)
           (coef-rac (num den) #t)))))

; expo-nat? : any -> boolean
; Propósito: indica si un valor fue construido con expo-nat.
(define expo-nat?
  (lambda (x)
    (and (exponente? x)
         (cases exponente x
           (expo-nat (k) #t)))))


; Traducción entre representación concreta y abstracta

#|
   coef-concreto->abstracto : number -> coeficiente
   Propósito: traduce un número exacto de Racket al constructor que le
   corresponde (coef-ent si es entero, coef-rac si no).
|#
(define coef-concreto->abstracto
  (lambda (n)
    (if (integer? n)
        (coef-ent n)
        (coef-rac (numerator n) (denominator n)))))

; coef-abstracto->concreto : coeficiente -> number
; Propósito: traduce un coeficiente abstracto a número exacto de Racket.
(define coef-abstracto->concreto
  (lambda (c)
    (cases coeficiente c
      (coef-ent (n) n)
      (coef-rac (num den) (/ num den)))))

; expo-abstracto->concreto : exponente -> int
; Propósito: traduce un exponente abstracto a entero de Racket.
(define expo-abstracto->concreto
  (lambda (e)
    (cases exponente e
      (expo-nat (k) k))))

; variable->simbolo : variable -> symbol
; Propósito: extrae el símbolo de una variable.
(define variable->simbolo
  (lambda (v)
    (cases variable v
      (nombre-var (s) s))))

; exponente-valido? : any -> boolean
; Propósito: #t si e es un entero exacto mayor o igual que cero.
(define exponente-valido?
  (lambda (e)
    (and (integer? e) (exact? e) (>= e 0))))

; coeficiente-valido? : any -> boolean
; Propósito: #t si c es un número racional exacto.
(define coeficiente-valido?
  (lambda (c)
    (and (rational? c) (exact? c))))


; la interfaz del TAD


; polinomio-cero : symbol -> polinomio
; Propósito: retorna el polinomio nulo en la variable dada.
(define polinomio-cero
  (lambda (s)
    (if (symbol? s)
        (poli (nombre-var s) (sin-terminos))
        (eopl:error 'polinomio-cero "La variable debe ser un simbolo"))))
#|
   insertar-en-terminos : terminos x number x int -> terminos
   Propósito: auxiliar de insertar-termino. Recorre la lista una sola vez:
   inserta (c, e) en su posición, suma si el exponente ya existe y quita
   el término si la suma da cero. Asume c distinto de cero y e válido.
|#
(define insertar-en-terminos
  (lambda (ts c e)
    (cases terminos ts
      (sin-terminos ()
        (mas-terminos (termino (coef-concreto->abstracto c) (expo-nat e))
                      (sin-terminos)))
      (mas-terminos (term resto)
        (cases termino-tad term
          (termino (coef expo)
            (let ((k (expo-abstracto->concreto expo)))
              (cond
                ;; el exponente nuevo es mayor: el término va aquí
                ((> e k)
                 (mas-terminos (termino (coef-concreto->abstracto c) (expo-nat e))
                               ts))
                ;; mismo exponente: se suman los coeficientes
                ((= e k)
                 (let ((suma (+ c (coef-abstracto->concreto coef))))
                   (if (zero? suma)
                       resto
                       (mas-terminos (termino (coef-concreto->abstracto suma) expo)
                                     resto))))
                ;; el exponente nuevo es menor: se sigue buscando
                (else
                 (mas-terminos term (insertar-en-terminos resto c e)))))))))))

#|
   insertar-termino : polinomio x number x int -> polinomio
   Propósito: inserta el término c*x^e. Si el exponente ya existe suma los
   coeficientes; si la suma da cero el término desaparece. Con c = 0 el
   polinomio no cambia. Error si e es negativo o si c no es exacto.
|#
(define insertar-termino
  (lambda (p c e)
    (cond
      ((not (exponente-valido? e))
       (eopl:error 'insertar-termino "El exponente debe ser un entero no negativo"))
      ((not (coeficiente-valido? c))
       (eopl:error 'insertar-termino "El coeficiente debe ser un numero exacto"))
      ((zero? c) p)
      (else
       (cases polinomio p
         (poli (var terms)
           (poli var (insertar-en-terminos terms c e))))))))

#|
   buscar-coeficiente : terminos x int -> number
   Propósito: auxiliar de coeficiente-de. Aprovecha el orden estricto
   decreciente: si el exponente actual ya es menor que el buscado, este
   no existe y se corta la búsqueda.
|#
(define buscar-coeficiente
  (lambda (ts e)
    (cases terminos ts
      (sin-terminos ()
        (eopl:error 'coeficiente-de "El polinomio no tiene termino con ese exponente"))
      (mas-terminos (term resto)
        (cases termino-tad term
          (termino (coef expo)
            (let ((k (expo-abstracto->concreto expo)))
              (cond
                ((= k e) (coef-abstracto->concreto coef))
                ((< k e)
                 (eopl:error 'coeficiente-de
                             "El polinomio no tiene termino con ese exponente"))
                (else (buscar-coeficiente resto e))))))))))
#|
   coeficiente-de : polinomio x int -> number
   Propósito: retorna el coeficiente concreto del término con exponente e.
   Genera error si el polinomio no tiene ese término.
|#
(define coeficiente-de
  (lambda (p e)
    (cases polinomio p
      (poli (var terms)
        (buscar-coeficiente terms e)))))

#|
   quitar-en-terminos : terminos x int -> terminos
   Propósito: auxiliar de eliminar-termino. Una sola pasada, con corte
   anticipado por el orden estricto. Error si el término no existe.
|#
(define quitar-en-terminos
  (lambda (ts e)
    (cases terminos ts
      (sin-terminos ()
        (eopl:error 'eliminar-termino "El polinomio no tiene termino con ese exponente"))
      (mas-terminos (term resto)
        (cases termino-tad term
          (termino (coef expo)
            (let ((k (expo-abstracto->concreto expo)))
              (cond
                ((= k e) resto)
                ((< k e)
                 (eopl:error 'eliminar-termino
                             "El polinomio no tiene termino con ese exponente"))
                (else (mas-terminos term (quitar-en-terminos resto e)))))))))))

#|
   eliminar-termino : polinomio x int -> polinomio
   Propósito: retorna un polinomio nuevo sin el término de exponente e.
   Genera error si ese término no existe.
|#
(define eliminar-termino
  (lambda (p e)
    (cases polinomio p
      (poli (var terms)
        (poli var (quitar-en-terminos terms e))))))

#|
   sumar-terminos : terminos x terminos -> terminos
   Propósito: auxiliar de sumar. Recorre las dos listas en paralelo, una
   sola vez, aprovechando que ambas están ordenadas de mayor a menor
   exponente. Cada llamada consume al menos un término.
     - exponentes distintos: pasa primero el de mayor exponente
     - exponentes iguales: se suman; si da cero, el término se cancela
|#
(define sumar-terminos
  (lambda (ts1 ts2)
    (cases terminos ts1
      (sin-terminos () ts2)
      (mas-terminos (t1 r1)
        (cases terminos ts2
          (sin-terminos () ts1)
          (mas-terminos (t2 r2)
            (cases termino-tad t1
              (termino (c1 e1)
                (cases termino-tad t2
                  (termino (c2 e2)
                    (let ((k1 (expo-abstracto->concreto e1))
                          (k2 (expo-abstracto->concreto e2)))
                      (cond
                        ((> k1 k2)
                         (mas-terminos t1 (sumar-terminos r1 ts2)))
                        ((< k1 k2)
                         (mas-terminos t2 (sumar-terminos ts1 r2)))
                        (else
                         (let ((suma (+ (coef-abstracto->concreto c1)
                                        (coef-abstracto->concreto c2))))
                           (if (zero? suma)
                               (sumar-terminos r1 r2)
                               (mas-terminos
                                (termino (coef-concreto->abstracto suma) e1)
                                (sumar-terminos r1 r2)))))))))))))))))

#|
   sumar : polinomio x polinomio -> polinomio
   Propósito: retorna la suma de dos polinomios en la misma variable. Los
   términos con igual exponente se combinan y los que se cancelan
   desaparecen. Error si las variables son distintas.
|#
(define sumar
  (lambda (p q)
    (cases polinomio p
      (poli (var-p terms-p)
        (cases polinomio q
          (poli (var-q terms-q)
            (if (eq? (variable->simbolo var-p) (variable->simbolo var-q))
                (poli var-p (sumar-terminos terms-p terms-q))
                (eopl:error 'sumar "Los polinomios deben estar en la misma variable"))))))))

#|
   polinomio->lista : polinomio -> lista de (coeficiente exponente)
   Propósito: observador auxiliar que muestra un polinomio como lista de
   pares concretos, por ejemplo ((4 5) (-3/2 2) (7 0)). Sirve para
   verificar resultados en las pruebas, porque los datatypes se imprimen
   de forma opaca.
|#
(define polinomio->lista
  (lambda (p)
    (cases polinomio p
      (poli (var terms) (terminos->lista terms)))))

; terminos->lista : terminos -> lista de (coeficiente exponente)
; Propósito: auxiliar de polinomio->lista.
(define terminos->lista
  (lambda (ts)
    (cases terminos ts
      (sin-terminos () '())
      (mas-terminos (term resto)
        (cases termino-tad term
          (termino (coef expo)
            (cons (list (coef-abstracto->concreto coef)
                        (expo-abstracto->concreto expo))
                  (terminos->lista resto))))))))

