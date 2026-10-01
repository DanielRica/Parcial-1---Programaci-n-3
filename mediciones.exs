#Lopez Cuartas - Daniel Chacon
#
# Módulo Mediciones (BORRADOR: falta contrastarlo con el enunciado general).
#
# Mide con :timer.tc/1 cuánto tarda buscar productores en una LISTA
# (Enum.find, recorre uno por uno) frente a un MAPA indexado por código
# (Map.get, acceso directo). Sirve para justificar con datos la decisión de
# convertir la lista de productores a mapa cuando hay muchas búsquedas.
#
# :timer.tc/1 recibe una función sin argumentos y devuelve
# {microsegundos, resultado}.

defmodule Mediciones do
  @doc """
  Mide en microsegundos cuánto tarda buscar productores por código en una lista y en un mapa.

  ## Parámetros
  - cantidad: número total de productores a generar para la prueba
  - busquedas: número de búsquedas a realizar

  ## Ejemplo
  iex> Mediciones.comparar_lista_vs_mapa(100, 10)
  %{productores: 100, busquedas: 10, lista_us: ..., mapa_us: ..., veces_mas_rapido: ...}
  """
  def comparar_lista_vs_mapa(cantidad, busquedas) do
    lista = Enum.map(1..cantidad, fn n -> %{codigo: "P#{n}", nombre: "Productor #{n}"} end)
    mapa = Map.new(lista, fn p -> {p.codigo, p} end)
    # Se buscan códigos que están hacia el final de la lista (peor caso)
    codigos = Enum.map(1..busquedas, fn n -> "P#{cantidad - rem(n, 10)}" end)

    {micros_lista, _} =
      :timer.tc(fn -> Enum.each(codigos, fn c -> Enum.find(lista, &(&1.codigo == c)) end) end)

    {micros_mapa, _} = :timer.tc(fn -> Enum.each(codigos, fn c -> Map.get(mapa, c) end) end)

    %{
      productores: cantidad,
      busquedas: busquedas,
      lista_us: micros_lista,
      mapa_us: micros_mapa,
      veces_mas_rapido: micros_lista / max(micros_mapa, 1)
    }
  end

  @doc """
  Mide el tiempo en microsegundos que tarda en validarse y clasificarse un conjunto de entregas.

  ## Parámetros
  - entregas: lista de entregas a validar y clasificar
  - productores: lista de todos los productores registrados
  - tanques: lista de todos los tanques registrados

  ## Ejemplo
  iex> Mediciones.medir_clasificacion(entregas, productores, tanques)
  %{entregas: 80, microsegundos: ..., validas: 70}
  """
  def medir_clasificacion(entregas, productores, tanques) do
    {micros, resultado} = :timer.tc(fn -> Validacion.clasificar_entregas(entregas, productores, tanques) end)
    %{entregas: length(entregas), microsegundos: micros, validas: length(resultado.validas)}
  end

  @doc """
  Ejecuta las mediciones y las imprime en la consola con un formato claro.
  """
  def mostrar_mediciones(productores_datos, entregas, tanques) do
    IO.puts("\n==================================================")
    IO.puts("   MEDICIONES DE RENDIMIENTO CON :timer.tc/1")
    IO.puts("==================================================")

    # 1. Prueba con el volumen real del centro (10 productores, 500 búsquedas)
    medicion_real = comparar_lista_vs_mapa(10, 500)

    IO.puts("\n1. Comparación con datos reales del proyecto (10 productores, 500 búsquedas):")
    IO.puts("   - Tiempo en LISTA (Enum.find): #{medicion_real.lista_us} µs")
    IO.puts("   - Tiempo en MAPA (Map.get):    #{medicion_real.mapa_us} µs")
    IO.puts("   - El MAPA es #{Float.round(medicion_real.veces_mas_rapido, 2)} veces más rápido")

    # 2. Prueba con un volumen grande (500 productores, 500 búsquedas)
    medicion_grande = comparar_lista_vs_mapa(500, 500)

    IO.puts("\n2. Comparación si el centro creciera (500 productores, 500 búsquedas):")
    IO.puts("   - Tiempo en LISTA (Enum.find): #{medicion_grande.lista_us} µs")
    IO.puts("   - Tiempo en MAPA (Map.get):    #{medicion_grande.mapa_us} µs")
    IO.puts("   - El MAPA es #{Float.round(medicion_grande.veces_mas_rapido, 2)} veces más rápido")

    # 3. Medición del proceso de clasificación de entregas
    medicion_clasif = medir_clasificacion(entregas, productores_datos, tanques)

    IO.puts("\n3. Rendimiento de la validación del sistema:")
    IO.puts("   - Entregas procesadas: #{medicion_clasif.entregas}")
    IO.puts("   - Entregas válidas:    #{medicion_clasif.validas}")
    IO.puts("   - Tiempo de ejecución: #{medicion_clasif.microsegundos} µs")
    IO.puts("==================================================\n")
  end
end
