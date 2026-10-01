#Lopez Cuartas - Daniel Chacon
#
# Reutiliza las funciones de Negocio (valor de entrega, bonificación del
# día y liquidación) para que los totales del comprobante coincidan
# exactamente con los del reporte R4.

defmodule Comprobante do
  @doc """
  Genera el comprobante de liquidación de un productor dado su código.

  ## Parámetros
  - codigo: código del productor a buscar
  - productores: lista de todos los productores registrados
  - entregas_validas: lista de entregas que superaron la validación

  ## Ejemplo
  iex> Comprobante.generar("P01", productores, entregas_validas)
  {:ok, "COMPROBANTE DE LIQUIDACIÓN..."}
  """
  def generar(codigo, productores, entregas_validas) do
    with {:ok, productor} <- buscar_productor(codigo, productores) do
      {:ok, armar_texto(productor, entregas_validas)}
    end
  end

  @doc """
  Busca un productor dentro de una lista utilizando su código, ignorando mayúsculas y espacios.

  ## Parámetros
  - codigo: código del productor
  - productores: lista de productores en donde se realizará la búsqueda

  ## Ejemplo
  iex> Comprobante.buscar_productor("p01 ", [%{codigo: "P01", nombre: "Marta Gómez"}])
  {:ok, %{codigo: "P01", nombre: "Marta Gómez"}}
  """
  def buscar_productor(codigo, productores) do
    codigo_normalizado = codigo |> String.trim() |> String.upcase()

    case Enum.find(productores, &(String.upcase(&1.codigo) == codigo_normalizado)) do
      nil -> {:error, :productor_desconocido}
      productor -> {:ok, productor}
    end
  end


  # Construye el texto completo del comprobante de liquidación de un productor.
  defp armar_texto(productor, entregas_validas) do
    liquidacion = Negocio.liquidar_productor(productor, entregas_validas)

    detalle_dias =
      entregas_validas
      |> Enum.filter(&(&1.productor == productor.codigo))
      |> Enum.group_by(& &1.dia)
      |> Enum.sort_by(fn {dia, _entregas} -> dia end)
      |> Enum.map(fn {dia, entregas} -> linea_dia(dia, entregas) end)
      |> detalle_o_aviso()

    """
    COMPROBANTE DE LIQUIDACIÓN
    Productor: #{productor.nombre} (#{productor.codigo})

    Detalle por día:
    #{detalle_dias}
    Litros entregados: #{liquidacion.litros} L
    Total entregas: $#{round(liquidacion.valor_entregas)}
    Total bonificaciones: $#{round(liquidacion.bonificaciones)}
    Descuento por transporte: $#{round(liquidacion.transporte)}
    NETO A PAGAR: $#{round(liquidacion.neto)}\
    """
  end

  # Genera la línea descriptiva de litros, valor y bonificación de un día.
  defp linea_dia(dia, entregas) do
    litros = entregas |> Enum.map(& &1.litros) |> Enum.sum()
    valor = entregas |> Enum.map(&Negocio.valor_entrega(&1.litros, &1.grasa)) |> Enum.sum()
    bonificacion = Negocio.bonificacion_dia(litros)

    " - Día #{dia}: #{litros} L | entregas $#{round(valor)} | bonificación $#{bonificacion}"
  end

  # Devuelve el texto de detalles unido o un aviso si la lista está vacía.
  defp detalle_o_aviso([]), do: " (sin entregas válidas)"
  defp detalle_o_aviso(lineas), do: Enum.join(lineas, "\n")
end
