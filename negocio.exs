#Lopez Cuartas - Daniel Chacon
#
# Reglas de negocio del centro de acopio: valor de una entrega según su
# calidad, bonificación por volumen diario, descuento de transporte y
# liquidación final por productor.
#
# Todas las funciones son puras: dependen únicamente de sus argumentos y
# no leen ni escriben datos del usuario. No hay recursividad ni structs;
# los recorridos se hacen con Enum.

defmodule Negocio do
  @tarifa_base 1800
  @litros_bonificacion 450
  @valor_bonificacion 25_000
  @costo_transporte 18_000

  # -----------------------------------
  # Valor de una entrega (según grasa)
  # -----------------------------------

  @doc """
  Calcula el valor en pesos de una entrega válida a partir de sus litros
  y el ajuste que corresponde según el porcentaje de grasa de la muestra.

  ## Parámetros
  - litros: cantidad de litros de la entrega
  - grasa: porcentaje de grasa de la entrega

  ## Ejemplo
  iex> Negocio.valor_entrega(100, 4.0)
  190800.0
  """
  def valor_entrega(litros, grasa) do
    base = litros * @tarifa_base
    ajuste = porcentaje_ajuste_grasa(grasa)
    base + base * ajuste
  end

  @doc """
  Determina el porcentaje de ajuste sobre el valor de una entrega según
  el porcentaje de grasa de la muestra.

  ## Parámetros
  - grasa: porcentaje de grasa de la muestra

  ## Ejemplo
  iex> Negocio.porcentaje_ajuste_grasa(3.6)
  0.06
  """
  def porcentaje_ajuste_grasa(grasa) when grasa >= 3.5, do: 0.06
  def porcentaje_ajuste_grasa(grasa) when grasa >= 3.0, do: 0.0
  def porcentaje_ajuste_grasa(grasa) when grasa >= 2.5, do: -0.08
  def porcentaje_ajuste_grasa(_grasa), do: -0.20

  @doc """
  Calcula el valor total de todas las entregas válidas de un productor.

  ## Parámetros
  - entregas_validas: lista de todas las entregas validadas
  - codigo_productor: identificador del productor

  ## Ejemplo
  iex> Negocio.valor_total_entregas(entregas, "P01")
  190800.0
  """
  def valor_total_entregas(entregas_validas, codigo_productor) do
    entregas_validas
    |> Enum.filter(&(&1.productor == codigo_productor))
    |> Enum.map(&valor_entrega(&1.litros, &1.grasa))
    |> Enum.sum()
  end

  # -----------------------------------
  # Bonificación por volumen diario
  # -----------------------------------

  @doc """
  Agrupa y suma los litros entregados por un productor por cada día.

  ## Parámetros
  - entregas_validas: lista de todas las entregas validadas
  - codigo_productor: identificador del productor

  ## Ejemplo
  iex> Negocio.litros_por_dia_de_productor(entregas, "P01")
  [{1, 433}, {2, 231}]
  """
  def litros_por_dia_de_productor(entregas_validas, codigo_productor) do
    entregas_validas
    |> Enum.filter(&(&1.productor == codigo_productor))
    |> Enum.group_by(& &1.dia)
    |> Enum.map(fn {dia, entregas} -> {dia, Enum.sum(Enum.map(entregas, & &1.litros))} end)
  end

  @doc """
  Calcula la bonificación monetaria de un día según el volumen de litros recibidos.

  ## Parámetros
  - litros_dia: total de litros entregados en el día

  ## Ejemplo
  iex> Negocio.bonificacion_dia(500)
  25000
  """
  def bonificacion_dia(litros_dia) when litros_dia >= @litros_bonificacion, do: @valor_bonificacion
  def bonificacion_dia(_litros_dia), do: 0

  @doc """
  Calcula la bonificación total sumada de todos los días de un productor.

  ## Parámetros
  - entregas_validas: lista de entregas validadas
  - codigo_productor: identificador del productor

  ## Ejemplo
  iex> Negocio.bonificacion_total(entregas, "P01")
  25000
  """
  def bonificacion_total(entregas_validas, codigo_productor) do
    entregas_validas
    |> litros_por_dia_de_productor(codigo_productor)
    |> Enum.map(fn {_dia, litros} -> bonificacion_dia(litros) end)
    |> Enum.sum()
  end

  # -----------------------------------
  # Descuento de transporte
  # -----------------------------------

  @doc """
  Determina los días distintos en los que un productor realizó entregas.

  ## Parámetros
  - entregas_validas: lista de todas las entregas validadas
  - codigo_productor: identificador del productor

  ## Ejemplo
  iex> Negocio.dias_con_entrega(entregas, "P01")
  [1, 2, 3]
  """
  def dias_con_entrega(entregas_validas, codigo_productor) do
    entregas_validas
    |> Enum.filter(&(&1.productor == codigo_productor))
    |> Enum.map(& &1.dia)
    |> Enum.uniq()
  end

  @doc """
  Calcula el descuento de transporte a aplicar a un productor si utiliza el servicio.

  ## Parámetros
  - productor: mapa con la información del productor (incluye clave transporte)
  - entregas_validas: lista de todas las entregas validadas

  ## Ejemplo
  iex> Negocio.descuento_transporte(productor, entregas)
  18000
  """
  def descuento_transporte(productor, entregas_validas) do
    if productor.transporte do
      entregas_validas
      |> dias_con_entrega(productor.codigo)
      |> length()
      |> Kernel.*(@costo_transporte)
    else
      0
    end
  end

  # -----------------------------------
  # Liquidación
  # -----------------------------------

  @doc """
  Liquida el pago total a un productor tomando en cuenta sus entregas, bonificaciones y descuentos.

  ## Parámetros
  - productor: mapa con los datos del productor a liquidar
  - entregas_validas: lista con todas las entregas validadas

  ## Ejemplo
  iex> Negocio.liquidar_productor(productor, entregas)
  %{codigo: "P01", nombre: "Marta", neto: 250000.0, ...}
  """
  def liquidar_productor(productor, entregas_validas) do
    entregas_del_productor = Enum.filter(entregas_validas, &(&1.productor == productor.codigo))
    litros_totales = entregas_del_productor |> Enum.map(& &1.litros) |> Enum.sum()

    valor_entregas = valor_total_entregas(entregas_validas, productor.codigo)
    bonificaciones = bonificacion_total(entregas_validas, productor.codigo)
    transporte = descuento_transporte(productor, entregas_validas)
    neto = valor_entregas + bonificaciones - transporte

    %{
      codigo: productor.codigo,
      nombre: productor.nombre,
      litros: litros_totales,
      valor_entregas: valor_entregas,
      bonificaciones: bonificaciones,
      transporte: transporte,
      neto: neto
    }
  end

  @doc """
  Calcula la liquidación para todos los productores registrados.

  ## Parámetros
  - productores: lista de todos los productores registrados
  - entregas_validas: lista con todas las entregas validadas

  ## Ejemplo
  iex> Negocio.liquidar_todos(productores, entregas)
  [%{codigo: "P01", neto: 250000.0}, ...]
  """
  def liquidar_todos(productores, entregas_validas) do
    Enum.map(productores, &liquidar_productor(&1, entregas_validas))
  end
end
