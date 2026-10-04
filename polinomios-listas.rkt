#lang eopl
;Autores: Juan Eduardo Calderon Jaramillo 2611001-3743

;; Taller 1 - Polinomios dispersos.
;; Parte 1: polinomios con listas.
;;
;; Aquí guardamos las partes del polinomio usando listas.
;;
;; Funciones principales
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

;;*******
;; Funciones para crear y revisar las partes
;;*******

;; poli : variable x terminos -> polinomio
;; Crea un polinomio con una variable y sus términos.
(define poli
  (lambda (var terms) (list 'poli var terms)))

;; poli? : any -> boolean
;; Revisa si es un polinomio.
(define poli?
  (lambda (p) (and (pair? p) (eq? (car p) 'poli))))

;; poli->var : polinomio -> variable
;; Saca la variable del polinomio.
(define poli->var (lambda (p) (cadr p)))

;; poli->terms : polinomio -> terminos
;; Saca los términos del polinomio.
(define poli->terms (lambda (p) (caddr p)))

;; nombre-var : symbol -> variable
;; Crea una variable.
(define nombre-var
  (lambda (s) (list 'nombre-var s)))

;; nombre-var? : any -> boolean
;; Revisa si es una variable.
(define nombre-var? (lambda (v) (and (pair? v) (eq? (car v) 'nombre-var))))

;; nombre-var->s : variable -> symbol
;; Saca el nombre de la variable.
(define nombre-var->s (lambda (v) (cadr v)))

;; sin-terminos : -> terminos
;; Crea una lista sin términos.
(define sin-terminos
  (lambda () (list 'sin-terminos)))

;; sin-terminos? : any -> boolean
;; Revisa si no hay términos.
(define sin-terminos? (lambda (t) (and (pair? t) (eq? (car t) 'sin-terminos))))

;; mas-terminos : termino x terminos -> terminos
;; Agrega un término al frente de la lista.
(define mas-terminos
  (lambda (term resto) (list 'mas-terminos term resto)))

;; mas-terminos? : any -> boolean
;; Revisa si hay más términos.
(define mas-terminos? (lambda (t) (and (pair? t) (eq? (car t) 'mas-terminos))))

;; mas-terminos->term : terminos -> termino
;; Saca el primer término.
(define mas-terminos->term (lambda (t) (cadr t)))

;; mas-terminos->resto : terminos -> terminos
;; Saca los términos que quedan.
(define mas-terminos->resto (lambda (t) (caddr t)))

;; termino : coeficiente x exponente -> termino
;; Crea un término.
(define termino
  (lambda (coef expo) (list 'termino coef expo)))

;; termino? : any -> boolean
;; Revisa si es un término.
(define termino? (lambda (t) (and (pair? t) (eq? (car t) 'termino))))

;; termino->coef : termino -> coeficiente
;; Saca el coeficiente.
(define termino->coef (lambda (t) (cadr t)))

;; termino->expo : termino -> exponente
;; Saca el exponente.
(define termino->expo (lambda (t) (caddr t)))

;; coef-ent : int -> coeficiente
;; Crea un coeficiente entero.
(define coef-ent
  (lambda (n) (list 'coef-ent n)))

;; coef-ent? : any -> boolean
;; Revisa si el coeficiente es entero.
(define coef-ent? (lambda (c) (and (pair? c) (eq? (car c) 'coef-ent))))

;; coef-ent->n : coeficiente -> int
;; Saca el número del coeficiente.
(define coef-ent->n (lambda (c) (cadr c)))

;; coef-rac : int x int -> coeficiente
;; Crea un coeficiente racional.
(define coef-rac
  (lambda (num den) (list 'coef-rac num den)))

;; coef-rac? : any -> boolean
;; Revisa si el coeficiente es racional.
(define coef-rac? (lambda (c) (and (pair? c) (eq? (car c) 'coef-rac))))

;; coef-rac->num : coeficiente -> int
;; Saca el numerador.
(define coef-rac->num (lambda (c) (cadr c)))

;; coef-rac->den : coeficiente -> int
;; Saca el denominador.
(define coef-rac->den (lambda (c) (caddr c)))

;; expo-nat : int -> exponente
;; Crea un exponente.
(define expo-nat
  (lambda (k) (list 'expo-nat k)))

;; expo-nat? : any -> boolean
;; Revisa si el exponente es natural.
(define expo-nat? (lambda (e) (and (pair? e) (eq? (car e) 'expo-nat))))

;; expo-nat->k : exponente -> int
;; Saca el número del exponente.
(define expo-nat->k (lambda (e) (cadr e)))

;; Conversión de números

;; coef-concreto->abstracto : number -> coeficiente
;; Convierte un número al tipo de coeficiente que usamos.
(define coef-concreto->abstracto
  (lambda (n)
    (if (integer? n)
        (coef-ent n)
        (coef-rac (numerator n) (denominator n)))))

;; coef-abstracto->concreto : coeficiente -> number
;; Convierte el coeficiente otra vez a un número.
(define coef-abstracto->concreto
  (lambda (c)
    (cond
      [(coef-ent? c) (coef-ent->n c)]
      [(coef-rac? c) (/ (coef-rac->num c) (coef-rac->den c))]
      [else (eopl:error 'coef-abstracto->concreto "coeficiente invalido: ~s" c)])))

;;*******
;; Funciones principales
;;*******

;; polinomio-cero : symbol -> polinomio
;; Crea el polinomio cero.
(define polinomio-cero
  (lambda (variable)
    (poli (nombre-var variable) (sin-terminos))))

;; insertar-termino : polinomio x coeficiente x exponente -> polinomio
;; Agrega un término y lo combina si ya existe. Si da cero, lo quita.
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
;; Esta función ayuda a insertar el término en el lugar correcto.
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
           ;; el nuevo exponente va antes
           [(> expo-concreto e-actual)
            (mas-terminos (termino (coef-concreto->abstracto coef-concreto)
                                    (expo-nat expo-concreto))
                          terms)]
           ;; mismo exponente: se suman
           [(= expo-concreto e-actual)
            (let ([suma (+ coef-concreto (coef-abstracto->concreto (termino->coef t)))])
              (if (zero? suma)
                  resto
                  (mas-terminos (termino (coef-concreto->abstracto suma)
                                          (expo-nat e-actual))
                                resto)))]
           ;; seguimos buscando dónde ponerlo
           [else
            (mas-terminos t (insertar-en-terminos resto coef-concreto expo-concreto))]))])))

;; coeficiente-de : polinomio x exponente -> coeficiente
;; Busca el coeficiente de un exponente.
(define coeficiente-de
  (lambda (p expo-concreto)
    (buscar-coeficiente (poli->terms p) expo-concreto)))

;; buscar-coeficiente : terminos x int -> number
;; Ayuda a buscar el coeficiente.
(define buscar-coeficiente
  (lambda (terms expo-concreto)
    (cond
      [(sin-terminos? terms)
       (eopl:error 'coeficiente-de "El polinomio no tiene termino con ese exponente")]
      [else
       (let* ([t (mas-terminos->term terms)]
              [e-actual (expo-nat->k (termino->expo t))])
         (cond
           ;; si ya pasamos el exponente, no está
           [(< e-actual expo-concreto)
            (eopl:error 'coeficiente-de "El polinomio no tiene termino con ese exponente")]
           [(= e-actual expo-concreto)
            (coef-abstracto->concreto (termino->coef t))]
           [else
            (buscar-coeficiente (mas-terminos->resto terms) expo-concreto)]))])))

;; eliminar-termino : polinomio x exponente -> polinomio
;; Quita un término del polinomio.
(define eliminar-termino
  (lambda (p expo-concreto)
    (poli (poli->var p) (quitar-termino (poli->terms p) expo-concreto))))

;; quitar-termino : terminos x int -> terminos
;; Ayuda a encontrar y quitar el término.
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

;;*******
;; Ejemplos
;;*******

;; Ejemplo 1: polinomio cero
(define ejemplo-1 (polinomio-cero 'x))

;; Ejemplo 2: un polinomio con 7
(define ejemplo-2 (poli (nombre-var 'x)
                         (mas-terminos (termino (coef-ent 7) (expo-nat 0))
                                       (sin-terminos))))

;; Ejemplo 3: un polinomio con varios términos
(define ejemplo-3
  (poli (nombre-var 'x)
        (mas-terminos (termino (coef-ent 4) (expo-nat 5))
                      (mas-terminos (termino (coef-rac -3 2) (expo-nat 2))
                                    (mas-terminos (termino (coef-ent 7) (expo-nat 0))
                                                  (sin-terminos))))))

;; Ejemplo 4: el mismo polinomio, pero agregando los términos uno por uno
(define ejemplo-4
  (insertar-termino
    (insertar-termino
      (insertar-termino (polinomio-cero 'x) 7 0)
      -3/2 2)
    4 5))

;; Ejemplo 5: revisando el ejemplo 3
(define ejemplo-5-es-poli (poli? ejemplo-3))
(define ejemplo-5-variable (nombre-var->s (poli->var ejemplo-3)))
(define ejemplo-5-primer-termino (mas-terminos->term (poli->terms ejemplo-3)))
(define ejemplo-5-primer-coef (coef-ent->n (termino->coef ejemplo-5-primer-termino)))
(define ejemplo-5-primer-expo (expo-nat->k (termino->expo ejemplo-5-primer-termino)))

;;*******
;; Ejemplos de las funciones principales
;;*******

;; Los errores se prueban en pruebas-polinomios.rkt

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
