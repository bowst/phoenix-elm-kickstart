# Phoenix Elm Project Kickstarter

## Getting Started

### Installing Erlang/Elixir

Follow the instructions located here: https://elixir-lang.org/install.html

### Running Locally

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Project Structure

### Overview
Pages can either be rendered server-side (e.g. via a Phoenix template) or client-side (e.g. via Elm).  In general, pages that do not require a user to be authenticated are rendered server-side, while the application itself is primarily rendered client-side.

Client side pages request application resources via a GraphQL API exposed by the server.  The following libraries are critical to manageing this communication:

   * Server side: https://hexdocs.pm/absinthe/overview.html
   * Client side: https://package.elm-lang.org/packages/jamesmacaulay/elm-graphql/latest/

Additionally, this projects come's with Bowst's "API" utilities, which are built on top of this stack and facilitate many routine interactions (such as querying and handling errors during resource mutations).

### Phoenix

Comes with a configured `Auth` context to manage user authentication.  Additional project specific context can be added to build out project features.

### Elm

For the most part, follows the excellent Elm Real World SPA, which can be found here: https://github.com/rtfeldman/elm-spa-example.  There are a few modifications to better suite the needs of our applications.  

The biggest difference is Page/Routing structure.  Rather than having a centralized routing file which contains all project routes, this project allows for multiple levels of routing.

For example, the top level routes are simply:
 * Dashboard
 * UserRoutes
 
 However, there is a seperate module for handling all UserRoutes, and can deletegate to the specific route requested in that subsection.  In this project kickstart, we've simply included the basic list, view, edit/create, and remove routes in the users subsection as an example.
 
## Phoenix Resources

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Elm Resources

  * Official website: http://elm-lang.org/
  * Guides: https://guide.elm-lang.org/
  * Docs: http://elm-lang.org/docs
  * Package Docs: https://package.elm-lang.org
