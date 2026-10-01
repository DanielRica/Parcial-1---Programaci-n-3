#Lopez Cuartas - Daniel Chacon
#
# Módulo Entrada: convierte el texto de la entrega adicional
# (productor;tanque;dia;litros;grasa) en un mapa de entrega.
#
# Esta función SOLO revisa el formato. Las reglas de negocio (productor
# existente, día entre 1 y 6, etc.) las aplica después Validacion, igual
# que con las entregas de datos.exs.
#
# Se usa Integer.parse/1 y Float.parse/1.

defmodule Entrada do
  @separador ";"
  @cantidad_campos 5

  @doc """
  Convierte el texto de una entrega adicional en un mapa de entrega.

  ## Parámetros
  - texto: texto que contiene los datos de la entrega separados por un delimitador

  ## Ejemplo
  iex> Entrada.parsear_entrega("P03;T2;4;320.5;3.6")
  {:ok, %{productor: "P03", tanque: "T2", dia: 4, litros: 320.5, grasa: 3.6}}
  """
  def parsear_entrega(texto) do
    campos = texto |> String.split(@separador) |> Enum.map(&String.trim/1)

    with true <- length(campos) == @cantidad_campos,
         [productor, tanque, dia, litros, grasa] <- campos,
         {:ok, dia} <- a_entero(dia),
         {:ok, litros} <- a_numero(litros),
         {:ok, grasa} <- a_numero(grasa) do
      {:ok, %{productor: productor, tanque: tanque, dia: dia, litros: litros, grasa: grasa}}
    else
      _ -> {:error, :formato_invalido}
    end
  end

  # --- Conversiones (devuelven {:ok, numero} o :error) ---

  # Convierte una cadena a entero. Devuelve {:ok, entero} o :error.
  defp a_entero(texto) do
    case Integer.parse(texto) do
      {numero, ""} -> {:ok, numero}
      _ -> :error
    end
  end

  # Convierte una cadena a entero o decimal. Devuelve {:ok, numero} o :error.
  defp a_numero(texto) do
    case a_entero(texto) do
      {:ok, numero} ->
        {:ok, numero}

      :error ->
        case Float.parse(texto) do
          {numero, ""} -> {:ok, numero}
          _ -> :error
        end
    end
  end
end
