#Lopez Cuartas - Daniel Chacon
#
# Módulo de validación de entregas.
# Reglas de negocio, en el orden exacto exigido por el enunciado:
#   1. El código del productor existe          -> :productor_desconocido
#   2. El tanque existe                        -> :tanque_desconocido
#   3. El día es un entero entre 1 y 6         -> :dia_invalido
#   4. Los litros son > 0 y <= 800             -> :litros_fuera_de_rango
#   5. El porcentaje de grasa está entre 0 y 15 -> :porcentaje_invalido
#
# Se usa `with` para encadenar las verificaciones y detenerse en la primera
# que falle, tal como lo exige el enunciado. No hay recursividad ni structs:
# solo mapas, tuplas {:ok, _} / {:error, _} y funciones que dependen
# únicamente de sus argumentos (funciones puras).

defmodule Validacion do
  @dia_minimo 1
  @dia_maximo 6
  @litros_minimo 0
  @litros_maximo 800
  @grasa_minima 0
  @grasa_maxima 15

  @doc """
  Valida una entrega contra las listas de productores y tanques conocidos, así como sus rangos.

  ## Parámetros
  - entrega: mapa con la información de la entrega a validar
  - productores: lista de todos los productores registrados
  - tanques: lista de todos los tanques registrados

  ## Ejemplo
  iex> Validacion.validar_entrega(%{productor: "P01", tanque: "T1", dia: 1, litros: 200, grasa: 3.5}, productores, tanques)
  {:ok, %{productor: "P01", tanque: "T1", dia: 1, litros: 200, grasa: 3.5}}
  """
  def validar_entrega(entrega, productores, tanques) do
    with {:ok, _} <- verificar_productor(entrega, productores),
         {:ok, _} <- verificar_tanque(entrega, tanques),
         {:ok, _} <- verificar_dia(entrega),
         {:ok, _} <- verificar_litros(entrega),
         {:ok, _} <- verificar_grasa(entrega) do
      {:ok, entrega}
    end
  end

  @doc """
  Aplica la validación a toda una colección de entregas y las clasifica.

  ## Parámetros
  - entregas: lista de entregas a validar y clasificar
  - productores: lista de todos los productores registrados
  - tanques: lista de todos los tanques registrados

  ## Ejemplo
  iex> Validacion.clasificar_entregas(entregas, productores, tanques)
  %{validas: [...], invalidas: [...]}
  """
  def clasificar_entregas(entregas, productores, tanques) do
    resultados =
      Enum.map(entregas, fn entrega ->
        {entrega, validar_entrega(entrega, productores, tanques)}
      end)

    validas =
      resultados
      |> Enum.filter(fn {_entrega, resultado} -> match?({:ok, _}, resultado) end)
      |> Enum.map(fn {entrega, _resultado} -> entrega end)

    invalidas =
      resultados
      |> Enum.filter(fn {_entrega, resultado} -> match?({:error, _}, resultado) end)
      |> Enum.map(fn {entrega, {:error, motivo}} -> %{entrega: entrega, motivo: motivo} end)

    %{validas: validas, invalidas: invalidas}
  end

  # --- Verificaciones individuales (cada una es el "cómo" de una regla) ---

  # Verifica si el productor indicado en la entrega existe en la lista de productores.
  defp verificar_productor(%{productor: codigo}, productores) do
    if Enum.any?(productores, fn p -> p.codigo == codigo end) do
      {:ok, codigo}
    else
      {:error, :productor_desconocido}
    end
  end

  # Verifica si el tanque indicado en la entrega existe en la lista de tanques.
  defp verificar_tanque(%{tanque: id}, tanques) do
    if Enum.any?(tanques, fn t -> t.id == id end) do
      {:ok, id}
    else
      {:error, :tanque_desconocido}
    end
  end

  # Verifica que el día de la entrega esté dentro del rango permitido (1 a 6).
  defp verificar_dia(%{dia: dia})
       when is_integer(dia) and dia >= @dia_minimo and dia <= @dia_maximo do
    {:ok, dia}
  end

  defp verificar_dia(_entrega), do: {:error, :dia_invalido}

  # Verifica que los litros de la entrega estén dentro del rango permitido.
  defp verificar_litros(%{litros: litros})
       when is_number(litros) and litros > @litros_minimo and litros <= @litros_maximo do
    {:ok, litros}
  end

  defp verificar_litros(_entrega), do: {:error, :litros_fuera_de_rango}

  # Verifica que el porcentaje de grasa esté dentro del rango permitido.
  defp verificar_grasa(%{grasa: grasa})
       when is_number(grasa) and grasa >= @grasa_minima and grasa <= @grasa_maxima do
    {:ok, grasa}
  end

  defp verificar_grasa(_entrega), do: {:error, :porcentaje_invalido}
end
