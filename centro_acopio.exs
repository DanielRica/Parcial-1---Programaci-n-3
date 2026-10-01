#Lopez Cuartas - Daniel Chacon
#
# Programa principal del centro de acopio de leche.



Code.require_file("util2.ex", __DIR__)
Code.require_file("datos.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)
Code.require_file("negocio.exs", __DIR__)
Code.require_file("entrada.exs", __DIR__)
Code.require_file("reportes.exs", __DIR__)
Code.require_file("comprobante.exs", __DIR__)
Code.require_file("investigacion.exs", __DIR__)
Code.require_file("mediciones.exs", __DIR__)

defmodule CentroAcopio do
  @pregunta_entrega """
  Ingrese una entrega adicional
  (productor;tanque;dia;litros;grasa)
  o Enter para omitir:
  """

  # Litros diarios informados por el centro vecino
  @centro_vecino %{1 => 1850.5, 2 => 2100, 3 => 1640, 5 => 2350, 7 => 800}

  @doc """
  Función principal que orquesta la ejecución del centro de acopio.

  ## Parámetros
  - No recibe parámetros.

  ## Ejemplo
  iex> CentroAcopio.main()
  :ok
  """
  def main do
    productores = Datos.productores()
    tanques = Datos.tanques()

    clasificadas =
      Datos.entregas()
      |> agregar_entrega_adicional()
      |> Validacion.clasificar_entregas(productores, tanques)

    clasificadas
    |> Reportes.generar_todos(productores, tanques)
    |> mostrar_reportes()

    clasificadas.validas
    |> generar_investigacion(productores)
    |> Util2.mostrar(:mensaje)

    "\nIngrese el código de un productor para ver su comprobante: "
    |> Util2.ingresar(:texto)
    |> Comprobante.generar(productores, clasificadas.validas)
    |> mostrar_comprobante()
  end

  # Solicita al usuario ingresar una entrega adicional y la procesa.
  defp agregar_entrega_adicional(entregas) do
    @pregunta_entrega
    |> Util2.ingresar(:texto)
    |> incorporar_entrega(entregas)
  end

  # Incorpora la entrega leída a la lista de entregas (caso base cuando se recibe cadena vacía).
  defp incorporar_entrega("", entregas), do: entregas

  # Intenta parsear el texto de una entrega e incorporarla a la lista de entregas.
  defp incorporar_entrega(texto, entregas) do
    case Entrada.parsear_entrega(texto) do
      {:ok, entrega} ->
        entregas ++ [entrega]

      {:error, :formato_invalido} ->
        Util2.mostrar(
          "Formato inválido: se ignora la entrega adicional. " <>
            "Use productor;tanque;dia;litros;grasa (ej: P03;T2;4;320.5;3.6)",
          :error
        )

        entregas
    end
  end

  # Combina los litros por día con otro centro y muestra un ranking de los 3 mejores productores según su pago neto.
  defp generar_investigacion(entregas_validas, productores) do
    combinado =
      entregas_validas
      |> Reportes.litros_por_dia()
      |> Investigacion.combinar_litros(@centro_vecino)
      |> Enum.sort()
      |> Enum.map(fn {dia, litros} -> " - Día #{dia}: #{litros} L\n" end)
      |> Enum.join()

    liquidaciones = Negocio.liquidar_todos(productores, entregas_validas)

    top_neto =
      Investigacion.ranking(liquidaciones, por: & &1.neto, top: 3)
      |> Enum.with_index(1)
      |> Enum.map(fn {l, i} -> " #{i}. #{l.nombre} (#{l.codigo}): $#{round(l.neto)}\n" end)
      |> Enum.join()

    """
    INVESTIGACIÓN: combinación con el centro vecino (Map.merge/3)
    #{combinado}
    Ranking (top 3 por neto a pagar, con ranking/2):
    #{top_neto}\
    """
  end

  # Muestra la lista de reportes en pantalla, separados por saltos de línea.
  defp mostrar_reportes(reportes) do
    reportes
    |> Enum.join("\n\n")
    |> Util2.mostrar(:mensaje)
  end

  # Muestra el comprobante de liquidación de un productor en pantalla.
  defp mostrar_comprobante({:ok, texto}) do
    Util2.mostrar("\n" <> texto, :mensaje)
  end

  # Muestra un mensaje de error si el productor no se encontró para su comprobante.
  defp mostrar_comprobante({:error, :productor_desconocido}) do
    Util2.mostrar("\nEl código ingresado no corresponde a ningún productor.", :mensaje)
  end
end

CentroAcopio.main()
