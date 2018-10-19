defmodule PrismaIDNA do
  @moduledoc """
  Documentation for PrismaIDNA.
  """

  @doc """
  Hello world.

  ## Examples

      iex> PrismaIDNA.hello()
      :world

  """
  def hello do
    :world
  end

  def fakerql_user_names do
    query = "query {
      allUsers {
        firstName
      }
    }"

    variables = %{}
    options = %{
      url: "https://fakerql.com/graphql"
    }

    SimpleGraphqlClient.graphql_request(query, variables, options)
  end

  def prisma_user_names do
    query = "query {
      allUsers {
        firstName
      }
    }"

    variables = %{}
    options = %{
      url: Application.get_env(:elixir_prisma_graphql_idna_issue, :prisma_url),
      headers: [{"Authorization", "Bearer #{Application.get_env(:elixir_prisma_graphql_idna_issue, :prisma_token)}"}]
    }

    SimpleGraphqlClient.graphql_request(query, variables, options)
  end
end
