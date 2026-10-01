#Lopez Cuartas - Daniel Chacon
#
# Módulo Reportes: los 8 reportes exigidos por el enunciado (R1 a R8).
# Cada función generar_rX es pura: recibe datos ya calculados y devuelve
# el texto del reporte. Quien lo muestra en pantalla es el main, a través
# de Util2.mostrar/2.

defmodule Reportes do
  @dias 1..6
  @meta_diaria 2000
  @minimo_entregas_r6 3

  @doc """
  Genera los 8 reportes, en el orden exigido (R1 a R8), como una lista de textos.

  ## Parámetros
  - %{validas: validas, invalidas: invalidas}: mapa con entregas válidas e inválidas
  - productores: lista de productores
  - tanques: lista de tanques

  ## Ejemplo
  iex> Reportes.generar_todos(clasificadas, productores, tanques)
  ["R1. Entregas rechazadas...", "R2. Litros por tanque..."]
  """
  def generar_todos(%{validas: validas, invalidas: invalidas}, productores, tanques) do
    liquidaciones = Negocio.liquidar_todos(productores, validas)

    [
      generar_r1(invalidas),
      generar_r2(tanques, validas),
      generar_r3(validas),
      generar_r4(liquidaciones),
      generar_r5(validas, productores),
      generar_r6(validas, productores),
      generar_r7(liquidaciones, validas),
      generar_r8(validas, productores, tanques)
    ]
    |> Enum.map(&String.trim_trailing/1)
  end

  # -----------------------------------
  # R1. Entregas rechazadas y motivo
  # -----------------------------------

  @doc """
  Genera el texto del reporte R1: cada entrega rechazada con su motivo,
  y la cantidad de rechazos agrupada por motivo.

  ## Parámetros
  - invalidas: lista de entregas inválidas con su motivo de rechazo

  ## Ejemplo
  iex> Reportes.generar_r1(invalidas)
  "R1. Entregas rechazadas..."
  """
  def generar_r1(invalidas) do
    detalle =
      invalidas
      |> Enum.map(fn %{entrega: e, motivo: motivo} ->
        " - productor=#{inspect(e.productor)}, tanque=#{inspect(e.tanque)}, " <>
          "dia=#{inspect(e.dia)}, litros=#{inspect(e.litros)}, grasa=#{inspect(e.grasa)} " <>
          "-> #{motivo}\n"
      end)
      |> Enum.join()

    conteo =
      invalidas
      |> Enum.frequencies_by(& &1.motivo)
      |> Enum.map(fn {motivo, cantidad} -> " - #{motivo}: #{cantidad}\n" end)
      |> Enum.join()

    """
    R1. Entregas rechazadas
    #{detalle}
    Cantidad de rechazos por motivo:
    #{conteo}\
    """
  end

  # -----------------------------------
  # R2. Litros y % de ocupación por tanque
  # -----------------------------------

  @doc """
  Calcula los litros almacenados y porcentaje de ocupación de cada tanque.
  Un tanque sin entregas válidas queda con 0 litros.

  ## Parámetros
  - tanques: lista de tanques
  - entregas_validas: lista de entregas válidas

  ## Ejemplo
  iex> Reportes.litros_por_tanque(tanques, entregas)
  [%{id: "T1", litros: 1000, porcentaje: 10.0}]
  """
  def litros_por_tanque(tanques, entregas_validas) do
    Enum.map(tanques, fn tanque ->
      litros =
        entregas_validas
        |> Enum.filter(&(&1.tanque == tanque.id))
        |> Enum.map(& &1.litros)
        |> Enum.sum()

      porcentaje = litros / tanque.capacidad * 100

      %{id: tanque.id, nombre: tanque.nombre, litros: litros, capacidad: tanque.capacidad, porcentaje: porcentaje}
    end)
  end

  @doc """
  Genera el texto del reporte R2 ordenado por porcentaje de ocupación.

  ## Parámetros
  - tanques: lista de tanques
  - entregas_validas: lista de entregas válidas

  ## Ejemplo
  iex> Reportes.generar_r2(tanques, entregas)
  "R2. Litros por tanque y % de ocupación..."
  """
  def generar_r2(tanques, entregas_validas) do
    filas =
      tanques
      |> litros_por_tanque(entregas_validas)
      |> Util2.ordenar(:desc, & &1.porcentaje)
      |> Enum.map(fn t ->
        " - #{t.id} (#{t.nombre}): #{t.litros} L de #{t.capacidad} L -> " <>
          "#{Float.round(t.porcentaje, 1)}% de ocupación\n"
      end)
      |> Enum.join()

    "R2. Litros por tanque y % de ocupación (mayor a menor)\n#{filas}"
  end

  # -----------------------------------
  # R3. Litros por día y cumplimiento de la meta
  # -----------------------------------

  @doc """
  Calcula los litros recibidos en cada uno de los 6 días de recepción.
  Un día sin entregas válidas queda en 0.

  ## Parámetros
  - entregas_validas: lista de entregas válidas

  ## Ejemplo
  iex> Reportes.litros_por_dia(entregas)
  %{1 => 100, 2 => 200, 3 => 0, 4 => 0, 5 => 0, 6 => 0}
  """
  def litros_por_dia(entregas_validas) do
    agrupado =
      entregas_validas
      |> Enum.group_by(& &1.dia)
      |> Enum.map(fn {dia, entregas} -> {dia, Enum.sum(Enum.map(entregas, & &1.litros))} end)
      |> Enum.into(%{})

    Enum.into(@dias, %{}, fn dia -> {dia, Map.get(agrupado, dia, 0)} end)
  end

  @doc """
  Genera el reporte R3 evaluando el cumplimiento de la meta por día.

  ## Parámetros
  - entregas_validas: lista de entregas válidas
  - meta_diaria: cantidad de litros requerida para cumplir la meta

  ## Ejemplo
  iex> Reportes.generar_r3(entregas, 2000)
  "R3. Litros por día y cumplimiento de la meta..."
  """
  def generar_r3(entregas_validas, meta_diaria \\ @meta_diaria) do
    litros_dia = litros_por_dia(entregas_validas)

    filas =
      @dias
      |> Enum.map(fn dia ->
        litros = Map.get(litros_dia, dia, 0)
        estado = if litros >= meta_diaria, do: "sí cumplió la meta", else: "no cumplió la meta"
        " - Día #{dia}: #{litros} L -> #{estado}\n"
      end)
      |> Enum.join()

    cumplimientos = Enum.map(@dias, fn dia -> Map.get(litros_dia, dia, 0) >= meta_diaria end)
    todos_los_dias = Enum.all?(cumplimientos)
    al_menos_un_dia = Enum.any?(cumplimientos)

    """
    R3. Litros por día y cumplimiento de la meta (#{meta_diaria} L)
    #{filas}
    ¿Se cumplió la meta todos los días? #{si_no(todos_los_dias)}
    ¿Se cumplió la meta al menos un día? #{si_no(al_menos_un_dia)}\
    """
  end

  # -----------------------------------
  # R4. Liquidación numerada y ordenada
  # -----------------------------------

  @doc """
  Genera el texto del reporte R4 con la liquidación de todos los productores,
  numerada y ordenada de mayor a menor pago neto.

  ## Parámetros
  - liquidaciones: lista de liquidaciones calculadas

  ## Ejemplo
  iex> Reportes.generar_r4(liquidaciones)
  "R4. Liquidación de productores..."
  """
  def generar_r4(liquidaciones) do
    filas =
      liquidaciones
      |> Util2.ordenar(:desc, & &1.neto)
      |> Enum.with_index(1)
      |> Enum.map(fn {l, indice} ->
        " #{indice}. #{l.codigo} - #{l.nombre}: litros=#{l.litros}, " <>
          "entregas=$#{redondear(l.valor_entregas)}, bonificaciones=$#{redondear(l.bonificaciones)}, " <>
          "transporte=$#{redondear(l.transporte)}, neto=$#{redondear(l.neto)}\n"
      end)
      |> Enum.join()

    "R4. Liquidación de productores (ordenada por neto, de mayor a menor)\n#{filas}"
  end

  # -----------------------------------
  # R5. Productor con más litros por día
  # -----------------------------------

  @doc """
  Calcula los litros entregados por cada productor en un día específico.

  ## Parámetros
  - entregas_validas: lista de entregas válidas
  - dia: día a evaluar

  ## Ejemplo
  iex> Reportes.litros_por_productor_en_dia(entregas, 1)
  %{"P01" => 500, "P02" => 300}
  """
  def litros_por_productor_en_dia(entregas_validas, dia) do
    entregas_validas
    |> Enum.filter(&(&1.dia == dia))
    |> Enum.group_by(& &1.productor)
    |> Enum.map(fn {productor, entregas} -> {productor, Enum.sum(Enum.map(entregas, & &1.litros))} end)
  end

  @doc """
  Devuelve el código o códigos del productor(es) con más litros entregados en un día.
  Si hay empate, devuelve todos los códigos empatados.

  ## Parámetros
  - entregas_validas: lista de entregas válidas
  - dia: día a evaluar

  ## Ejemplo
  iex> Reportes.ganadores_del_dia(entregas, 1)
  ["P01", "P02"]
  """
  def ganadores_del_dia(entregas_validas, dia) do
    case litros_por_productor_en_dia(entregas_validas, dia) do
      [] ->
        []

      litros_por_productor ->
        maximo = litros_por_productor |> Enum.map(fn {_p, litros} -> litros end) |> Enum.max()

        litros_por_productor
        |> Enum.filter(fn {_p, litros} -> litros == maximo end)
        |> Enum.map(fn {p, _litros} -> p end)
    end
  end

  @doc """
  Genera el reporte R5 indicando el productor con más litros cada día.

  ## Parámetros
  - entregas_validas: lista de entregas válidas
  - productores: lista de todos los productores

  ## Ejemplo
  iex> Reportes.generar_r5(entregas, productores)
  "R5. Productor con más litros entregados..."
  """
  def generar_r5(entregas_validas, productores) do
    ganadores_por_dia = Enum.map(@dias, fn dia -> {dia, ganadores_del_dia(entregas_validas, dia)} end)

    filas =
      ganadores_por_dia
      |> Enum.map(fn {dia, ganadores} ->
        texto = if ganadores == [], do: "sin entregas válidas", else: Enum.join(nombres_de(ganadores, productores), ", ")
        " - Día #{dia}: #{texto}\n"
      end)
      |> Enum.join()

    conteo_victorias =
      ganadores_por_dia
      |> Enum.flat_map(fn {_dia, ganadores} -> ganadores end)
      |> Enum.frequencies()

    primer_lugar =
      case conteo_victorias do
        m when map_size(m) == 0 ->
          "nadie (no hubo entregas válidas)"

        _ ->
          maximo_victorias = conteo_victorias |> Map.values() |> Enum.max()

          conteo_victorias
          |> Enum.filter(fn {_p, victorias} -> victorias == maximo_victorias end)
          |> Enum.map(fn {p, _victorias} -> p end)
          |> nombres_de(productores)
          |> Enum.join(", ")
      end

    """
    R5. Productor con más litros entregados cada día
    #{filas}
    Ocupó el primer lugar en más días: #{primer_lugar}\
    """
  end

  # -----------------------------------
  # R6. Mejor calidad (grasa ponderada por litros)
  # -----------------------------------

  @doc """
  Calcula el porcentaje de grasa ponderado por litros de un productor.
  (suma(grasa * litros) / suma(litros)).

  ## Parámetros
  - entregas_validas: lista de entregas válidas
  - codigo_productor: identificador del productor

  ## Ejemplo
  iex> Reportes.grasa_ponderada(entregas, "P01")
  3.5
  """
  def grasa_ponderada(entregas_validas, codigo_productor) do
    entregas = Enum.filter(entregas_validas, &(&1.productor == codigo_productor))
    litros_totales = entregas |> Enum.map(& &1.litros) |> Enum.sum()
    suma_ponderada = entregas |> Enum.map(&(&1.grasa * &1.litros)) |> Enum.sum()

    if litros_totales == 0, do: 0, else: suma_ponderada / litros_totales
  end

  @doc """
  Genera el reporte R6 con el productor que tiene la mejor calidad de leche.

  ## Parámetros
  - entregas_validas: lista de entregas válidas
  - productores: lista de todos los productores

  ## Ejemplo
  iex> Reportes.generar_r6(entregas, productores)
  "R6. Productor con mejor calidad..."
  """
  def generar_r6(entregas_validas, productores) do
    candidatos =
      productores
      |> Enum.map(fn p -> {p, Enum.count(entregas_validas, &(&1.productor == p.codigo))} end)
      |> Enum.filter(fn {_p, cantidad} -> cantidad >= @minimo_entregas_r6 end)

    case candidatos do
      [] ->
        "R6. Ningún productor tiene al menos #{@minimo_entregas_r6} entregas válidas.\n"

      _ ->
        {mejor, _cantidad} = Enum.max_by(candidatos, fn {p, _c} -> grasa_ponderada(entregas_validas, p.codigo) end)
        ponderado = grasa_ponderada(entregas_validas, mejor.codigo)

        """
        R6. Productor con mejor calidad (grasa ponderada por litros, mínimo #{@minimo_entregas_r6} entregas)
         - #{mejor.nombre} (#{mejor.codigo}): #{Float.round(ponderado * 1.0, 2)}% de grasa ponderada\
        """
    end
  end

  # -----------------------------------
  # R7. Total pagado y costo promedio por litro
  # -----------------------------------

  @doc """
  Genera el reporte R7 con el total pagado en la semana y el costo promedio por litro.

  ## Parámetros
  - liquidaciones: lista de liquidaciones calculadas
  - entregas_validas: lista de entregas válidas

  ## Ejemplo
  iex> Reportes.generar_r7(liquidaciones, entregas)
  "R7. Total pagado y costo promedio..."
  """
  def generar_r7(liquidaciones, entregas_validas) do
    total_pagado = liquidaciones |> Enum.map(& &1.neto) |> Enum.sum()
    litros_totales = entregas_validas |> Enum.map(& &1.litros) |> Enum.sum()
    costo_promedio = if litros_totales == 0, do: 0, else: total_pagado / litros_totales

    """
    R7. Total pagado y costo promedio por litro
     - Total pagado en la semana: $#{round(total_pagado)}
     - Litros válidos recibidos: #{litros_totales} L
     - Costo promedio pagado por litro: $#{Float.round(costo_promedio * 1.0, 2)}\
    """
  end

  # -----------------------------------
  # R8. Productores con entrega en todos los tanques
  # -----------------------------------

  @doc """
  Calcula los tanques distintos en los que un productor tiene al menos una entrega válida.

  ## Parámetros
  - entregas_validas: lista de entregas válidas
  - codigo_productor: identificador del productor

  ## Ejemplo
  iex> Reportes.tanques_de_productor(entregas, "P01")
  ["T1", "T2"]
  """
  def tanques_de_productor(entregas_validas, codigo_productor) do
    entregas_validas
    |> Enum.filter(&(&1.productor == codigo_productor))
    |> Enum.map(& &1.tanque)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Genera el reporte R8 con los productores que entregaron leche en todos los tanques.

  ## Parámetros
  - entregas_validas: lista de entregas válidas
  - productores: lista de todos los productores
  - tanques: lista de todos los tanques

  ## Ejemplo
  iex> Reportes.generar_r8(entregas, productores, tanques)
  "R8. Productores con entrega válida en todos los tanques..."
  """
  def generar_r8(entregas_validas, productores, tanques) do
    ids_tanques = tanques |> Enum.map(& &1.id) |> Enum.sort()

    cumplen =
      Enum.filter(productores, fn p ->
        tanques_de_productor(entregas_validas, p.codigo) == ids_tanques
      end)

    detalle =
      case cumplen do
        [] -> " - Ninguno\n"
        _ -> cumplen |> Enum.map(fn p -> " - #{p.nombre} (#{p.codigo})\n" end) |> Enum.join()
      end

    "R8. Productores con entrega válida en todos los tanques\n#{detalle}"
  end

  # -----------------------------------
  # Auxiliares privadas
  # -----------------------------------

  # Convierte un booleano a la cadena "Sí" o "No".
  defp si_no(true), do: "Sí"
  defp si_no(false), do: "No"

  # Redondea un número a su entero más cercano.
  defp redondear(valor), do: round(valor)

  # Transforma una lista de códigos de productor a cadenas legibles con nombre y código.
  defp nombres_de(codigos, productores) do
    Enum.map(codigos, fn codigo ->
      productor = Enum.find(productores, &(&1.codigo == codigo))
      "#{productor.nombre} (#{codigo})"
    end)
  end
end
