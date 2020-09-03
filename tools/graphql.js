const { ApolloServer, gql, MockList } = require('apollo-server');
const faker = require('faker');

const fs = require('fs');
const schema = fs.readFileSync("./tmp/schema.graphql", 'utf-8');
const typeDefs = gql(schema);

const mocks = {
  String: () => faker.lorem.sentence(),
  Query: () => ({
    publicArticles: () => new MockList([0, 8]),
    draftArticles: () => new MockList([0, 8]),
  }),
  Article: () => ({
    uid: faker.random.uuid(),
    markdown: `## Hello

It is welog contents.

### List

uses \`*\`

* a
* b
* c

uses \`-\`

- 1
- 2
- 3

### Table

|v1|v2|
|---|---|
|FOO|BAR|
|HOGE|FUGA|

### Code

\`\`\`elm
module Welog exposing(..)


import Browser
import Html exposing(h1, text)


main : Program () Model Msg
main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }


type alias Model = String


init : Model
init = "Hello"


type Msg = Update String


update : Msg -> Model -> (Model, Cmd Msg)
update msg _ =
  case msg of
    Update str ->
      ( str, Cmd.none )


view : Model -> Html Msg
view model =
  h1 [] [ text (model ++ " welog!!") ]
\`\`\`

---

welog is awsome!!`,
    html: "",
    last_modified_at: Math.floor(Date.now() / 1000),
    prev_uid: faker.random.uuid(),
    next_uid: faker.random.uuid(),
  })
};

const server = new ApolloServer({
  typeDefs: typeDefs,
  mocks: mocks,
});

server.listen().then(({ url }) => {
  console.log(`🚀 Server ready at ${url}`)
});