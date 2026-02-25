# Práctica de Laboratorio #4: Traducción dirigida por la sintaxis: léxicos

**Universidad de La Laguna** **Escuela Superior de Ingeniería y Tecnología** **Grado en Ingeniería Informática** **Asignatura:** Procesadores de Lenguajes
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