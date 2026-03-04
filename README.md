# Práctica de Laboratorio #4: Traducción dirigida por la sintaxis: léxicos

**Universidad de La Laguna** **Escuela Superior de Ingeniería y Tecnología** **Grado en Ingeniería Informática** 

**Asignatura:** Procesadores de Lenguajes

**Curso:** 2025/2026

**Alumno:** Eric Bermúdez Hernández (alu0101517476)

**Correo:** alu0101517476@ull.edu.es

---

## Descripción de la Práctica

Esta práctica implementa una calculadora basada en una gramática independiente del contexto utilizando Jison. Durante el análisis sintáctico, se realiza una traducción dirigida por la sintaxis (SDD) para calcular el valor de la expresión aritmética reconocida.

A cada símbolo gramatical se le asocia un atributo (`value`) que almacena el número resultante de aplicar los operadores a los operandos, permitiendo que la evaluación semántica ocurra en paralelo a la validación sintáctica.

## Instalación y Ejecución

### 1. Instalar las dependencias:

```bash
npm i
```

### 2. Generar el analizador sintáctico (Parser) con Jison:

```bash
npx jison src/grammar.jison -o src/parser.js
```

### 3. Ejecutar la suite de pruebas con Jest:

```bash
npm test
```

## Tareas Realizadas

Durante el desarrollo de esta práctica, se ha ampliado el comportamiento base del analizador léxico y se han actualizado las pruebas unitarias:

**1. Soporte para Comentarios de una línea:**
Se modificó el archivo `src/grammar.jison` para que el analizador léxico reconozca e ignore los comentarios que comienzan por `//`, permitiendo documentar las operaciones matemáticas sin afectar el análisis sintáctico.
Regla añadida: `\/\/.* { /* skip single line comments */ }`

**2. Soporte para Números Flotantes y Notación Científica:**
Se actualizó la expresión regular que reconoce los tokens numéricos. Ahora la calculadora puede operar con números enteros, decimales y notación científica (ej. `2.35`, `2.35`)
Regla modificada: `[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?\b`

**3. Actualización de las pruebas (Jest):**
Se modificó el archivo `__tests__/parser.test.js` para:

* Añadir casos de prueba que validen las expresiones con números decimales, notación científica y comentarios.

* Eliminar la comprobación antigua que esperaba que la entrada de un decimal (como `3.5`) devolviera un error, ya que ahora es una funcionalidad soportada nativamente por el analizador.

## Cuestionario del Analizador Léxico (Lexer)

### 3.1. Describa la diferencia entre `/* skip whitespace */` y devolver un token.
La acción `/* skip whitespace */` hace que el analizador léxico ignore el fragmento de texto coincidente (como los espacios) y pase a leer el siguiente sin enviar nada al analizador sintáctico. Por el contrario, al devolver un token (ej. `return 'NUMBER'`), el lexer empaqueta la información reconocida y se la entrega al parser para que este valide la estructura gramatical.

### 3.2. Escriba la secuencia exacta de tokens producidos para la entrada `123**45+0`
La secuencia sería: `NUMBER` (por 123), `OP` (por **), `NUMBER` (por 45), `OP` (por +), `NUMBER` (por 0) y finalmente `EOF`.

### 3.3. Indique por qué `**` debe aparecer antes que `[-+*/]`.
Jison evalúa las expresiones regulares en el orden en que están escritas de arriba a abajo. Si la regla `[-+*/]` (que incluye el asterisco simple) estuviera antes, al leer `**`, el lexer coincidiría con el primer `*` de forma aislada, devolviendo un token `OP` incorrecto, en lugar de reconocer los dos asteriscos juntos como el operador de potencia.

### 3.4. Explique cuándo se devuelve `EOF`.
El token `EOF` (End Of File) se devuelve cuando el analizador léxico detecta que ha llegado al final de la cadena de texto o archivo de entrada, indicándole al parser que no hay más símbolos por procesar.

### 3.5. Explique por qué existe la regla que devuelve `INVALID`.
Actúa como una regla de seguridad ("catch-all"). Si el lexer encuentra un carácter que no coincide con ninguna de las reglas válidas anteriores (números, operadores, espacios), ejecutará esta regla. Esto permite lanzar un error o manejar la situación de forma controlada en lugar de que el programa falle de forma impredecible.

---

# Práctica de Laboratorio #5: Traducción dirigida por la sintaxis: gramática Archivo

Se nos proporciona la definición de una gramática simple la cual es la siguiente:

$L \rightarrow E \text{ eof}$

$E \rightarrow E \text{ op } T$

$E \rightarrow T$

$T \rightarrow \text{number}$

Esta gramática es recursiva por la izquierda para todos los operadores `op`, lo que significa que agrupa siempre las operaciones de izquierda a derecha, sin importar si es suma, resta, multiplicación o potencia.

1. Partiendo de la gramática y las siguientes frases 4.0-2.0*3.0, 2**3**2 y 7-4/2:

1.1 Escriba la derivación para cada una de las frases.

- Derivación por la derecha

En un analizador ascendente (Bottom-Up) como Jison, se construye la derivación por la derecha en orden inverso:

1. L ⇒ E eof

2. ⇒ E op T eof (aquí op es *)

3. ⇒ E op number(3.0) eof

4. ⇒ E op T op number(3.0) eof (aquí el primer op es -)

5. ⇒ E op number(2.0) op number(3.0) eof

6. ⇒ T op number(2.0) op number(3.0) eof

7. ⇒ number(4.0) op number(2.0) op number(3.0) eof

1.2. Escriba el árbol de análisis sintáctico (parse tree) para cada una de las frases.

Árbol de Análisis Sintáctico:
            L
          /   \
         E     eof
       / | \
      E op(*) T
    / | \     |
   E op(-) T number(3.0)
   |       |
   T   number(2.0)
   |
number(4.0)

1.3. ¿En qué orden se evaluan las acciones semánticas para cada una de las frases?
Nótese que la evaluación a la que da lugar la sdd para las frases no se corresponde con los convenios de evaluación establecidos en matemáticas y los lenguajes de programación.

Las acciones se evalúan de abajo hacia arriba y de izquierda a derecha de la siguiente forma:

- Frase: `4.0-2.0*3.0`

1. Se convierte "4.0" en número (T → number).

2. Se convierte "2.0" en número (T → number).

3. Se evalúa la resta: `operate('-', 4.0, 2.0)` dando como resultado `2.0` (E → E op T).

4. Se convierte `3.0` en número (T → number).

5. Se evalúa la multiplicación: `operate('*', 2.0, 3.0)` dando como resultado final `6.0` (E → E op T).

- Frase: `2**3**2`

- Derivación por la derecha:

1. L ⇒ E eof

2. ⇒ E op T eof (aquí op es el segundo `**`)

3. ⇒ E op number(2) eof

4. ⇒ E op T op number(2) eof (aquí el primer op es el primer `**`)

5. ⇒ E op number(3) op number(2) eof

6. ⇒ T op number(3) op number(2) eof

7. ⇒ number(2) op number(3) op number(2) eof

- Árbol de Análisis Sintáctico (Parse Tree)

            L
          /   \
         E     eof
       / | \
      E op(**) T
    / | \      |
   E op(**) T number(2)
   |        |
   T     number(3)
   |
number(2)

- Orden de evaluación de las acciones semánticas

1. Se convierte el primer `2` en un número. 

2. Se convierte el 3 en un número.

3. Se evalúa la primera potencia: `operate('**', 2, 3)` dando como resultado 8 (2^3).

4. Se convierte el último `2` en número.ç

5. Se evalúa la segunda potencia: `operate('**', 8, 2)` dando como resultado final `64` (8^2).
(Orden: Se asocian de izquierda a derecha en lugar de derecha a izquierda, por lo que el resultado difiere de la convención matemática 2(32)=512).

- Frase C: `7 - 4 / 2`

1.1 Derivación (Por la derecha)

1. L ⇒ E eof 

2. ⇒ E op T eof (aquí op es /)

3. ⇒ E op number(2) eof

4. ⇒ E op T op number(2) eof (aquí el primer op es -)

5. ⇒ E op number(4) op number(2) eof

6. ⇒ T op number(4) op number(2) eof

7. ⇒ number(7) op number(4) op number(2) eof

1.2. Árbol de Análisis Sintáctico (Parse Tree)

            L
          /   \
         E     eof
       / | \
      E op(/) T
    / | \     |
   E op(-) T number(2)
   |       |
   T    number(4)
   |
number(7)

1.3 Orden de evaluación de las acciones semánticas

1. Se convierte `7` en número.

2. Se convierte `4` en número.

3. Se evalúa la resta: `operate('-', 7, 4)` dando como resultado `3`.

4. Se convierte `2` en número.

5. Se evalúa la división: `operate('/', 3, 2)` dando como resultado final `1.5`.
(Orden: Primero la resta, luego la división. Matemáticamente incorrecto, pero sintácticamente correcto para esta gramática inicial).