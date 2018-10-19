# PrismaIDNA

## The Issue [](https://github.com/prisma/prisma-cloud-feedback/issues)

The service domain used by prisma to host both the graphql-playground and graphql-api is not complaint with the RFC1034 spec for CNAME labels.

```
server-name_organization.prisma.sh.	128 IN CNAME random-aws-resource.eu-west-1.elb.amazonaws.com.
```

The left side is called label and the right side `CNAME`, therefore the label would be `server-name_organization.prisma.sh.` and the `CNAME` consequently `random-aws-resource.eu-west-1.elb.amazonaws.com.`.
Most implementations of the RFC don't seem to have a problem with the, by spec, illegal `_` character but some implement it very strictly, one of these more strict one is the [erlang idna package](https://hex.pm/packages/idna).

> For you to be able to test this issue and hopefully find a solution I've setup a small test project over at [zetaron/elixir-prisma-graphql-idna-issue](https://github.com/zetaron/elixir-prisma-graphql-idna-issue), please follow the README on how to use it.

## Running the Sample

Setup you prisma endpoint inside the `config/config.exs` File:
```elixir
config :elixir_prisma_graphql_idna_issue,
  prisma_url: "https://some-database_some-organization.prisma.sh/service/stage",
  prisma_token: ""
```

```bash
docker run \
  --rm \
  -it \
  -v $(pwd):/usr/src/myapp \
  -w /usr/src/myapp \
  elixir sh -c "mix local.hex --force && mix deps.get && iex -S mix"
```

This command uses the official `elixir` docker image to provide a clean and reproducible environment.
It then installs the `hex` package manager and fetches the projects dependencies, the last segment then starts an interactive elixir shell with the project started as a background process.

To validate that everything is setup correctly run this inside the interactive elixir shell:

```elixir
iex(1)> PrismaIDNA.fakerql_user_names
```

This should generate output similar to the following:

<details><summary>Expected Output (click to toggle expansion)</summary>
<p>

```elixir
{:ok,
 %SimpleGraphqlClient.Response{
   body: {:ok,
    %{
      "data" => %{
        "allUsers" => [
          %{"firstName" => "Lauren"},
          %{"firstName" => "Chesley"},
          %{"firstName" => "Melisa"},
          %{"firstName" => "Hallie"},
          %{"firstName" => "Elfrieda"},
          %{"firstName" => "Marley"},
          %{"firstName" => "Imani"},
          %{"firstName" => "Nora"},
          %{"firstName" => "Devon"},
          %{"firstName" => "Lyric"},
          %{"firstName" => "Cara"},
          %{"firstName" => "Ansel"},
          %{"firstName" => "Minerva"},
          %{"firstName" => "Victor"},
          %{"firstName" => "Orpha"},
          %{"firstName" => "Gillian"},
          %{"firstName" => "Jocelyn"},
          %{"firstName" => "Wilford"},
          %{"firstName" => "Helena"},
          %{"firstName" => "Stone"},
          %{"firstName" => "Kade"},
          %{"firstName" => "Zachariah"},
          %{"firstName" => "Micaela"},
          %{"firstName" => "Wade"},
          %{"firstName" => "Rod"}
        ]
      }
    }},
   headers: [
     {"Date", "Thu, 18 Oct 2018 11:57:56 GMT"},
     {"Content-Type", "application/json"},
     {"Content-Length", "592"},
     {"Connection", "keep-alive"},
     {"Access-Control-Allow-Origin", "*"},
     {"Vary", "Accept-Encoding"},
     {"x-now-trace", "bru1"},
     {"server", "now"},
     {"now", "1"},
     {"cache-control", "s-maxage=0"},
     {"X-Now-Id", "nh4kb-1539863876352-ntAD0zQeMzEtmGFD7VOLvGMJ"},
     {"X-Now-Instance", "385951122"},
     {"Accept-Ranges", "bytes"}
   ],
   status_code: 200
 }}
```

</p>
</details>

Now for the actual issue, run the following command:

```elixir
iex(2)> PrismaIDNA.prisma_user_names
```

This should generate output similar to the following:

<details><summary>Expected Output (click to toggle expansion)</summary>
<p>

```elixir
** (exit) {:bad_label, {:alabel, 'The label "some-database_some-organization"  is not a valid A-label: ulabel error={bad_label,\n                                                              {context,\n          "Codepoint 95 not allowed (\'DISALLOWED\') at posion 17 in \\"some-database_some-organization\\""}}'}}
    (idna) /Users/fst/src/github.com/zetaron/elixir-prisma-graphql-idna-issue/deps/idna/src/idna.erl:277: :idna.alabel/1
    (idna) /Users/fst/src/github.com/zetaron/elixir-prisma-graphql-idna-issue/deps/idna/src/idna.erl:145: :idna.encode_1/2
    (hackney) /Users/fst/src/github.com/zetaron/elixir-prisma-graphql-idna-issue/deps/hackney/src/hackney_url.erl:99: :hackney_url.normalize/2
    (hackney) /Users/fst/src/github.com/zetaron/elixir-prisma-graphql-idna-issue/deps/hackney/src/hackney.erl:305: :hackney.request/5
    (httpoison) lib/httpoison/base.ex:633: HTTPoison.Base.request/9
    (simple_graphql_client) lib/simple_graphql_client.ex:43: SimpleGraphqlClient.graphql_request/3
```

</p>
</details>
