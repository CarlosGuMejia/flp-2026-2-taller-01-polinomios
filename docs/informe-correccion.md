# Informe de corrección — Taller 1: polinomios dispersos

Las demostraciones se hacen una sola vez, sobre la estructura recursiva
que define la gramática, porque la lógica de las funciones es la misma en
las tres representaciones. Los fragmentos de código son los de
`polinomios-datatypes.rkt`.

**Curso:** Fundamentos de Interpretación y Compilación de Lenguajes
de Programación — Universidad del Valle, Sede Tuluá.

**Integrantes del grupo:**

| Nombre | Código | Correo institucional |
|--------|--------|----------------------|
| Juan Eduardo Calderon Jaramillo | 2611001-3743 | juan.eduardo.calderon@correounivalle.edu.co |
| Carlos Humberto Gutierrez Mejia | 2059817-3743 | carlos.humberto.gutierrez@correounivalle.edu.co |
| {{Nombre 3}} | {{Código 3}} | {{correo3@correounivalle.edu.co}} |

---

## 1. Marco formal

### 1.1 Corrección de programas recursivos

Sea $f : A \to B$ una función y $A$ un conjunto definido
recursivamente. Sea $P_f$ un programa recursivo en Racket que pretende
calcular $f$. Decimos que $P_f$ es correcto con respecto a su
especificación si se cumple:

$$
\forall a \in A \,:\, P_f(a) = f(a)
$$

La estrategia de demostración es **inducción estructural** sobre $A$.
Aquí $A$ es el conjunto de listas de términos que genera la gramática:

- **Caso base:** $a = \text{sin-terminos}()$, y se verifica
  $P_f(a) = f(a)$ directamente.
- **Caso inductivo:** $a = \text{mas-terminos}(t, r)$. Se asume la
  **hipótesis de inducción** $P_f(r) = f(r)$ sobre el resto de la
  lista y se demuestra $P_f(a) = f(a)$.

Las tres funciones analizadas (`coeficiente-de`, `eliminar-termino` e
`insertar-termino`) se apoyan en una función auxiliar con recursión
estructural sobre la lista de términos, sin acumuladores. Por eso la
corrección se argumenta con hipótesis de inducción y no con una
invariante de acumulador.

### 1.2 El invariante de la representación

Las cuatro condiciones del enunciado se enuncian como una única
propiedad sobre polinomios. Sea $p$ un polinomio con términos
$t_1, t_2, \ldots, t_n$, donde $t_i = (c_i, e_i)$:

$$
\mathrm{Inv}(p) \equiv
\underbrace{\forall i < n : e_i > e_{i+1}}_{\text{orden estricto}}
\ \land\
\underbrace{\forall i : c_i \neq 0}_{\text{sin ceros}}
\ \land\
\underbrace{\forall i : e_i \in \mathbb{N}}_{\text{exponentes naturales}}
\ \land\
\underbrace{\forall i : \mathrm{red}(c_i)}_{\text{racionales reducidos}}
$$

donde $\mathrm{red}\left(\frac{a}{b}\right)$ abrevia
$b > 0 \,\land\, \mathrm{mcd}(|a|, b) = 1$, y un coeficiente entero se
toma como el racional de denominador $1$.

Como las funciones auxiliares trabajan sobre la lista de términos, se
escribe también $\mathrm{Inv}(ts)$ para una lista de términos $ts$, con
las mismas cuatro condiciones. Entonces
$\mathrm{Inv}(p) \equiv \mathrm{Inv}(\mathrm{terms}(p))$.

### 1.3 Notación y lemas auxiliares

**Valor de un coeficiente.** Se define
$\mathrm{val}(\texttt{coef-ent}(n)) = n$ y
$\mathrm{val}(\texttt{coef-rac}(a, b)) = \frac{a}{b}$. Es lo que
calcula `coef-abstracto->concreto`.

**Vista concreta de una lista de términos.** Se escribe
$ts = [(\gamma_1, e_1), \ldots, (\gamma_n, e_n)]$ con
$\gamma_i = \mathrm{val}(c_i)$, que es exactamente lo que devuelve
`polinomio->lista`. Además:

$$
E(ts) = \{e_1, \ldots, e_n\}, \qquad |ts| = n
$$

Si $ts$ es una secuencia y $t$ uno de sus elementos, $ts \setminus \{t\}$
es la secuencia que resulta de borrar ese único elemento, sin tocar el
orden de los demás.

**Lema 1 (cola y subsecuencias).** Si $\mathrm{Inv}(ts)$ y
$ts = (\gamma_1, e_1) :: r$, entonces $\mathrm{Inv}(r)$ y
$e_1 > e$ para todo $e \in E(r)$. De manera más general, toda
subsecuencia de $ts$ cumple $\mathrm{Inv}$.

*Demostración.* Las condiciones 2, 3 y 4 son propiedades de cada término
por separado, así que las hereda cualquier subconjunto de términos. La
condición 1 dice que los exponentes forman una secuencia estrictamente
decreciente; por transitividad de $>$, cualquier subsecuencia lo sigue
siendo, y el primer exponente es mayor que todos los demás. $\square$

**Lema 2 (conversión de coeficientes).** Sea $c$ un racional exacto de
Racket y sea $\mathrm{conv}(c)$ el coeficiente que construye
`coef-concreto->abstracto`: `coef-ent` $c$ si $c$ es entero y
`coef-rac` $(\texttt{numerator}(c), \texttt{denominator}(c))$ en otro
caso. Entonces $\mathrm{val}(\mathrm{conv}(c)) = c$ y
$\mathrm{red}(\mathrm{conv}(c))$.

*Demostración.* Si $c$ es entero, $\mathrm{val}(\texttt{coef-ent}(c)) = c$
y su denominador es $1$, así que $\mathrm{mcd}(|c|, 1) = 1$. Si no lo es,
$\mathrm{val} = \frac{\texttt{numerator}(c)}{\texttt{denominator}(c)} = c$,
y Racket guarda los racionales exactos en forma reducida y con
denominador positivo (Racket Reference, *Numbers*), de modo que
$b > 0$ y $\mathrm{mcd}(|a|, b) = 1$. $\square$

---

## 2. Funciones analizadas

### 2.1 Corrección de `coeficiente-de`

**Especificación.**

- **Tipo:** `coeficiente-de : polinomio × exponente -> coeficiente`
- **Pre-condición:** $\mathrm{Inv}(p)$ y $e \in \mathbb{Z}$ (el exponente
  consultado es un entero).
- **Post-condición:** sean $(\gamma_1, e_1), \ldots, (\gamma_n, e_n)$ los
  términos de $p$.

  $$
  \text{Post}(p, e, r) \equiv \exists i : e_i = e \,\land\, r = \gamma_i
  $$

  cuando el exponente $e$ aparece en $p$; y la función levanta
  `eopl:error` cuando no aparece. Por el orden estricto, a lo sumo un
  término tiene el exponente $e$, de modo que $\gamma_i$ está bien
  definido.

**Código.**

```racket
; coeficiente-de : polinomio x int -> number
; Propósito: retorna el coeficiente concreto del término con exponente e.
; Genera error si el polinomio no tiene ese término.
(define coeficiente-de
  (lambda (p e)
    (cases polinomio p
      (poli (var terms)
        (buscar-coeficiente terms e)))))

; buscar-coeficiente : terminos x int -> number
; Propósito: auxiliar de coeficiente-de; aprovecha el orden estricto
; decreciente para cortar la búsqueda.
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
```

**Lema de corrección de `buscar-coeficiente`.** Sea $ts$ con
$\mathrm{Inv}(ts)$ y $e \in \mathbb{Z}$. Entonces
`(buscar-coeficiente ts e)` termina y:

1. si existe $(\gamma, e) \in ts$, retorna $\gamma$;
2. si no existe, levanta `eopl:error`.

**Demostración** por inducción estructural sobre $ts$.

- **Caso base** ($ts = \text{sin-terminos}()$): la lista no tiene
  términos, así que no existe $(\gamma, e) \in ts$ y estamos en el caso
  2. El programa entra por la cláusula `sin-terminos` y levanta el
  error:

  $$
  \texttt{buscar}([\,], e) = \texttt{error}
  $$

- **Caso inductivo** ($ts = (\gamma_1, k) :: r$, con
  $\mathrm{Inv}(ts)$). Por el Lema 1, $\mathrm{Inv}(r)$ y $k > x$ para
  todo $x \in E(r)$, de modo que se puede usar la hipótesis de inducción
  sobre $r$:

  $$
  \text{(HI)}\quad \texttt{buscar}(r, e) \text{ cumple 1 y 2 sobre } r
  $$

  El programa compara $k$ con $e$ y hay tres subcasos, que son
  exhaustivos.

  - **$k = e$.** El programa retorna $\mathrm{val}(\text{coef}) = \gamma_1$.
    El término $(\gamma_1, e)$ está en $ts$, así que estamos en el caso
    1 y el valor retornado es el correcto. Por el orden estricto, ningún
    otro término tiene exponente $e$.
  - **$k < e$.** El programa levanta el error. Como $k > x$ para todo
    $x \in E(r)$, se tiene $E(ts) \subseteq \{x : x \le k\}$, y como
    $k < e$, ningún término de $ts$ tiene exponente $e$: estamos en el
    caso 2 y el error es lo correcto. Aquí el orden estricto permite
    **cortar la búsqueda sin recorrer el resto de la lista**.
  - **$k > e$.** El programa retorna $\texttt{buscar}(r, e)$. El primer
    término tiene exponente $k \neq e$, así que existe un término con
    exponente $e$ en $ts$ si y solo si existe en $r$. Por (HI), si
    existe, el resultado es su coeficiente $\gamma$ (caso 1), y si no
    existe, se levanta el error (caso 2). $\square$

- **Levantamiento del error.** En los tres subcasos y en el caso base,
  el error aparece exactamente cuando no existe un término con
  exponente $e$: en el caso base y en $k < e$ no existe, y en $k = e$ se
  retorna un valor sin error. En $k > e$ el comportamiento lo hereda la
  llamada recursiva, para la cual vale lo mismo por (HI). Por tanto el
  error se levanta cuando el exponente no está y **solo** en ese caso.

- **Terminación.** Se usa la medida $\mu(ts) = |ts| \in \mathbb{N}$, el
  número de términos de la lista. La única llamada recursiva (subcaso
  $k > e$) se hace sobre $r$ y

  $$
  \mu(r) = \mu(ts) - 1 < \mu(ts)
  $$

  La medida está acotada inferiormente por $0$, y con $\mu = 0$ (lista
  vacía) no hay llamada recursiva. Como $\mathbb{N}$ no tiene cadenas
  decrecientes infinitas, la función termina.

**Conclusión:** `coeficiente-de` desarma el polinomio con `cases`,
obtiene $\mathrm{terms}(p)$, que cumple $\mathrm{Inv}$ por la
pre-condición, y retorna `(buscar-coeficiente terms e)`. Por el lema,
cumple $\text{Post}(p, e, r)$: retorna el coeficiente buscado cuando el
exponente existe y levanta `eopl:error` cuando no existe. Además hace
una sola pasada sobre la lista.

---

### 2.2 Corrección de `eliminar-termino`

**Especificación.**

- **Tipo:** `eliminar-termino : polinomio × exponente -> polinomio`
- **Pre-condición:** $\mathrm{Inv}(p)$ y $e \in \mathbb{Z}$.
- **Post-condición:** si existe $(\gamma, e) \in \mathrm{terms}(p)$, el
  resultado $r$ contiene **exactamente** los términos de $p$ menos ese:

  $$
  \text{terminos}(r) = \text{terminos}(p) \setminus \{(\gamma, e)\}
  $$

  con los demás términos en el mismo orden relativo, la misma variable
  que $p$ y $\mathrm{Inv}(r)$. Si $e$ no aparece en $p$, la función
  levanta `eopl:error`.

**Código.**

```racket
; eliminar-termino : polinomio x int -> polinomio
; Propósito: retorna un polinomio nuevo sin el término de exponente e.
; Genera error si ese término no existe.
(define eliminar-termino
  (lambda (p e)
    (cases polinomio p
      (poli (var terms)
        (poli var (quitar-en-terminos terms e))))))

; quitar-en-terminos : terminos x int -> terminos
; Propósito: auxiliar; una sola pasada con corte anticipado por el
; orden estricto.
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
```

**Lema de corrección de `quitar-en-terminos`.** Sea $ts$ con
$\mathrm{Inv}(ts)$ y $e \in \mathbb{Z}$. Entonces
`(quitar-en-terminos ts e)` termina y:

1. si existe $t = (\gamma, e) \in ts$, retorna $ts \setminus \{t\}$;
2. si no existe, levanta `eopl:error`.

**Demostración** por inducción estructural sobre $ts$.

- **Caso base** ($ts = \text{sin-terminos}()$): no hay término con
  exponente $e$ (caso 2) y el programa levanta el error.

- **Caso inductivo** ($ts = t_1 :: r$ con $t_1 = (\gamma_1, k)$ y
  $\mathrm{Inv}(ts)$). Por el Lema 1, $\mathrm{Inv}(r)$ y $k$ es mayor
  que todo exponente de $r$. Hipótesis de inducción:
  $\texttt{quitar}(r, e)$ cumple 1 y 2 sobre $r$.

  - **$k = e$.** Retorna $r$. Por el orden estricto, $t_1$ es el único
    término con exponente $e$, y borrarlo de $ts$ deja justamente $r$:
    $ts \setminus \{t_1\} = r$. Caso 1 satisfecho.
  - **$k < e$.** Levanta el error. Igual que en 2.1, todos los
    exponentes de $ts$ son menores o iguales que $k < e$, así que no hay
    término con exponente $e$ (caso 2).
  - **$k > e$.** Retorna $t_1 ::\ \texttt{quitar}(r, e)$. Como
    $k \neq e$, existe un término con exponente $e$ en $ts$ si y solo si
    existe en $r$.
    - Si existe $t_e \in r$, por (HI)
      $\texttt{quitar}(r, e) = r \setminus \{t_e\}$, y entonces
      $t_1 :: (r \setminus \{t_e\}) = (t_1 :: r) \setminus \{t_e\}
      = ts \setminus \{t_e\}$, porque $t_1 \neq t_e$ y borrar un
      elemento de la cola no cambia la posición de la cabeza.
    - Si no existe, por (HI) la llamada recursiva levanta el error, que
      se propaga antes de construir ningún `mas-terminos`. $\square$

- **El resultado tiene exactamente los términos esperados.** El lema
  dice que el resultado es $ts \setminus \{t\}$: contiene todos los
  términos de $ts$ menos $t$, ninguno nuevo y ninguno modificado, y en el
  mismo orden. Como `eliminar-termino` envuelve el resultado con la
  misma variable (`poli var ...`), se cumple la igualdad de términos de
  la post-condición.

- **El resultado conserva el invariante.** $ts \setminus \{t\}$ es una
  subsecuencia de $ts$, y por el Lema 1 cumple $\mathrm{Inv}$. En
  concreto, quitar un término no rompe el orden estricto (las
  desigualdades entre los términos que quedan siguen siendo las mismas,
  y la transitividad cubre el hueco) ni introduce ceros, exponentes
  negativos o racionales sin reducir, porque no se crea ningún
  coeficiente nuevo.

- **Terminación.** Misma medida que en 2.1: $\mu(ts) = |ts|$. La única
  llamada recursiva (subcaso $k > e$) se hace sobre $r$, con
  $\mu(r) = \mu(ts) - 1$, y $\mu \ge 0$.

**Conclusión:** como `eliminar-termino` aplica `quitar-en-terminos` sobre
$\mathrm{terms}(p)$, que cumple $\mathrm{Inv}$, y conserva la variable,
el resultado cumple la post-condición: sin el término de exponente $e$ si
existe, con error si no existe, y con $\mathrm{Inv}(r)$.

---

### 2.3 `insertar-termino` preserva el invariante

**Enunciado.** Si $\mathrm{Inv}(p)$ vale antes de la llamada, entonces
$\mathrm{Inv}(\texttt{insertar-termino}(p, c, e))$ vale sobre el
resultado.

**Código.**

```racket
; insertar-termino : polinomio x number x int -> polinomio
; Propósito: inserta el término c*x^e. Si el exponente ya existe suma los
; coeficientes; si la suma da cero el término desaparece. Con c = 0 el
; polinomio no cambia. Error si e es negativo o si c no es exacto.
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

; insertar-en-terminos : terminos x number x int -> terminos
; Propósito: auxiliar; recorre la lista una sola vez.
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
                ((> e k)
                 (mas-terminos (termino (coef-concreto->abstracto c) (expo-nat e))
                               ts))
                ((= e k)
                 (let ((suma (+ c (coef-abstracto->concreto coef))))
                   (if (zero? suma)
                       resto
                       (mas-terminos (termino (coef-concreto->abstracto suma) expo)
                                     resto))))
                (else
                 (mas-terminos term (insertar-en-terminos resto c e)))))))))))
```

**Casos que no llegan a la función auxiliar.**

- Si $e$ no es un entero exacto $\ge 0$, o si $c$ no es un racional
  exacto, la función levanta un error y no devuelve ningún polinomio:
  la propiedad se cumple de manera vacía.
- Si $c = 0$, devuelve $p$ sin cambios, y entonces $\mathrm{Inv}$ vale
  porque ya valía para $p$. Esta cláusula es necesaria: insertar un
  término con coeficiente cero violaría la condición 2.
- En los demás casos, $c \neq 0$, $c$ es un racional exacto y
  $e \in \mathbb{N}$, y se llama a `insertar-en-terminos`. La variable
  de $p$ se conserva.

Basta entonces demostrar el siguiente lema, con
$ts' = \texttt{ins}(ts, c, e)$ para `insertar-en-terminos`.

**Lema 3.** Sea $ts$ con $\mathrm{Inv}(ts)$, $c \neq 0$ racional exacto
y $e \in \mathbb{N}$. Entonces:

- **(a)** $\mathrm{Inv}(\texttt{ins}(ts, c, e))$;
- **(b)** $E(\texttt{ins}(ts, c, e)) \subseteq E(ts) \cup \{e\}$.

La parte (b) se incluye porque la necesita el paso inductivo de (a): al
volver de la recursión hay que saber que los exponentes del resultado
siguen siendo menores que la cabeza.

**Demostración** por inducción estructural sobre $ts$. En cada cláusula
se indica a cuál de los tres casos del enunciado corresponde y se
verifican las cuatro condiciones.

- **Caso base** ($ts = [\,]$). Es el **Caso A** (el exponente es nuevo,
  porque la lista no tiene ninguno). El resultado es $[(c, e)]$:
  1. orden estricto: una lista de un solo término lo cumple de forma
     vacía;
  2. $c \neq 0$ por hipótesis;
  3. $e \in \mathbb{N}$ por hipótesis;
  4. $\mathrm{red}(\mathrm{conv}(c))$ por el Lema 2.

  Además $E = \{e\} \subseteq \emptyset \cup \{e\}$.

- **Caso inductivo** ($ts = (\gamma, k) :: r$, con $\mathrm{Inv}(ts)$).
  Por el Lema 1, $\mathrm{Inv}(r)$ y $k > x$ para todo $x \in E(r)$.
  Hipótesis de inducción: el lema vale para $r$ con los mismos $c$ y
  $e$.

  - **$e > k$ — Caso A: el exponente es nuevo y va al frente.** El
    resultado es $(c, e) :: ts$. Como $k$ es el mayor exponente de $ts$
    (Lema 1), $e$ es mayor que todos los exponentes de $ts$ y no
    coincide con ninguno.
    1. Orden estricto: $e > k$, y el resto $ts$ ya cumple la condición.
    2. Sin ceros: $c \neq 0$ y los de $ts$ no son cero.
    3. Exponentes naturales: $e \in \mathbb{N}$ y los de $ts$ lo son.
    4. Reducidos: $\mathrm{conv}(c)$ es reducido (Lema 2) y los de $ts$
       no se tocan.

    $E = E(ts) \cup \{e\}$, así que (b) se cumple.

  - **$e = k$ — el exponente ya existía.** Sea $s = c + \gamma$, suma de
    dos racionales exactos, que es un racional exacto.

    - **$s \neq 0$ — Caso B.** El resultado es $(s, k) :: r$. El
      exponente $k$ es el mismo que tenía la cabeza, así que la relación
      de orden con $r$ no cambia: $k > x$ para todo $x \in E(r)$.
      1. Orden estricto: se conserva, porque $E$ no cambia y $r$ cumple
         la condición.
      2. Sin ceros: $s \neq 0$ por la hipótesis del caso, y los demás
         coeficientes son los de $r$.
      3. Exponentes naturales: $k \in \mathbb{N}$ (venía de $ts$).
      4. Reducidos: $\mathrm{conv}(s)$ es reducido por el Lema 2, aunque
         $c$ y $\gamma$ fueran fracciones con denominadores distintos,
         porque Racket normaliza la suma.

      $E = E(ts)$, así que (b) se cumple.

    - **$s = 0$ — Caso C.** El resultado es $r$: el término desaparece.
      $\mathrm{Inv}(r)$ vale por el Lema 1 (la cola de una lista que
      cumple $\mathrm{Inv}$). En particular, quitar la cabeza no deja
      ningún coeficiente cero, y por eso la condición 2 exige borrar el
      término en lugar de dejarlo con coeficiente $0$. Además
      $E(r) \subseteq E(ts)$, así que (b) se cumple.

  - **$e < k$ — la inserción ocurre más adentro.** El resultado es
    $(\gamma, k) :: \texttt{ins}(r, c, e)$. Por (HI),
    $\mathrm{Inv}(\texttt{ins}(r, c, e))$ y
    $E(\texttt{ins}(r, c, e)) \subseteq E(r) \cup \{e\}$. Todo elemento
    de ese conjunto es menor que $k$: los de $E(r)$ por el Lema 1, y
    $e$ por la hipótesis del subcaso.
    1. Orden estricto: la cola cumple la condición por (HI), y la
       cabeza tiene exponente $k$ mayor que todos los de la cola.
    2. Sin ceros: el coeficiente de la cabeza viene de $ts$ y los de la
       cola de (HI).
    3. Exponentes naturales: igual que en la condición anterior.
    4. Reducidos: igual, por (HI).

    $E \subseteq E(ts) \cup \{e\}$, así que (b) se cumple. Según lo que
    pase dentro de la llamada recursiva, el efecto neto es el de los
    casos A, B o C. $\square$

**Cobertura de los tres casos.** Al recorrer la lista, las cláusulas
$e < k$ saltan las cabezas cuyo exponente es mayor que $e$. El recorrido
termina en el primer término con $k \le e$ o al llegar al final. Por eso
los tres casos del enunciado quedan cubiertos y son exhaustivos:

| Situación | Dónde termina el recorrido | Caso |
|---|---|---|
| El exponente no existe | fin de lista, o primera cabeza con $k < e$ | A |
| Existe y la suma no es cero | cabeza con $k = e$ y $s \neq 0$ | B |
| Existe y la suma es cero | cabeza con $k = e$ y $s = 0$ | C |

**Terminación.** Medida $\mu(ts) = |ts|$. La única llamada recursiva
(subcaso $e < k$) se hace sobre $r$, con $\mu(r) = \mu(ts) - 1$, y
$\mu \ge 0$. Además cada llamada consume un término de la lista: la
función hace una sola pasada y no necesita ordenar al final.

**Conclusión:** si $\mathrm{Inv}(p)$ vale antes de la llamada, entonces
$\mathrm{terms}(p)$ cumple $\mathrm{Inv}$, y por el Lema 3 el resultado
de `insertar-en-terminos` también. Como `insertar-termino` conserva la
variable de $p$, devuelve $p$ cuando $c = 0$ y levanta error en los
datos inválidos, vale $\mathrm{Inv}(\texttt{insertar-termino}(p, c, e))$.
El invariante **se conserva** en cada paso; no se restaura después.

---

## 3. Equivalencia de las dos representaciones

Argumente por qué las funciones de la interfaz son las mismas para la
representación basada en listas y la basada en procedimientos, y qué
propiedad de la interfaz impide que el cliente las distinga. Basta una
explicación conceptual apoyada en la sección 2.2 de EOPL, sin
demostración formal.

Conviene que la explicación responda a esto:

- {{Qué ve el cliente de un polinomio: qué operaciones tiene
  disponibles y qué no puede hacer.}}
- {{Qué cambia entre las dos representaciones y por qué ese cambio
  queda del lado de adentro de la interfaz.}}
- {{Qué habría que hacer para que el cliente sí notara la diferencia,
  y por qué eso significaría que la abstracción se rompió.}}

---

## 4. Referencias

- Friedman, D. P., & Wand, M. *Essentials of Programming Languages*,
  3.ª ed., MIT Press, 2008. Sección 2.1 (especificación de datos),
  sección 2.2 (representación basada en listas y basada en
  procedimientos), sección 2.4 (`define-datatype` y `cases`).
- The Racket Reference, *Numbers* (representación de los racionales
  exactos): https://docs.racket-lang.org/reference/numbers.html
