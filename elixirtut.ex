defmodule M do
  def getter do
    days =
      %{} |>
        Map.put(1, "Monday") |>
        Map.put(2, "Tuesday")
    Map.get(days, 1)
  end
end
