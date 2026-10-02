#lang eopl
;Autores: Juan Eduardo Calderon Jaramillo 2611001-3743

;; Taller 1 — Polinomios dispersos.
;; Parte 1: representación basada en listas.
;;
;; Cada variante de la gramática se representa con una lista cuyo primer
;; elemento es un símbolo que la identifica (la etiqueta).
;;
;; Interfaz del TAD
;;
;;   polinomio-cero    : symbol -> polinomio
;;   insertar-termino  : polinomio x coeficiente x exponente -> polinomio
;;   coeficiente-de    : polinomio x exponente -> coeficiente
;;   eliminar-termino  : polinomio x exponente -> polinomio

(provide polinomio-cero insertar-termino coeficiente-de eliminar-termino)
(provide poli poli? poli->var poli->terms)
(provide nombre-var nombre-var? nombre-var->s)
(provide sin-terminos sin-terminos? mas-terminos mas-terminos?
         mas-terminos->term mas-terminos->resto)
(provide termino termino? termino->coef termino->expo)
(provide coef-ent coef-ent? coef-ent->n)
(provide coef-rac coef-rac? coef-rac->num coef-rac->den)
(provide expo-nat expo-nat? expo-nat->k)

;; ---------------------------------------------------------------
;; Constructores y observadores de la gramática
;; ---------------------------------------------------------------

;; poli : variable x terminos -> polinomio
;; Propósito: construye un polinomio a partir de su variable y su lista
;; de términos.
(define poli
  (lambda (var terms) (list 'poli var terms)))

;; poli? : any -> boolean
;; Propósito: indica si un valor fue construido con poli.
(define poli?
  (lambda (p) (and (pair? p) (eq? (car p) 'poli))))

;; poli->var : polinomio -> variable
;; Propósito: extrae la variable de un polinomio.
(define poli->var (lambda (p) (cadr p)))

;; poli->terms : polinomio -> terminos
;; Propósito: extrae la lista de términos de un polinomio.
(define poli->terms (lambda (p) (caddr p)))

;; nombre-var : symbol -> variable
;; Propósito: construye el nombre de una variable a partir de un símbolo.
(define nombre-var
  (lambda (s) (list 'nombre-var s)))

;; nombre-var? : any -> boolean
;; Propósito: indica si un valor fue construido con nombre-var.
(define nombre-var? (lambda (v) (and (pair? v) (eq? (car v) 'nombre-var))))

;; nombre-var->s : variable -> symbol
;; Propósito: extrae el símbolo de una variable.
(define nombre-var->s (lambda (v) (cadr v)))

;; sin-terminos : -> terminos
;; Propósito: construye la lista vacía de términos (caso base).
(define sin-terminos
  (lambda () (list 'sin-terminos)))

;; sin-terminos? : any -> boolean
;; Propósito: indica si un valor fue construido con sin-terminos.
(define sin-terminos? (lambda (t) (and (pair? t) (eq? (car t) 'sin-terminos))))

;; mas-terminos : termino x terminos -> terminos
;; Propósito: construye una lista de términos agregando uno al frente.
(define mas-terminos
  (lambda (term resto) (list 'mas-terminos term resto)))

;; mas-terminos? : any -> boolean
;; Propósito: indica si un valor fue construido con mas-terminos.
(define mas-terminos? (lambda (t) (and (pair? t) (eq? (car t) 'mas-terminos))))

;; mas-terminos->term : terminos -> termino
;; Propósito: extrae el primer término de una lista de términos.
(define mas-terminos->term (lambda (t) (cadr t)))

;; mas-terminos->resto : terminos -> terminos
;; Propósito: extrae el resto de la lista de términos.
(define mas-terminos->resto (lambda (t) (caddr t)))

;; termino : coeficiente x exponente -> termino
;; Propósito: construye un término a partir de su coeficiente y exponente.
(define termino
  (lambda (coef expo) (list 'termino coef expo)))

;; termino? : any -> boolean
;; Propósito: indica si un valor fue construido con termino.
(define termino? (lambda (t) (and (pair? t) (eq? (car t) 'termino))))

;; termino->coef : termino -> coeficiente
;; Propósito: extrae el coeficiente de un término.
(define termino->coef (lambda (t) (cadr t)))

;; termino->expo : termino -> exponente
;; Propósito: extrae el exponente de un término.
(define termino->expo (lambda (t) (caddr t)))

;; coef-ent : int -> coeficiente
;; Propósito: construye un coeficiente entero.
(define coef-ent
  (lambda (n) (list 'coef-ent n)))

;; coef-ent? : any -> boolean
;; Propósito: indica si un valor fue construido con coef-ent.
(define coef-ent? (lambda (c) (and (pair? c) (eq? (car c) 'coef-ent))))

;; coef-ent->n : coeficiente -> int
;; Propósito: extrae el entero de un coeficiente entero.
(define coef-ent->n (lambda (c) (cadr c)))

;; coef-rac : int x int -> coeficiente
;; Propósito: construye un coeficiente racional a partir de numerador y
;; denominador (ya reducidos y con denominador positivo).
(define coef-rac
  (lambda (num den) (list 'coef-rac num den)))

;; coef-rac? : any -> boolean
;; Propósito: indica si un valor fue construido con coef-rac.
(define coef-rac? (lambda (c) (and (pair? c) (eq? (car c) 'coef-rac))))

;; coef-rac->num : coeficiente -> int
;; Propósito: extrae el numerador de un coeficiente racional.
(define coef-rac->num (lambda (c) (cadr c)))

;; coef-rac->den : coeficiente -> int
;; Propósito: extrae el denominador de un coeficiente racional.
(define coef-rac->den (lambda (c) (caddr c)))

;; expo-nat : int -> exponente
;; Propósito: construye un exponente natural.
(define expo-nat
  (lambda (k) (list 'expo-nat k)))

;; expo-nat? : any -> boolean
;; Propósito: indica si un valor fue construido con expo-nat.
(define expo-nat? (lambda (e) (and (pair? e) (eq? (car e) 'expo-nat))))

;; expo-nat->k : exponente -> int
;; Propósito: extrae el entero de un exponente.
(define expo-nat->k (lambda (e) (cadr e)))

;; ---------------------------------------------------------------
;; Traducción entre representación concreta y abstracta
;; ---------------------------------------------------------------

;; coef-concreto->abstracto : number -> coeficiente
;; Propósito: traduce un número exacto de Racket al constructor que le
;; corresponde (coef-ent si es entero, coef-rac si no).
(define coef-concreto->abstracto
  (lambda (n)
    (if (integer? n)
        (coef-ent n)
        (coef-rac (numerator n) (denominator n)))))

;; coef-abstracto->concreto : coeficiente -> number
;; Propósito: traduce un coeficiente abstracto de vuelta a número exacto
;; de Racket.
(define coef-abstracto->concreto
  (lambda (c)
    (cond
      [(coef-ent? c) (coef-ent->n c)]
      [(coef-rac? c) (/ (coef-rac->num c) (coef-rac->den c))]
      [else (eopl:error 'coef-abstracto->concreto "coeficiente invalido: ~s" c)])))

;; ---------------------------------------------------------------
;; Interfaz del TAD
;; ---------------------------------------------------------------

;; polinomio-cero : symbol -> polinomio
;; Propósito: retorna el polinomio nulo en la variable dada.
(define polinomio-cero
  (lambda (variable)
    (poli (nombre-var variable) (sin-terminos))))

;; insertar-termino : polinomio x coeficiente x exponente -> polinomio
;; Propósito: inserta (o combina) un término en el polinomio, conservando
;; el orden estricto decreciente y eliminando el término si la suma de
;; coeficientes da cero. Si el coeficiente recibido ya es cero, retorna
;; el polinomio sin cambios. Recorre la lista de términos una sola vez.
(define insertar-termino
  (lambda (p coef-concreto expo-concreto)
    (if (or (not (integer? expo-concreto)) (< expo-concreto 0))
        (eopl:error 'insertar-termino "El exponente debe ser un entero no negativo")
        (if (not (exact? coef-concreto))
            (eopl:error 'insertar-termino "El coeficiente debe ser un numero exacto")
            (if (zero? coef-concreto)
                p
                (poli (poli->var p)
                      (insertar-en-terminos (poli->terms p)
                                            coef-concreto
                                            expo-concreto)))))))

;; insertar-en-terminos : terminos x number x int -> terminos
;; Propósito: auxiliar de insertar-termino; asume coeficiente distinto de
;; cero y exponente válido ya verificados por quien la llama.
(define insertar-en-terminos
  (lambda (terms coef-concreto expo-concreto)
    (cond
      [(sin-terminos? terms)
       (mas-terminos (termino (coef-concreto->abstracto coef-concreto)
                               (expo-nat expo-concreto))
                     (sin-terminos))]
      [else
       (let* ([t (mas-terminos->term terms)]
              [resto (mas-terminos->resto terms)]
              [e-actual (expo-nat->k (termino->expo t))])
         (cond
           ;; el exponente nuevo va antes que el actual: se inserta aqui
           [(> expo-concreto e-actual)
            (mas-terminos (termino (coef-concreto->abstracto coef-concreto)
                                    (expo-nat expo-concreto))
                          terms)]
           ;; mismo exponente: se suman los coeficientes
           [(= expo-concreto e-actual)
            (let ([suma (+ coef-concreto (coef-abstracto->concreto (termino->coef t)))])
              (if (zero? suma)
                  resto
                  (mas-terminos (termino (coef-concreto->abstracto suma)
                                          (expo-nat e-actual))
                                resto)))]
           ;; el exponente nuevo va mas adelante: se sigue buscando
           [else
            (mas-terminos t (insertar-en-terminos resto coef-concreto expo-concreto))]))])))

;; coeficiente-de : polinomio x exponente -> coeficiente
;; Propósito: retorna el coeficiente concreto del término con ese
;; exponente. Genera error si el exponente no está en el polinomio.
(define coeficiente-de
  (lambda (p expo-concreto)
    (buscar-coeficiente (poli->terms p) expo-concreto)))

;; buscar-coeficiente : terminos x int -> number
;; Propósito: auxiliar de coeficiente-de; recorre los términos aprovechando
;; el orden estricto decreciente para cortar la búsqueda tan pronto como
;; el exponente actual queda por debajo del buscado.
(define buscar-coeficiente
  (lambda (terms expo-concreto)
    (cond
      [(sin-terminos? terms)
       (eopl:error 'coeficiente-de "El polinomio no tiene termino con ese exponente")]
      [else
       (let* ([t (mas-terminos->term terms)]
              [e-actual (expo-nat->k (termino->expo t))])
         (cond
           ;; por el orden estricto, si ya pasamos el exponente no esta
           [(< e-actual expo-concreto)
            (eopl:error 'coeficiente-de "El polinomio no tiene termino con ese exponente")]
           [(= e-actual expo-concreto)
            (coef-abstracto->concreto (termino->coef t))]
           [else
            (buscar-coeficiente (mas-terminos->resto terms) expo-concreto)]))])))

;; eliminar-termino : polinomio x exponente -> polinomio
;; Propósito: retorna un polinomio sin el término de ese exponente.
;; Genera error si el término no existe.
(define eliminar-termino
  (lambda (p expo-concreto)
    (poli (poli->var p) (quitar-termino (poli->terms p) expo-concreto))))

;; quitar-termino : terminos x int -> terminos
;; Propósito: auxiliar de eliminar-termino; recorre los términos
;; aprovechando el orden estricto decreciente para cortar la búsqueda.
(define quitar-termino
  (lambda (terms expo-concreto)
    (cond
      [(sin-terminos? terms)
       (eopl:error 'eliminar-termino "El polinomio no tiene termino con ese exponente")]
      [else
       (let* ([t (mas-terminos->term terms)]
              [resto (mas-terminos->resto terms)]
              [e-actual (expo-nat->k (termino->expo t))])
         (cond
           [(< e-actual expo-concreto)
            (eopl:error 'eliminar-termino "El polinomio no tiene termino con ese exponente")]
           [(= e-actual expo-concreto) resto]
           [else (mas-terminos t (quitar-termino resto expo-concreto))]))])))

;; ---------------------------------------------------------------
;; Ejemplos de construcción (al menos 5)
;; ---------------------------------------------------------------

;; Ejemplo 1: el polinomio nulo en x
(define ejemplo-1 (polinomio-cero 'x))

;; Ejemplo 2: un polinomio con un solo termino, 7 (constante)
(define ejemplo-2 (poli (nombre-var 'x)
                         (mas-terminos (termino (coef-ent 7) (expo-nat 0))
                                       (sin-terminos))))

;; Ejemplo 3: 4x^5 - (3/2)x^2 + 7, construido directamente con constructores
(define ejemplo-3
  (poli (nombre-var 'x)
        (mas-terminos (termino (coef-ent 4) (expo-nat 5))
                      (mas-terminos (termino (coef-rac -3 2) (expo-nat 2))
                                    (mas-terminos (termino (coef-ent 7) (expo-nat 0))
                                                  (sin-terminos))))))

;; Ejemplo 4: el mismo polinomio del ejemplo 3, pero construido insertando
;; termino a termino con la funcion de interfaz
(define ejemplo-4
  (insertar-termino
    (insertar-termino
      (insertar-termino (polinomio-cero 'x) 7 0)
      -3/2 2)
    4 5))

;; Ejemplo 5: usando los observadores para inspeccionar ejemplo-3
(define ejemplo-5-es-poli (poli? ejemplo-3))
(define ejemplo-5-variable (nombre-var->s (poli->var ejemplo-3)))
(define ejemplo-5-primer-termino (mas-terminos->term (poli->terms ejemplo-3)))
(define ejemplo-5-primer-coef (coef-ent->n (termino->coef ejemplo-5-primer-termino)))
(define ejemplo-5-primer-expo (expo-nat->k (termino->expo ejemplo-5-primer-termino)))

;; ---------------------------------------------------------------
;; Ejemplos de uso de cada función de la interfaz (al menos 5 cada una)
;;
;; Los casos de error se documentan aquí a modo de referencia, pero
;; comentados: evaluarlos detendría la ejecución del archivo. Las
;; pruebas reales de esos errores, con check-exn, van en
;; pruebas-polinomios.rkt (Parte 4 del taller).
;; ---------------------------------------------------------------

;; -- polinomio-cero --
(polinomio-cero 'x)                 ;; el polinomio nulo en x
(polinomio-cero 'y)                 ;; el polinomio nulo en y
(poli->var (polinomio-cero 'z))     ;; (nombre-var 'z)
(sin-terminos? (poli->terms (polinomio-cero 'x)))  ;; #t
(poli? (polinomio-cero 'w))         ;; #t

;; -- insertar-termino --
(insertar-termino (polinomio-cero 'x) 7 0)       ;; 7
(insertar-termino ejemplo-3 1 2)                 ;; 4x^5 - (1/2)x^2 + 7
(insertar-termino ejemplo-3 3/2 2)               ;; 4x^5 + 7 (se cancela)
(insertar-termino ejemplo-3 2 10)                ;; 2x^10 + 4x^5 - (3/2)x^2 + 7
(insertar-termino (polinomio-cero 'x) 0 3)       ;; sigue siendo el polinomio nulo
;; Caso de error (ver pruebas-polinomios.rkt con check-exn):
;; (insertar-termino ejemplo-3 5 -1)
;; -> eopl:error "El exponente debe ser un entero no negativo"

;; -- coeficiente-de --
(coeficiente-de ejemplo-3 5)   ;; 4
(coeficiente-de ejemplo-3 2)   ;; -3/2
(coeficiente-de ejemplo-3 0)   ;; 7
(coeficiente-de ejemplo-4 2)   ;; -3/2 (ejemplo-4 es igual a ejemplo-3)
(coeficiente-de              ;; sobre un polinomio distinto
  (insertar-termino (polinomio-cero 'x) 7 0)
  0)                          ;; 7
;; Caso de error (ver pruebas-polinomios.rkt con check-exn):
;; (coeficiente-de ejemplo-3 3)
;; -> eopl:error "El polinomio no tiene termino con ese exponente"

;; -- eliminar-termino --
(eliminar-termino ejemplo-3 2)   ;; 4x^5 + 7
(eliminar-termino ejemplo-3 5)   ;; -(3/2)x^2 + 7
(eliminar-termino ejemplo-3 0)   ;; 4x^5 - (3/2)x^2
(poli? (eliminar-termino ejemplo-3 0))  ;; #t
(eliminar-termino              ;; sobre un polinomio distinto: queda 7
  (insertar-termino (polinomio-cero 'x) 7 0)
  0)
;; Caso de error (ver pruebas-polinomios.rkt con check-exn):
;; (eliminar-termino ejemplo-3 3)
;; -> eopl:error "El polinomio no tiene termino con ese exponente"