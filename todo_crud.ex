defmodule TodoList do

  defstruct auto_id: 1, entries: %{}

  def new, do: %TodoList{}

  def add_entry(
    %TodoList{entries: entries, auto_id: auto_id} = todo_list, # destructured
    entry) do
      #Adds ID to new entry
      entry = Map.put(entry, :id, auto_id)
      #Adds the new entry to the existing entries list
      new_entries = Map.put(entries, auto_id, entry)
      #Updates the struct - new entry + prepare next ID
      %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) -> entry.date == date end)
    |> Enum.map(fn({_, entry}) -> entry end)
  end

  def update_entry(
    %TodoList{entries: entries} = todo_list,
    entry_id,
    updater_fun
  ) do
    case entries[entry_id] do
      nil -> todo_list  # No entry returns list unchanged

      old_entry ->  # Matches all entries
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(%TodoList{entries: entries} = todo_list, del_id) do
    new_entries = Map.delete(entries, del_id)
    %TodoList{todo_list | entries: new_entries}
  end

end
