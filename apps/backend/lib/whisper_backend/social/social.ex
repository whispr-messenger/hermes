defmodule WhisperBackend.Social do
  @moduledoc """
  The Social context.
  """

  import Ecto.Query, warn: false
  alias WhisperBackend.Repo
  alias WhisperBackend.Social.Friendship
  alias WhisperBackend.Social.Post
  alias WhisperBackend.Social.PostComment
  alias WhisperBackend.Social.PostLike
  alias WhisperBackend.Social.PostMedia
  alias WhisperBackend.Social.PostReport
  alias WhisperBackend.Accounts.User
  alias WhisperBackend.Media.MediaFile

  @doc """
  Creates a friendship request.
  """
  def create_friendship_request(user_id, friend_id) do
    %Friendship{}
    |> Friendship.changeset(%{user_id: user_id, friend_id: friend_id, status: "pending"})
    |> Repo.insert()
  end

  @doc """
  Accepts a friendship request.
  """
  def accept_friendship(user_id, friend_id) do
    # Find the friendship request
    friendship = get_friendship(user_id, friend_id)
    
    if friendship do
      # Update the status to accepted
      friendship
      |> Friendship.changeset(%{status: "accepted"})
      |> Repo.update()
      
      # Create the reverse friendship
      %Friendship{}
      |> Friendship.changeset(%{user_id: friend_id, friend_id: user_id, status: "accepted"})
      |> Repo.insert()
    else
      {:error, :not_found}
    end
  end

  @doc """
  Rejects a friendship request.
  """
  def reject_friendship(user_id, friend_id) do
    friendship = get_friendship(user_id, friend_id)
    
    if friendship do
      friendship
      |> Friendship.changeset(%{status: "rejected"})
      |> Repo.update()
    else
      {:error, :not_found}
    end
  end

  @doc """
  Deletes a friendship.
  """
  def delete_friendship(user_id, friend_id) do
    # Delete both directions of the friendship
    Repo.transaction(fn ->
      {_, _} = from(f in Friendship, where: f.user_id == ^user_id and f.friend_id == ^friend_id)
      |> Repo.delete_all()
      
      {_, _} = from(f in Friendship, where: f.user_id == ^friend_id and f.friend_id == ^user_id)
      |> Repo.delete_all()
    end)
  end

  @doc """
  Gets a friendship.
  """
  def get_friendship(user_id, friend_id) do
    Repo.one(from f in Friendship, where: f.user_id == ^user_id and f.friend_id == ^friend_id)
  end

  @doc """
  Gets all friends for a user.
  """
  def get_friends(user_id) do
    query = from f in Friendship,
            where: f.user_id == ^user_id and f.status == "accepted",
            join: u in User, on: f.friend_id == u.id,
            select: u
            
    Repo.all(query)
  end

  @doc """
  Creates a post.
  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.
  """
  def update_post(id, attrs, user_id) do
    post = get_post(id)
    
    if post && post.user_id == user_id do
      post
      |> Post.changeset(attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a post.
  """
  def delete_post(id, user_id) do
    post = get_post(id)
    
    if post && post.user_id == user_id do
      Repo.delete(post)
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Gets a post.
  """
  def get_post(id), do: Repo.get(Post, id)

  @doc """
  Gets all posts for a user.
  """
  def get_user_posts(user_id) do
    query = from p in Post,
            where: p.user_id == ^user_id and p.status == "active",
            order_by: [desc: p.inserted_at]
            
    Repo.all(query)
  end

  @doc """
  Gets all public posts.
  """
  def get_public_posts do
    query = from p in Post,
            where: p.visibility == "public" and p.status == "active",
            order_by: [desc: p.inserted_at]
            
    Repo.all(query)
  end

  @doc """
  Adds a media attachment to a post.
  """
  def add_post_media(post_id, media_id, user_id) do
    post = get_post(post_id)
    media = WhisperBackend.Media.get_media_file(media_id)
    
    if post && post.user_id == user_id && media && media.user_id == user_id do
      # Create association between post and media
      %WhisperBackend.Social.PostMedia{}
      |> WhisperBackend.Social.PostMedia.changeset(%{post_id: post_id, media_id: media_id})
      |> Repo.insert()
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Removes a media attachment from a post.
  """
  def remove_post_media(post_id, media_id, user_id) do
    post = get_post(post_id)
    
    if post && post.user_id == user_id do
      from(pm in PostMedia, where: pm.post_id == ^post_id and pm.media_id == ^media_id)
      |> Repo.delete_all()
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Adds a comment to a post.
  """
  def add_comment(attrs \\ %{}) do
    %PostComment{}
    |> PostComment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.
  """
  def update_comment(id, attrs, user_id) do
    comment = get_comment(id)
    
    if comment && comment.user_id == user_id do
      comment
      |> PostComment.changeset(attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a comment.
  """
  def delete_comment(id, user_id) do
    comment = get_comment(id)
    post = comment && get_post(comment.post_id)
    
    # Allow comment deletion by comment author or post author
    if comment && (comment.user_id == user_id || (post && post.user_id == user_id)) do
      Repo.delete(comment)
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Gets a comment.
  """
  def get_comment(id), do: Repo.get(PostComment, id)

  @doc """
  Gets all comments for a post.
  """
  def get_post_comments(post_id) do
    query = from c in PostComment,
            where: c.post_id == ^post_id,
            order_by: [asc: c.inserted_at],
            preload: [:user]
            
    Repo.all(query)
  end

  @doc """
  Likes a post.
  """
  def like_post(post_id, user_id) do
    # Check if already liked
    existing_like = Repo.one(
      from l in PostLike,
      where: l.post_id == ^post_id and l.user_id == ^user_id
    )
    
    if existing_like do
      {:ok, existing_like}
    else
      %PostLike{}
      |> PostLike.changeset(%{post_id: post_id, user_id: user_id})
      |> Repo.insert()
    end
  end

  @doc """
  Unlikes a post.
  """
  def unlike_post(post_id, user_id) do
    {count, _} = from(l in PostLike, where: l.post_id == ^post_id and l.user_id == ^user_id)
    |> Repo.delete_all()
    
    {:ok, count}
  end

  @doc """
  Gets like count for a post.
  """
  def get_post_like_count(post_id) do
    Repo.one(from l in PostLike, where: l.post_id == ^post_id, select: count(l.id))
  end

  @doc """
  Checks if a user has liked a post.
  """
  def user_liked_post?(post_id, user_id) do
    Repo.exists?(from l in PostLike, where: l.post_id == ^post_id and l.user_id == ^user_id)
  end

  @doc """
  Gets the feed for a user (posts from friends and public posts).
  """
  def get_user_feed(user_id) do
    # Get user's friends
    friend_ids = from(f in Friendship,
                  where: f.user_id == ^user_id and f.status == "accepted",
                  select: f.friend_id)
                  |> Repo.all()
    
    # Get posts from friends and public posts
    query = from p in Post,
            where: (p.user_id in ^friend_ids and p.status == "active") or 
                   (p.visibility == "public" and p.status == "active"),
            order_by: [desc: p.inserted_at],
            preload: [:user]
            
    Repo.all(query)
  end

  @doc """
  Searches for posts by content.
  """
  def search_posts(query_string) do
    search_term = "%#{query_string}%"
    
    query = from p in Post,
            where: ilike(p.content, ^search_term) and p.status == "active" and p.visibility == "public",
            order_by: [desc: p.inserted_at],
            preload: [:user]
            
    Repo.all(query)
  end

  @doc """
  Reports a post for moderation.
  """
  def report_post(post_id, user_id, reason) do
    %PostReport{}
    |> PostReport.changeset(%{post_id: post_id, reporter_id: user_id, reason: reason})
    |> Repo.insert()
  end
end