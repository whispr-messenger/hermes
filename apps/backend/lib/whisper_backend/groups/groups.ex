defmodule WhisperBackend.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias WhisperBackend.Repo
  alias WhisperBackend.Groups.Group
  alias WhisperBackend.Groups.GroupMembership

  @doc """
  Creates a group.
  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.
  """
  def update_group(id, attrs, user_id) do
    group = get_group(id)
    
    if group && group.owner_id == user_id do
      group
      |> Group.changeset(attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a group.
  """
  def delete_group(id, user_id) do
    group = get_group(id)
    
    if group && group.owner_id == user_id do
      Repo.delete(group)
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Gets a group.
  """
  def get_group(id), do: Repo.get(Group, id)

  @doc """
  Gets all groups for a user.
  """
  def get_user_groups(user_id) do
    query = from g in Group,
            join: m in GroupMembership, on: m.group_id == g.id,
            where: m.user_id == ^user_id and m.status == "accepted",
            select: g
            
    Repo.all(query)
  end
end