defmodule Util2 do
  @moduledoc """
  Funciones auxiliares de propósito general para entrada y salida de datos,
  procesamiento de colecciones y conversión de sus elementos a texto.

  El módulo incluye funciones para:

  - leer datos desde teclado;
  - validar valores enteros, reales y booleanos;
  - ingresar colecciones de elementos;
  - mostrar mensajes y errores;
  - ordenar y filtrar colecciones;
  - convertir colecciones a una representación textual.

  ## Información

  - **Versión:** 2.0
  - **Autor:** Julián E. Gutiérrez P.
  - **Fecha:** septiembre de 2026
  - **Licencia:** GNU GPL v3
  """

  # -----------------------------------
  # Salida de datos
  # -----------------------------------

  @doc """
  Muestra un mensaje en la salida indicada (estándar o de errores).

  ## Parámetros
  - mensaje: contenido que se desea mostrar
  - :mensaje / :error: átomo indicador de la salida (estándar o error)

  ## Ejemplo
  iex> Util2.mostrar("Hola Mundo", :mensaje)
  :ok
  """
  def mostrar(mensaje, :mensaje), do: IO.puts(mensaje)
  def mostrar(mensaje, :error), do: IO.puts(:standard_error, mensaje)

  # -----------------------------------
  # Entrada de datos
  # -----------------------------------

  @doc """
  Lee desde teclado un dato o una colección de datos de forma interactiva.

  ## Parámetros
  - pregunta: texto promocional o función para pedir el dato
  - tipo_dato: átomo indicador del tipo de dato o colección

  ## Ejemplo
  iex> Util2.ingresar("Ingrese edad: ", :entero)
  15
  """
  def ingresar(pregunta, :coleccion_reales) do
    ingresar(fn -> ingresar(pregunta, :real) end, :coleccion)
  end

  def ingresar(pregunta, :coleccion_enteros) do
    ingresar(fn -> ingresar(pregunta, :entero) end, :coleccion)
  end

  def ingresar(pregunta, :coleccion_textos) do
    ingresar(fn -> ingresar(pregunta, :texto) end, :coleccion)
  end

  def ingresar(ingresar_elemento, :coleccion) do
    ingresar_coleccion(ingresar_elemento, [])
  end

  def ingresar(pregunta, :boolean) do
    ingresar(
      pregunta,
      fn texto ->
        case String.downcase(texto) do
          "s" -> {true, ""}
          "n" -> {false, ""}
          _ -> :error
        end
      end,
      :boolean
    )
  end

  def ingresar(pregunta, :real) do
    ingresar(pregunta, &Float.parse/1, :real)
  end

  def ingresar(pregunta, :entero) do
    ingresar(pregunta, &Integer.parse/1, :entero)
  end

  @doc """
  Función para solicitar e ingresar un valor de texto desde la consola.

  ## Parámetros
  - mensaje: texto promocional que se le muestra al usuario antes de solicitar el dato
  - :texto: átomo indicador del tipo de dato solicitado

  ## Ejemplo
  iex> Util.ingresar("Ingrese su nombre: ", :texto)
  "Daniel"
  """
  def ingresar(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  # -----------------------------------
  # Operaciones sobre colecciones
  # -----------------------------------

  @doc """
  Ordena los elementos de una colección según una función y sentido dados.

  ## Parámetros
  - coleccion: colección que se desea ordenar
  - sentido: orden `:asc` o `:desc`
  - obtener_campo: función que obtiene el valor utilizado como criterio de ordenamiento

  ## Ejemplo
  iex> Util2.ordenar([3, 1, 2])
  [1, 2, 3]
  """
  def ordenar(coleccion, sentido \\ :asc, obtener_campo \\ & &1) do
    Enum.sort_by(coleccion, obtener_campo, sentido)
  end

  @doc """
  Filtra una colección de cadenas conservando aquellas cuya longitud sea menor o igual al valor indicado.

  ## Parámetros
  - coleccion: colección de cadenas que se desea filtrar
  - longitud: longitud máxima permitida

  ## Ejemplo
  iex> Util2.aplicar_filtro_longitud(["a", "abc", "abcd"], 3)
  ["a", "abc"]
  """
  def aplicar_filtro_longitud(coleccion, longitud) do
    Enum.filter(coleccion, &(String.length(&1) <= longitud))
  end

  @doc """
  Filtra una colección de cadenas conservando aquellas que comienzan con una subcadena determinada.

  ## Parámetros
  - coleccion: colección de cadenas que se desea filtrar
  - inicia: subcadena con la que deben comenzar los elementos seleccionados

  ## Ejemplo
  iex> Util2.aplicar_filtro_inicial(["Ana", "Juan", "Aníbal"], "An")
  ["Ana", "Aníbal"]
  """
  def aplicar_filtro_inicial(coleccion, inicia) do
    Enum.filter(coleccion, &String.starts_with?(&1, inicia))
  end

  @doc """
  Aplica un formato textual a cada elemento de una colección.

  ## Parámetros
  - coleccion: colección cuyos elementos se desean convertir
  - formato: función que recibe un elemento y retorna su representación textual

  ## Ejemplo
  iex> Util2.convertir_coleccion_mensaje([1, 2])
  [" - 1\\n", " - 2\\n"]
  """
  def convertir_coleccion_mensaje(
        coleccion,
        formato \\ fn elemento -> " - #{elemento}\n" end
      ) do
    Enum.map(coleccion, formato)
  end

  # -----------------------------------
  # Funciones auxiliares privadas
  # -----------------------------------

  # Ingresa los elementos de una colección leyendo de teclado hasta que el usuario indique que no hay más.
  defp ingresar_coleccion(ingresar_elemento, lista_actual) do
    elemento = ingresar_elemento.()
    nueva_lista = [elemento | lista_actual]

    case ingresar("\n¿Hay más datos (s/n)? ", :boolean) do
      true ->
        ingresar_coleccion(ingresar_elemento, nueva_lista)

      false ->
        Enum.reverse(nueva_lista)
    end
  end

  # Lee y valida un dato utilizando una función parser. Reintenta si el valor no es válido.
  defp ingresar(pregunta, parser, tipo_dato) do
    resultado =
      pregunta
      |> ingresar(:texto)
      |> parser.()

    case resultado do
      {valor, ""} ->
        valor

      _ ->
        mostrar(
          "El valor ingresado no es válido para el tipo #{tipo_dato}. Intente nuevamente.\n",
          :error
        )

        ingresar(pregunta, tipo_dato)
    end
  end
end
