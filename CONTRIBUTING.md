# Contributor Guidelines

## Commit Message Convention

For all commit messages the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#summary) styleguide shall be followed.
More information [here](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)

#### Editor Plugins

- [VSCode](https://marketplace.visualstudio.com/items?itemName=vivaxy.vscode-conventional-commits)
- [JetBrains IDEs](https://plugins.jetbrains.com/plugin/13389-conventional-commit)

### Enforcing commit message style via git hooks

> Please copy the [commit-msg](https://github.com/lucafluri/price_tracker/blob/dev/.githooks/commit-msg) git hook in .githooks into your local .git/hooks folder.  
> Before each commit the commit message gets checked and rejected if it does not meet the angular message style.

### Summary (from the angular guidelines)

**Motivation:** More readable commit history and using the git commit messages to **generate the automatic changelogs**.

#### Commit Message Format

Each commit message consists of a **header**, a **body** and a **footer**. The header has a special
format that includes a **type**, a **scope** and a **subject**:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The **header** is mandatory and the **scope** of the header is optional.

Any line of the commit message cannot be longer 100 characters! This allows the message to be easier
to read on GitHub as well as in various git tools.

The footer should contain a [closing reference to an issue](https://help.github.com/articles/closing-issues-via-commit-messages/) if any.

Samples: (even more [samples](https://github.com/angular/angular/commits/master))

#### Types

Must be one of the following:

- **build**: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **ci**: Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: Documentation only changes
- **feat**: A new feature
- **fix**: A bug fix
- **perf**: A code change that improves performance
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: Adding missing tests or correcting existing tests

#### Subject

The subject contains a succinct description of the change:

- use the imperative, present tense: "change" not "changed" nor "changes"
- don't capitalize the first letter
- no dot (.) at the end

#### Body

Just as in the **subject**, use the imperative, present tense: "change" not "changed" nor "changes".
The body should include the motivation for the change and contrast this with previous behavior.

#### Footer

The footer should contain any information about **Breaking Changes** and is also the place to
reference GitHub issues that this commit **Closes**.

**Breaking Changes** should start with the word `BREAKING CHANGE:` with a space or two newlines. The rest of the commit message is then used for this.

## Code Style

Generally the [Dart Codestyle](https://dart.dev/guides/language/effective-dart/style) shall be followed.
This can most likely be automated via formatters in your IDE.

## Folder Structure

https://medium.com/flutter-community/flutter-code-organization-revised-b09ad5cef7f6
