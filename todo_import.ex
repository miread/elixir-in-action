defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1))
  end

  def add_entry(
    %TodoList{entries: entries, auto_id: auto_id} = todo_list,
    entry) do
      #Adds ID to new entry
      entry = Map.put(entry, :id, auto_id)
      #Adds the new entry to the existing entries list
      new_entries = Map.put(entries, auto_id, entry)
      #Updates the struct - new entry + prepare next ID
      %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end
end

defmodule TodoList.CsvImporter do
  def import(filename) do
    read_lines(filename)
    |> Stream.map(&extract_fields(&1))
    |> Stream.map(&create_entry(&1))
    |> TodoList.new()
  end

  def read_lines(filename) do
    File.stream!(filename)
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  def extract_fields(line) do
    line
    |> String.split(",")
    |> convert_date
  end

  def convert_date([date_string, title]) do
    {parse_date(date_string), title}
  end

  def parse_date(date_string) do
    [year, month, day] =
      String.split(date_string, "/")
      |> Enum.map(&String.to_integer(&1))
      {year, month, day}
  end

  def create_entry({date, title}) do
    %{date: date, title: title}
  end
end
