#Lopez Cuartas - Daniel Chacon
#
# Módulo Investigacion: la parte de investigación del parcial.
#   1. Combinación de mapas con Map./3 (litros por día de dos centros).
#   2. Comparación entre promedio simple y ponderado de grasa (para R6).
#   3. ranking/2 con keyword lists  ->  BORRADOR: falta contrastarlo con el
#      enunciado general del curso, que no se ha revisado todavía.
#
# Todas las funciones son puras y sin recursividad.

defmodule Investigacion do
  # -----------------------------------
  # 1. Map.merge/3
  # -----------------------------------

  @doc """
  Combina el mapa de litros por día del centro con el de otro centro de acopio,
  sumando los valores de las claves que aparecen en ambos mapas.

  ## Parámetros
  - litros_propios: mapa con los litros agrupados por día de este centro
  - litros_vecino: mapa con los litros agrupados por día del centro vecino

  ## Ejemplo
  iex> Investigacion.combinar_litros(%{1 => 100, 2 => 50}, %{2 => 30, 7 => 800})
  %{1 => 100, 2 => 80, 7 => 800}
  """
  def combinar_litros(litros_propios, litros_vecino) do
    Map.merge(litros_propios, litros_vecino, fn _dia, propios, vecino -> propios + vecino end)
  end

  # -----------------------------------
  # 2. Promedio simple vs. ponderado por litros
  # -----------------------------------

  @doc """
  Calcula el promedio simple y el ponderado por litros de grasa para cada productor
  y la diferencia entre ambos.

  ## Parámetros
  - entregas_validas: lista de entregas que pasaron validación
  - productores: lista de productores a calcular
  - minimo: cantidad mínima de entregas requeridas para procesar a un productor

  ## Ejemplo
  iex> Investigacion.comparar_promedios(entregas, productores, 3)
  [%{codigo: "P01", ...}]
  """
  def comparar_promedios(entregas_validas, productores, minimo \\ 3) do
    productores
    |> Enum.map(fn p -> {p, Enum.filter(entregas_validas, &(&1.productor == p.codigo))} end)
    |> Enum.filter(fn {_p, entregas} -> length(entregas) >= minimo end)
    |> Enum.map(fn {p, entregas} ->
      simple = promedio_simple(entregas)
      ponderado = promedio_ponderado(entregas)

      %{
        codigo: p.codigo,
        nombre: p.nombre,
        entregas: length(entregas),
        simple: simple,
        ponderado: ponderado,
        diferencia: ponderado - simple
      }
    end)
  end

  # Calcula el promedio simple del porcentaje de grasa de una lista de entregas.
  defp promedio_simple(entregas) do
    (entregas |> Enum.map(& &1.grasa) |> Enum.sum()) / length(entregas)
  end

  # Calcula el promedio de grasa ponderado según los litros de cada entrega.
  defp promedio_ponderado(entregas) do
    litros = entregas |> Enum.map(& &1.litros) |> Enum.sum()
    (entregas |> Enum.map(&(&1.grasa * &1.litros)) |> Enum.sum()) / litros
  end

  # -----------------------------------
  # 3. ranking/2 con keyword lists (BORRADOR)
  # -----------------------------------

  @doc """
  Ordena una colección y devuelve las primeras posiciones, configurado con
  una keyword list de opciones.

  ## Parámetros
  - coleccion: lista de elementos a ordenar
  - opciones: lista de palabras clave con opciones como `:por`, `:orden`, `:top`

  ## Ejemplo
  iex> Investigacion.ranking([%{n: "a", v: 3}, %{n: "b", v: 9}, %{n: "c", v: 5}], por: & &1.v, top: 2)
  [%{n: "b", v: 9}, %{n: "c", v: 5}]
  """
  def ranking(coleccion, opciones \\ []) do
    por = Keyword.get(opciones, :por, & &1)
    orden = Keyword.get(opciones, :orden, :desc)
    top = Keyword.get(opciones, :top, length(coleccion))

    coleccion
    |> Util2.ordenar(orden, por)
    |> Enum.take(top)
  end
end
