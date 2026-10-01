#Lopez Cuartas - Daniel Chacon
#
# Conjunto de datos de prueba para el centro de acopio de leche.
#   - 10 productores, 4 de ellos con transporte (P01, P03, P06, P09)
#   - 4 tanques
#   - entregas en los 6 días
#   - 80 entregas válidas
#   - al menos 2 entregas inválidas por cada uno de los 5 motivos de rechazo
#
#Pruebas:
#   - P10 no tiene ninguna entrega (debe aparecer en la liquidación con todo en cero)
#   - P01 entrega en los 4 tanques (candidato natural para R8)
#   - P02 en el día 3 tiene dos entregas pequeñas (220 y 260 litros) que SOLO SUMADAS
#     superan los 450 litros: sirve para comprobar que la bonificación depende del
#     total diario y no del número de entregas
defmodule Datos do
  @doc """
  Devuelve la lista de productores registrados en el sistema.

  ## Parámetros
  - No recibe parámetros.

  ## Ejemplo
  iex> Datos.productores()
  [%{codigo: "P01", ...}]
  """
  def productores do
    [
    %{codigo: "P01", nombre: "Marta Gómez", transporte: true},
    %{codigo: "P02", nombre: "Luis Cardona", transporte: false},
    %{codigo: "P03", nombre: "Ana Restrepo", transporte: true},
    %{codigo: "P04", nombre: "Carlos Zapata", transporte: false},
    %{codigo: "P05", nombre: "Diana Ríos", transporte: false},
    %{codigo: "P06", nombre: "Jorge Salazar", transporte: true},
    %{codigo: "P07", nombre: "Paola Herrera", transporte: false},
    %{codigo: "P08", nombre: "Andrés Molina", transporte: false},
    %{codigo: "P09", nombre: "Sandra Ocampo", transporte: true},
    %{codigo: "P10", nombre: "Felipe Marín", transporte: false}
    ]
  end

  @doc """
  Devuelve la lista de tanques disponibles en el centro de acopio.

  ## Parámetros
  - No recibe parámetros.

  ## Ejemplo
  iex> Datos.tanques()
  [%{id: "T1", ...}]
  """
  def tanques do
    [
    %{id: "T1", nombre: "Tanque Norte", capacidad: 12000},
    %{id: "T2", nombre: "Tanque Central", capacidad: 8500},
    %{id: "T3", nombre: "Tanque Sur", capacidad: 9500},
    %{id: "T4", nombre: "Tanque Oriente", capacidad: 10000}
    ]
  end

  @doc """
  Devuelve el conjunto de entregas realizadas.

  ## Parámetros
  - No recibe parámetros.

  ## Ejemplo
  iex> Datos.entregas()
  [%{productor: "P01", ...}]
  """
  def entregas do
    [
    %{productor: "P01", tanque: "T1", dia: 1, litros: 433, grasa: 3.1},
    %{productor: "P01", tanque: "T2", dia: 2, litros: 231, grasa: 3.4},
    %{productor: "P01", tanque: "T3", dia: 3, litros: 478, grasa: 1.6},
    %{productor: "P01", tanque: "T4", dia: 4, litros: 260, grasa: 3.9},
    %{productor: "P02", tanque: "T1", dia: 3, litros: 220, grasa: 4.4},
    %{productor: "P02", tanque: "T2", dia: 3, litros: 260, grasa: 3.7},
    %{productor: "P03", tanque: "T1", dia: 5, litros: 604, grasa: 3.1},
    %{productor: "P01", tanque: "T1", dia: 1, litros: 666, grasa: 1.5},
    %{productor: "P01", tanque: "T2", dia: 6, litros: 706, grasa: 3.8},
    %{productor: "P02", tanque: "T3", dia: 1, litros: 615, grasa: 2.7},
    %{productor: "P07", tanque: "T2", dia: 2, litros: 348, grasa: 3.7},
    %{productor: "P01", tanque: "T1", dia: 6, litros: 590, grasa: 2.9},
    %{productor: "P04", tanque: "T4", dia: 4, litros: 168, grasa: 4.2},
    %{productor: "P07", tanque: "T3", dia: 4, litros: 665, grasa: 3.3},
    %{productor: "P09", tanque: "T1", dia: 5, litros: 236, grasa: 3.2},
    %{productor: "P02", tanque: "T2", dia: 4, litros: 763, grasa: 2},
    %{productor: "P06", tanque: "T1", dia: 5, litros: 335, grasa: 3.4},
    %{productor: "P07", tanque: "T1", dia: 3, litros: 618, grasa: 3.2},
    %{productor: "P08", tanque: "T3", dia: 1, litros: 483, grasa: 2.5},
    %{productor: "P07", tanque: "T2", dia: 5, litros: 323, grasa: 2.5},
    %{productor: "P09", tanque: "T3", dia: 5, litros: 704, grasa: 3.2},
    %{productor: "P06", tanque: "T3", dia: 5, litros: 493, grasa: 3},
    %{productor: "P01", tanque: "T1", dia: 2, litros: 559, grasa: 4},
    %{productor: "P01", tanque: "T1", dia: 3, litros: 316, grasa: 2.9},
    %{productor: "P06", tanque: "T4", dia: 1, litros: 594, grasa: 2.9},
    %{productor: "P02", tanque: "T4", dia: 5, litros: 679, grasa: 3.2},
    %{productor: "P07", tanque: "T1", dia: 2, litros: 545, grasa: 4.1},
    %{productor: "P09", tanque: "T1", dia: 2, litros: 763, grasa: 3.4},
    %{productor: "P07", tanque: "T1", dia: 2, litros: 544, grasa: 3.2},
    %{productor: "P02", tanque: "T3", dia: 2, litros: 244, grasa: 4.2},
    %{productor: "P07", tanque: "T1", dia: 3, litros: 366, grasa: 3.5},
    %{productor: "P08", tanque: "T2", dia: 5, litros: 516, grasa: 2},
    %{productor: "P08", tanque: "T1", dia: 3, litros: 179, grasa: 1.7},
    %{productor: "P09", tanque: "T4", dia: 2, litros: 501, grasa: 4.2},
    %{productor: "P05", tanque: "T4", dia: 2, litros: 349, grasa: 2.3},
    %{productor: "P06", tanque: "T1", dia: 5, litros: 744, grasa: 2},
    %{productor: "P01", tanque: "T3", dia: 6, litros: 471, grasa: 2.5},
    %{productor: "P02", tanque: "T4", dia: 6, litros: 259, grasa: 2.5},
    %{productor: "P01", tanque: "T4", dia: 5, litros: 283, grasa: 3.4},
    %{productor: "P06", tanque: "T4", dia: 4, litros: 302, grasa: 3.3},
    %{productor: "P02", tanque: "T1", dia: 2, litros: 492, grasa: 4.1},
    %{productor: "P07", tanque: "T3", dia: 1, litros: 530, grasa: 1.2},
    %{productor: "P09", tanque: "T1", dia: 5, litros: 411, grasa: 2.6},
    %{productor: "P02", tanque: "T2", dia: 2, litros: 365, grasa: 2.7},
    %{productor: "P04", tanque: "T4", dia: 5, litros: 284, grasa: 2.5},
    %{productor: "P05", tanque: "T3", dia: 2, litros: 134, grasa: 2.9},
    %{productor: "P05", tanque: "T3", dia: 5, litros: 127, grasa: 2.2},
    %{productor: "P07", tanque: "T1", dia: 1, litros: 689, grasa: 2.8},
    %{productor: "P09", tanque: "T4", dia: 1, litros: 446, grasa: 4.3},
    %{productor: "P03", tanque: "T2", dia: 1, litros: 151, grasa: 3.5},
    %{productor: "P03", tanque: "T3", dia: 6, litros: 755, grasa: 1.8},
    %{productor: "P09", tanque: "T3", dia: 2, litros: 319, grasa: 2.7},
    %{productor: "P06", tanque: "T4", dia: 5, litros: 343, grasa: 3.4},
    %{productor: "P05", tanque: "T3", dia: 1, litros: 355, grasa: 4.6},
    %{productor: "P06", tanque: "T4", dia: 3, litros: 700, grasa: 3.9},
    %{productor: "P06", tanque: "T1", dia: 1, litros: 714, grasa: 2.6},
    %{productor: "P03", tanque: "T3", dia: 1, litros: 299, grasa: 2.6},
    %{productor: "P04", tanque: "T1", dia: 4, litros: 617, grasa: 3},
    %{productor: "P04", tanque: "T1", dia: 1, litros: 779, grasa: 2.2},
    %{productor: "P04", tanque: "T4", dia: 4, litros: 471, grasa: 2.4},
    %{productor: "P07", tanque: "T2", dia: 1, litros: 672, grasa: 1.9},
    %{productor: "P06", tanque: "T4", dia: 4, litros: 663, grasa: 3.3},
    %{productor: "P04", tanque: "T4", dia: 4, litros: 418, grasa: 3.4},
    %{productor: "P07", tanque: "T4", dia: 5, litros: 711, grasa: 3.1},
    %{productor: "P06", tanque: "T4", dia: 2, litros: 524, grasa: 2.6},
    %{productor: "P01", tanque: "T2", dia: 5, litros: 498, grasa: 2.7},
    %{productor: "P07", tanque: "T2", dia: 1, litros: 309, grasa: 4.1},
    %{productor: "P08", tanque: "T4", dia: 2, litros: 448, grasa: 4.5},
    %{productor: "P04", tanque: "T3", dia: 1, litros: 303, grasa: 2.2},
    %{productor: "P02", tanque: "T2", dia: 5, litros: 682, grasa: 2.3},
    %{productor: "P04", tanque: "T3", dia: 6, litros: 609, grasa: 3.2},
    %{productor: "P01", tanque: "T2", dia: 2, litros: 591, grasa: 1.7},
    %{productor: "P06", tanque: "T4", dia: 3, litros: 205, grasa: 3.9},
    %{productor: "P05", tanque: "T2", dia: 5, litros: 602, grasa: 4},
    %{productor: "P04", tanque: "T3", dia: 5, litros: 731, grasa: 2.5},
    %{productor: "P02", tanque: "T3", dia: 2, litros: 291, grasa: 1.6},
    %{productor: "P04", tanque: "T2", dia: 5, litros: 591, grasa: 4.5},
    %{productor: "P05", tanque: "T4", dia: 1, litros: 390, grasa: 3.2},
    %{productor: "P05", tanque: "T3", dia: 4, litros: 365, grasa: 2.4},
    %{productor: "P06", tanque: "T4", dia: 1, litros: 239, grasa: 3},
    %{productor: "P99", tanque: "T1", dia: 2, litros: 300, grasa: 3.2},
    %{productor: "PXX", tanque: "T2", dia: 4, litros: 250, grasa: 3},
    %{productor: "P02", tanque: "T9", dia: 1, litros: 200, grasa: 3.4},
    %{productor: "P05", tanque: "T5", dia: 3, litros: 180, grasa: 2.8},
    %{productor: "P03", tanque: "T1", dia: 0, litros: 200, grasa: 3.1},
    %{productor: "P04", tanque: "T2", dia: 7, litros: 210, grasa: 3.6},
    %{productor: "P06", tanque: "T3", dia: 2, litros: 0, grasa: 3},
    %{productor: "P07", tanque: "T4", dia: 5, litros: 950, grasa: 3.3},
    %{productor: "P08", tanque: "T1", dia: 4, litros: 300, grasa: -1},
    %{productor: "P09", tanque: "T2", dia: 6, litros: 280, grasa: 18.5}
    ]
  end
end
